package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.CommissionPlanStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.PlanUser;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Residual;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.ResidualPlan;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.ResidualPlanAllocation;
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
        String key = "residual.insert";

        if (residual.getId() == null) {
            params.put("createdBy", currentUser.getId());
        } else {
            key = "residual.update";
            params.put("updatedBy", currentUser.getId());
            params.put("id", residual.getId());
        }

        long id = sqlCache.updateReturningId(key, params, "id").longValue();

        return getResidual(id);
    }

    public List<Residual> getResiduals() {
        List<Residual> results = sqlCache.query("residual.getAll", Collections.emptyMap(), Residual.class);
        return results;
    }

    public Residual getResidual(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);
        Optional<Residual> result = sqlCache.get("residual.getOne", params, Residual.class);
        return result.orElse(null);
    }

    public void deleteResidual(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);
        sqlCache.get("residual.delete", params, Residual.class);
    }

    public List<ResidualPlan> getResidualPlans() {
        List<ResidualPlan> results = sqlCache.query("residual.getAllPlans", Collections.emptyMap(), ResidualPlan.class);
        return results;
    }

    public String updateResidualPlan(ResidualPlan residualPlan) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("name", residualPlan.getName());
        params.put("description", residualPlan.getDescription());

        User currentUser = securityService.getCurrentUser();
        String key = "residual.createPlan";

        if (residualPlan.getId() == null) {
            params.put("createdBy", currentUser.getId());
        } else {
            key = "residual.updatePlan";
            params.put("updatedBy", currentUser.getId());
            params.put("id", residualPlan.getId());
        }

        long planId = sqlCache.updateReturningId(key, params, "id").longValue();

        return getResidualPlanDetails(planId);
    }

    public String getResidualPlanDetails(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);

        Optional<String> result = sqlCache.get("residual.getResidualPlanDetails", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("{}");
    }

    public String getResidualPlanUserHistory(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        List<String> query = sqlCache.query("residual.getResidualPlanUserHistory", params, new SingleColumnRowMapper<>(String.class));
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
            sqlCache.update("residual.updatePlanUser", params);
        } else {
            sqlCache.update("residual.insertPlanEndDate", params);
            sqlCache.update("residual.insertPlanUser", params);
        }
    }

    public String getResidualPlanUsers(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);

        Optional<String> users = sqlCache.get("residual.getResidualPlanUsers", params, new SingleColumnRowMapper<>(String.class));
        return users.orElse("[]");
    }

    public void deletePlan(Long id) {
        Map<String, Object> params = new HashMap<>();
        params.put("planId", id);
        sqlCache.update("residual.deletePlan", params);
    }

    public void approvePlan(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("approvedBy", securityService.getCurrentUser().getId());
        params.put("statusId", CommissionPlanStatus.ACTIVE.getId());

        sqlCache.update("residual.approvePlan", params);
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

        Long id = sqlCache.updateReturningId("residual.insertAllocation", params, "id").longValue();
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

        sqlCache.update("residual.updateAllocation", params);
    }

    public void removeAllocation(Long planId, Long id) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        sqlCache.update("residual.removeAllocation", params);
    }

    public String getResidualPlanAllocation(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        Optional<String> result = sqlCache.get("residual.getResidualPlanAllocation", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("{}");
    }

    public Optional<Long> clonePlan(Long id, ResidualPlan residualPlan) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);
        params.put("startDate", residualPlan.getStartDate());
        params.put("createdBy", securityService.getCurrentUser().getId());

        try (Connection connection = dataSource.getConnection()) {

            List<Long> users = residualPlan.getUsers();
            if (users != null && !users.isEmpty()) {
                Array usersArray = connection.createArrayOf("int", users.toArray());
                params.put("users", usersArray);
            } else {
                params.put("users", null);

            }

        } catch (SQLException e) {
            log.error("COMMISSION: residual sql exception {}", e.getMessage());
            e.printStackTrace();
        }

        Optional<Long> clonedId = sqlCache.get("residual.clonePlan", params, new SingleColumnRowMapper<>(Long.class));

        return clonedId;
    }

}
