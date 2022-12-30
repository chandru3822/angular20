package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.CommissionPlanStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.PlanUser;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Residual;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.ResidualPlan;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.ResidualPlanAllocation;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.queries.ResidualQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ResidualService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final DataSource dataSource;

  public Residual updateResidual(Residual residual) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("name", "put name here or whatever");

    User currentUser = securityService.getCurrentUser();

    long id;
    if (residual.getId() == null) {
      params.put("createdBy", currentUser.trueUserId());
      id = sqlCache.updateBySqlReturningId(ResidualQuery.insert, params, "id").longValue();
    } else {
      params.put("updatedBy", currentUser.trueUserId());
      params.put("id", residual.getId());
      id = sqlCache.updateBySqlReturningId(ResidualQuery.update, params, "id").longValue();
    }



    return getResidual(id);
  }

  public List<Residual> getResiduals() {
    return sqlCache.queryBySql(ResidualQuery.getAll, Collections.emptyMap(), Residual.class);
  }

  public Residual getResidual(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(ResidualQuery.getOne, params, Residual.class).orElse(null);
  }

  public void deleteResidual(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.getBySql(ResidualQuery.delete, params, Residual.class);
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
      params.put("createdBy", currentUser.trueUserId());
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

  public void insertUser(Long planId, PlanUser user) {
    final Date newStartDate = user.getStartDate();

    Map<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("userId", user.getUserId());
    params.put("startDate", newStartDate);
    params.put("endDate", user.getEndDate());

    if (user.getId() != null) {
      params.put("id", user.getId());
      sqlCache.updateBySql(ResidualQuery.updatePlanUser, params);
    } else {
      sqlCache.updateBySql(ResidualQuery.insertPlanEndDate, params);
      sqlCache.updateBySql(ResidualQuery.insertPlanUser, params);
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
    params.put("approvedBy", securityService.getCurrentUser().getId());
    params.put("statusId", CommissionPlanStatus.ACTIVE.getId());

    sqlCache.updateBySql(ResidualQuery.approvePlan, params);
  }

  public String insertAllocation(Long planId, ResidualPlanAllocation rpa) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("name", rpa.getName());
    params.put("level", rpa.getLevel());
    params.put("total", rpa.getTotal());
    params.put("createdById", currentUser.trueUserId());
    params.put("nbrFdcLower", rpa.getNbrFdcLower());
    params.put("nbrFdcUpper", rpa.getNbrFdcUpper());

    Long id = sqlCache.updateBySqlReturningId(ResidualQuery.insertAllocation, params, "id").longValue();
    return getResidualPlanAllocation(id);
  }

  public void updateAllocation(Long planId, ResidualPlanAllocation rpa) {
    Map<String, Object> params = new HashMap<>();
    params.put("name", rpa.getName());
    params.put("level", rpa.getLevel());
    params.put("total", rpa.getTotal());
    params.put("nbrFdcLower", rpa.getNbrFdcLower());
    params.put("nbrFdcUpper", rpa.getNbrFdcUpper());
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
        .get(
            ResidualQuery.getResidualPlanAllocation, params, new SingleColumnRowMapper<>(String.class))
        .orElse("{}");
  }

  public Optional<Long> clonePlan(Long id, ResidualPlan residualPlan) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", id);
    params.put("startDate", residualPlan.getStartDate());
    params.put("createdBy", securityService.getCurrentUser().trueUserId());

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
}
