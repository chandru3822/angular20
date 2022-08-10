package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.OverridePlanStatus;
import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.BackdatedPlanApprovalCredentials;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.OverridePlanAllocation;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Payroll;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.PlanUser;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.SqlArrayService;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Array;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OverridePlanService {

    private final SqlCache sqlCache;
    private final SecurityService securityService;
    private final PayrollService payroll;
    private final ObjectMapper om;
    private final SqlArrayService sqlArrayService;

    @Data
    public static class OverrideReceivingUser {
        private Long userId;
        private Double m1Allocation, m2Allocation;
        private String note;
    }

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class OverrideAssignedUser {
        private Long id, userId;
        private Date startDate, endDate;
        private BackdatedPlanApprovalCredentials approvalCreds;
    }

    @Data
    public static class OverridePlan {
        private Long id, positionId;
        private Integer statusId;
        private Double total = 0.0;
        private String name, description;
        private List<Long> receivingUsers, assignedUsers;
        private List<CustomFieldGroup> customFieldGroups;
    }

    @Data
    public static class OverrideMilestone {
        private Long overridePlanAllocationId, milestoneTypeId;
        private Double allocation;
    }

    @Data
    public static class CloneOverridePlan extends OverridePlan {
        private Date startDate, endDate;
        private Long userId;
        private BackdatedPlanApprovalCredentials backdateApprovalCreds;
    }

    public void updatePlanUser(Long planId, PlanUser planUser) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", planId);
        params.put("userId", planUser.getUserId());
        params.put("note", planUser.getNote());
        params.put("endDate", planUser.getEndDate());

        sqlCache.update("overridePlan.updatePlanUser", params);
    }

    public String updateOverridePlan(OverridePlan overridePlan) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("name", overridePlan.getName());
        params.put("description", overridePlan.getDescription());
        params.put("positionId", overridePlan.getPositionId());
        params.put("total", overridePlan.getTotal());

        User currentUser = securityService.getCurrentUser();
        String key = "overridePlan.create";

        if (overridePlan.getId() == null) {
            params.put("createdBy", currentUser.trueUserId());
        } else {
            key = "overridePlan.update";
            params.put("updatedBy", currentUser.trueUserId());
            params.put("id", overridePlan.getId());
        }

        long planId = sqlCache.updateReturningId(key, params, "id").longValue();

        return findOverridePlanDetail(planId);
    }

    public String findOverridePlans(Long positionId, Boolean excludeInactive) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("excludeInactive", excludeInactive);
        params.put("positionId", positionId);
        List<String> query = sqlCache.query("overridePlan.listAll", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? "[]" : query.get(0);
    }

  public void saveProjectToPlan(Long planId, Long projectId) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("projectId", projectId);

    //see if project is valid.  this is the smallest pre-existing query even though it returns the company id
    Optional<Long> companyId = sqlCache.queryForObjectOptional("project.getCompanyId", params, Long.class);

    //see if project is already assigned
    Optional<Long> commissionPlanId = sqlCache.queryForObjectOptional("overridePlan.checkProjectAssignment", params, Long.class);

    if(companyId.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Project ID", new Exception());
    } else if(commissionPlanId.isPresent()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project is already assigned to a plan.", new Exception());
    } else {
      sqlCache.update("overridePlan.assignProject", params);
    }
  }

    public String findOverridePlanDetail(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        List<String> query = sqlCache.query("overridePlan.findById", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? null : query.get(0);
    }

    public String findUserForOverrides(String search, Long positionId, Long planId, Boolean isReceiving) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("search", search + "%");
        params.put("positionId", positionId);
        params.put("planId", planId);
        params.put("isReceiving", isReceiving);

        List<String> query = sqlCache.query("overridePlan.findUsers", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? "[]" : query.get(0);
    }

    @Transactional
    public Optional<Long> cloneOverridePlan(Long id, CloneOverridePlan overridePlan, Long userId) throws SQLException, BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        boolean isBackdated = validateBackdatedPlan(overridePlan.getStartDate(), overridePlan.getBackdateApprovalCreds(), overridePlan.getPositionId());

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);
        params.put("startDate", overridePlan.getStartDate());
        params.put("createdBy", securityService.getCurrentUser().trueUserId());
        params.put("userId", userId);
        params.put("positionId", overridePlan.getPositionId());

        Array assignedUsersArray = sqlArrayService.createSqlArrayOfType("int", overridePlan.getAssignedUsers());
        params.put("assignedUsers", assignedUsersArray);

        Array receivingUsersArray = sqlArrayService.createSqlArrayOfType("int", overridePlan.getReceivingUsers());
        params.put("receivingUsers", receivingUsersArray);

        Optional<Long> clonedId = sqlCache.get("overridePlan.clone", params, new SingleColumnRowMapper<>(Long.class));
        if (isBackdated && clonedId.isPresent()) {
            List<OverrideNoteData> objs = overridePlan.getAssignedUsers().stream()
                    .map(uid -> new OverrideNoteData(overridePlan.getStartDate(),
                            "Backdated override plan approved by " + overridePlan.getBackdateApprovalCreds().getUsername(),
                            uid, clonedId.get()))
                    .collect(Collectors.toList());
            sqlCache.updateBatch("overridePlan.appendAssignedNote", objs);
        }

        return clonedId;
    }

    @Data
    private static class OverrideNoteData {
        private final Date startDate;
        private final String note;
        private final Long userId, planId;
    }

    public String getPlanReceivingUsers(Long id){
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);

        Optional<String> users = sqlCache.get("overridePlan.getReceivingUsers", params, new SingleColumnRowMapper<>(String.class));
        return users.orElse("[]");
    }

    public String getReceivingUser(Long planId, Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", userId);

        Optional<String> result = sqlCache.get("overridePlan.getReceivingUser", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("[]");
    }

    public String addReceivingUser(Long planId, OverrideReceivingUser receivingUser) {

        OverridePlanStatus planStatus = getPlanStatus(planId);
        if (OverridePlanStatus.ACTIVE.equals(planStatus)) {
            return null;
        }

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", receivingUser.getUserId());
        params.put("m1Allocation", receivingUser.getM1Allocation());
        params.put("m2Allocation", receivingUser.getM2Allocation());
        params.put("updatedBy", securityService.getCurrentUser().trueUserId());

        sqlCache.updateReturningId("overridePlan.addReceivingUser", params, "id").longValue();

        return getReceivingUser(planId, receivingUser.getUserId());
    }

    public void updateReceivingUser(Long planId, OverrideReceivingUser receivingUser) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", receivingUser.getUserId());
        params.put("m1", receivingUser.getM1Allocation());
        params.put("m2", receivingUser.getM2Allocation());
        params.put("updatedBy", securityService.getCurrentUser().trueUserId());
        params.put("note", receivingUser.getNote());

        sqlCache.update("overridePlan.updateReceivingUser", params);
    }

    public void deleteReceivingUser(Long planId, Long userId) {

        OverridePlanStatus planStatus = getPlanStatus(planId);
        if (OverridePlanStatus.ACTIVE.equals(planStatus)) {
            return;
        }

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", userId);
        params.put("updatedBy", securityService.getCurrentUser().trueUserId());

        sqlCache.update("overridePlan.deleteReceivingUser", params);
    }

    public String getAssignedUserDetail(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);

        List<String> query = sqlCache.query("overridePlan.findUserHistory", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? null : query.get(0);
    }

    public String getOverrides(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);

        Optional<String> result = sqlCache.get("commissionManagement.getOverrides", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("[]");
    }

    public String getAssignedUser(Long planId, Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", userId);

        Optional<String> result = sqlCache.get("overridePlan.getAssignedUser", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("[]");
    }

    @Transactional
    public String updateAssignedUser(Long planId, OverrideAssignedUser assignedUser, Long positionId, Boolean addUserToPlan)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        boolean isBackdatedPlan = validateBackdatedPlan(assignedUser, positionId);

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", assignedUser.getUserId());
        params.put("startDate", assignedUser.getStartDate());
        params.put("endDate", assignedUser.getEndDate());
        params.put("updatedBy", securityService.getCurrentUser().trueUserId());

//        this will set the end date of any active plans
        if (assignedUser.getId() != null) {
            params.put("id", assignedUser.getId());
            sqlCache.update("overridePlan.updateAssignedUser", params);
        } else {
            sqlCache.update("overridePlan.setEndDateAssignedUser", params);
            sqlCache.update("overridePlan.insertAssignedUser", params, "id");
        }

        if (isBackdatedPlan) {
            params.put("note", "backdated plan entry approved by "
                    + assignedUser.getApprovalCreds().getUsername());
            sqlCache.update("overridePlan.appendAssignedNote", params);
        }

      //this same endpoint is used when adding a user to a plan or when adding a plan to a user. and need to return different when adding to plan
      //if existing just return the one user, otherwise return the full updated list
      if(assignedUser.getId() != null) {
        return getAssignedUser(planId, assignedUser.getUserId());
      } else if(null != addUserToPlan && addUserToPlan) {
        return getPlanAssignedUsers(planId);
      } else {
        return getOverrides(assignedUser.getUserId());
      }
    }

    public String getPlanAssignedUsers(Long id){
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);

        Optional<String> users = sqlCache.get("overridePlan.getAssignedUsers", params, new SingleColumnRowMapper<>(String.class));
        return users.orElse("[]");
    }

    public void deleteAssignedUser(Long planId, Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", userId);
        params.put("updatedBy", securityService.getCurrentUser().trueUserId());

        sqlCache.update("overridePlan.deleteAssignedUser", params);
    }

    public void approvePlan(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("approvedBy", securityService.getCurrentUser().trueUserId());
        params.put("statusId", OverridePlanStatus.ACTIVE.getId());

        sqlCache.update("overridePlan.approve", params);
    }

    public void inactivatePlan(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("updatedBy", securityService.getCurrentUser().trueUserId());
        params.put("statusId", OverridePlanStatus.INACTIVE.getId());

        sqlCache.update("overridePlan.inactivate", params);
    }

    //    TODO: we need some checks around this
    public void deletePlan(Long id) {
        Map<String, Object> params = new HashMap<>();
        params.put("planId", id);
        sqlCache.update("overridePlan.deletePlan", params);
    }

    public Collection<OverridePlanAllocation> getAllocationDetails() {
        return sqlCache.query("overridePlan.export",
                Collections.emptyMap(),
                new RowMapper<OverridePlanAllocation>() {
                    @Override
                    public OverridePlanAllocation mapRow(ResultSet rs, int rowNum) throws SQLException {
                        try {
                            OverridePlanAllocation o = new OverridePlanAllocation();
                            o.setName(rs.getString("name"));
                            o.setCloser(rs.getString("closer"));
                            o.setTotal(rs.getBigDecimal("total"));
                            o.setStatusType(rs.getString("status_type"));

                            java.sql.Date startDate = rs.getDate("start_date");
                            o.setStartDate(startDate != null ? startDate.toLocalDate() : null);
                            java.sql.Date endDate = rs.getDate("end_date");
                            o.setEndDate(endDate != null ? endDate.toLocalDate() : null);

                            o.setMilestone1Allocation(rs.getBigDecimal("milestone_1_allocation"));
                            o.setMilestone2Allocation(rs.getBigDecimal("milestone_2_allocation"));
                            o.setReceivingUsers(om.readValue(rs.getString("receiving_users"),
                                    new TypeReference<Map<String, BigDecimal>>() {}));
                            return o;
                        } catch (IOException e) {
                            throw new SQLException(e);
                        }
                    }
                });
    }

    private OverridePlanStatus getPlanStatus(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", planId);

        Optional<OverridePlanStatus> status = sqlCache.get("overridePlan.getPlanStatus", params, (resultSet, i) -> {
            String statusString = resultSet.getString("status_type");
            return OverridePlanStatus.valueOf(statusString);
        });

        return status.orElse(OverridePlanStatus.UNKNOWN);
    }

    private boolean validateBackdatedPlan(OverrideAssignedUser user, Long positionId)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        Date startDate = user.getStartDate();
        return validateBackdatedPlan(startDate, user.getApprovalCreds(), positionId);
    }

    private boolean validateBackdatedPlan(Date startDate, BackdatedPlanApprovalCredentials credentials, Long positionId)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        final boolean IS_BACKDATED_PLAN = true;

        // if no start date is provided, then it doesn't make sense to check user hire dates
        if (startDate == null)
            return false;

        List<Payroll> approvedPayrolls = payroll.getApprovedPayrolls(positionId);
        if(approvedPayrolls.size() > 0) {
          Payroll mostRecent = approvedPayrolls.get(0);
          if (startDate.before(mostRecent.getPeriodEnd())) { // "if this change is a backdated change..."
              if (credentials == null) // throw exception if not credentials are provided
                  throw new BackdatedPlanApprovalRequiredException(startDate,
                          mostRecent.getId(),
                          mostRecent.getPeriodEnd());
              if (!areValidBackdatedPlanApprovalCredentials(credentials)) // throw exception if credentials are inadequate
                  throw new BackdatedPlanApprovalBadCredentialsException();
              // if we get here, we're all good! backdated change included appropriate approval credentials
              return IS_BACKDATED_PLAN;
          }
        }
        // not a backdated change, so nothing to validate
        return !IS_BACKDATED_PLAN;
    }

    private boolean areValidBackdatedPlanApprovalCredentials(BackdatedPlanApprovalCredentials creds) {
        Boolean isApproved = false;
        try {
            String username = creds.getUsername(),
                    password = creds.getPassword();
            User approvingUser = securityService.getUser(username);
            isApproved = userExists(approvingUser)
                    && validCreds(approvingUser, password)
                    && isExecutive(approvingUser);

        } catch (Exception e) {
            isApproved = false;
        }

        return isApproved;
    }

    private boolean userExists(User user) {
        return user != null;
    }

    private boolean validCreds(User user, String password) {
        try {
            return securityService.validatePassword(user, password);
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isExecutive(User user) {
        //todo: figure out user roles
//        List<UserRoleDO> roles = securityService.getUserRoles(user.getId());
//        if (roles == null)
//            return false;
//        return roles.stream()
//                .map(UserRoleDO::getRoleName)
//                .anyMatch("Executive"::equalsIgnoreCase);
        return false;
    }

    @Getter
    public static class BackdatedPlanApprovalRequiredException extends Exception {
        private final Date userStartDate;
        private final Long payrollId;
        private final Date payrollEndDate;

        public BackdatedPlanApprovalRequiredException(Date userStartDate, Long payrollId, Date payrollEndDate) {
            super(String.format("Provided user start date (%s) is before most"
                    + " recent payroll's end date (payroll id %d; end date %s);"
                    + " executive approval required", userStartDate, payrollId, payrollEndDate));
            this.userStartDate = userStartDate;
            this.payrollId = payrollId;
            this.payrollEndDate = payrollEndDate;
        }
    }

    public static class BackdatedPlanApprovalBadCredentialsException extends Exception {
        public BackdatedPlanApprovalBadCredentialsException () {
            super("Invalid credentials supplied to approve backdated plan.");
        }
    }
}
