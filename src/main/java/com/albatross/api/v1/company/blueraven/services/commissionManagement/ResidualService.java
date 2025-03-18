package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.commissionManagement.ResidualController;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.CommissionPlanStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.*;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.queries.ResidualQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ResidualService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final DataSource dataSource;

  public List<Residual> getResiduals() {
    return sqlCache.queryBySql(ResidualQuery.getAll, Collections.emptyMap(), Residual.class);
  }

  @Data
  public static class ResidualProject {
    Long id;
    String projectName, projectNameWithId;
  }

  public List<ResidualProject> getResidualProjects(String search) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("search", search);
    return sqlCache.queryBySql(ResidualQuery.getProjects, params, ResidualProject.class);
  }

  public void saveProjectOverride(ResidualController.ProjectOverride projectOverride) {
    User currentUser = securityService.getCurrentUser();

    try {

      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectOverride.getProjectId());
      params.put("overrideDate", projectOverride.getOverrideDate());
      params.put("userId", currentUser.trueUserId());
      sqlCache.updateBySql(ResidualQuery.addProjectOverride, params);
      sqlCache.updateBySql(ResidualQuery.deleteProjectQualified, params);
    } catch (DuplicateKeyException e) {
      String msg = "An override date already exists for this project";
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, msg);
    }
  }

  public List<ResidualDetail> getCurrentClawbacks(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    return sqlCache.queryBySql(ResidualQuery.getCurrentClawbacks, params, ResidualDetail.class);
  }

  public List<ResidualDetail> getResidualQualifiedLifetimeFds(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    return sqlCache.queryBySql(ResidualQuery.getResidualQualifiedLifetimeFds, params, ResidualDetail.class);
  }

  public List<ResidualDetail> getResidualQualifiedFdsThisPeriod(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    return sqlCache.queryBySql(ResidualQuery.getResidualQualifiedFdsThisPeriod, params, ResidualDetail.class);
  }

  public List<ResidualDetail> getResidualNotQualifiedFdsThisPeriod(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    return sqlCache.queryBySql(ResidualQuery.getResidualNotQualifiedFdsThisPeriod, params, ResidualDetail.class);
  }

  public List<ResidualDetail> getSnapshotFdc(Long residualId, Long userId, Long snapshotTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", residualId);
    params.put("userId", userId);
    params.put("snapshotTypeId", snapshotTypeId);
    return sqlCache.queryBySql(ResidualQuery.getSnapshotFdc, params, ResidualDetail.class);
  }

  public List<ResidualPlan> getResidualPlans() {
    return sqlCache.queryBySql(ResidualQuery.getAllPlans, Collections.emptyMap(), ResidualPlan.class);
  }

  public String updateResidualPlan(ResidualPlan residualPlan) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("name", residualPlan.getName());
    params.put("description", residualPlan.getDescription());

    User currentUser = securityService.getCurrentUser();

    long planId;
    if (residualPlan.getId() == null) {
      params.put("createdById", currentUser.trueUserId());
      planId = sqlCache.updateBySqlReturningId(ResidualQuery.createPlan, params, "id").longValue();
    } else {
      params.put("updatedBy", currentUser.trueUserId());
      params.put("id", residualPlan.getId());
      planId = sqlCache.updateBySqlReturningId(ResidualQuery.updatePlan, params, "id").longValue();
    }

    return getResidualPlanDetails(planId);
  }

  public String getResidualPlanDetails(Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);

    return sqlCache
      .getBySql(ResidualQuery.getResidualPlanDetails, params, new SingleColumnRowMapper<>(String.class))
      .orElse("{}");
  }

  public String findUserForResidual(String search, Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("search", search + "%");
    params.put("planId", planId);

    List<String> query =
      sqlCache.queryBySql(
        ResidualQuery.findUsers, params, new SingleColumnRowMapper<>(String.class));
    return query.isEmpty() ? "[]" : query.get(0);
  }

  public String getResidualPlanUserHistory(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    List<String> query =
      sqlCache.queryBySql(
        ResidualQuery.getResidualPlanUserHistory,
        params,
        new SingleColumnRowMapper<>(String.class));
    return query.isEmpty() ? "[]" : query.get(0);
  }

  public void insertUser(Long planId, PlanAssignment user) {
    User currentUser = securityService.getCurrentUser();
    final Date newStartDate = user.getStartDate();

    Map<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("userId", user.getUserId());
    params.put("startDate", newStartDate);
    params.put("endDate", user.getEndDate());
    params.put("currentUserId", currentUser.trueUserId());

    if (user.getId() != null) {
      params.put("id", user.getId());
      sqlCache.updateBySql(ResidualQuery.updatePlanUser, params);
    } else {
      sqlCache.updateBySql(ResidualQuery.insertPlanEndDate, params);
      sqlCache.updateBySql(ResidualQuery.insertPlanUser, params);
      //keller had me take this out
//      sqlCache.updateBySql(ResidualQuery.updateUserResidualPlans, params);
    }
  }

  public String getResidualPlanUsers(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", id);

    return sqlCache
      .getBySql(ResidualQuery.getResidualPlanUsers, params, new SingleColumnRowMapper<>(String.class))
      .orElse("[]");
  }

  public void deletePlan(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("planId", id);
    sqlCache.updateBySql(ResidualQuery.deletePlan, params);
  }

  public void approvePlan(Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("approvedById", securityService.getCurrentUser().getId());
    params.put("statusId", CommissionPlanStatus.ACTIVE.getId());

    sqlCache.updateBySql(ResidualQuery.approvePlan, params);
  }

  public String insertAllocation(Long planId, ResidualPlanAllocation rpa) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("createdById", currentUser.trueUserId());
    params.put("min", rpa.getMin());
    params.put("max", rpa.getMax());
    params.put("allocation", rpa.getAllocation());

    Long id = sqlCache.updateBySqlReturningId(ResidualQuery.insertAllocation, params, "id").longValue();
    return getResidualPlanAllocation(id);
  }

  public void updateAllocation(Long planId, ResidualPlanAllocation rpa) {
    Map<String, Object> params = new HashMap<>();
    params.put("min", rpa.getMin());
    params.put("max", rpa.getMax());
    params.put("allocation", rpa.getAllocation());
    params.put("id", rpa.getId());

    sqlCache.updateBySql(ResidualQuery.updateAllocation, params);
  }

  public void removeAllocation(Long planId, Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.updateBySql(ResidualQuery.removeAllocation, params);
  }

  public String getResidualPlanAllocation(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache
      .getBySql(
        ResidualQuery.getResidualPlanAllocation, params, new SingleColumnRowMapper<>(String.class))
      .orElse("{}");
  }

  public Optional<Long> clonePlan(Long id, ResidualPlan residualPlan) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", id);
    params.put("startDate", residualPlan.getStartDate());
    params.put("createdById", securityService.getCurrentUser().trueUserId());

    try (Connection connection = dataSource.getConnection()) {

      List<Long> users = residualPlan.getUsers();
      if (users != null && !users.isEmpty()) {
        Array usersArray = connection.createArrayOf("int", users.toArray());
        params.put("users", usersArray);
      } else {
        params.put("users", null);
      }

    } catch (SQLException e) {
      log.error("COMMISSION: residual sql exception", e);
    }

    return sqlCache.getBySql(ResidualQuery.clonePlan, params, new SingleColumnRowMapper<>(Long.class));
  }

    public List<ResidualSource> getAvailableSources(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);

        return sqlCache.queryBySql(ResidualQuery.getAvailableSources, params, ResidualSource.class);
    }

    public ResidualSource saveSource(Long planId, ResidualSource source) {
        Map<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("sourceId", source.getSourceId());
        params.put("amount", source.getAmount());

        Long id =
                sqlCache.updateBySqlReturningId(ResidualQuery.saveSource, params, "id").longValue();
        return getSource(id);
    }

    public ResidualSource updateSource(Long planId, ResidualSource source) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", source.getId());
        params.put("amount", source.getAmount());

        sqlCache.updateBySql(ResidualQuery.updateSource, params);
        return getSource(source.getId());
    }

    public void removeSource(Long planId, Long sourceId) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", sourceId);
        sqlCache.updateBySql(ResidualQuery.removeSource, params);
    }

    public ResidualSource getSource(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        Optional<ResidualSource> result = sqlCache.getBySql(ResidualQuery.getSource, params, ResidualSource.class);
        return result.orElse(null);
    }
}
