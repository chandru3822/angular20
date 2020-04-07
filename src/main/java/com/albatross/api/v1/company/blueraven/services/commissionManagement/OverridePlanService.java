package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.OverridePlanStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.BackdatedPlanApprovalCredentials;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.OverridePlanAllocation;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Payroll;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.PlanUser;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Array;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OverridePlanService {

    private final SqlCache sqlCache;
    private final DataSource dataSource;
    private final SecurityService securityService;
    private final PayrollService payroll;
    private final ObjectMapper om;


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

    public String updateOverridePlan(Long id, OverridePlan overridePlan) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("name", overridePlan.getName());
        params.put("description", overridePlan.getDescription());
        params.put("positionId", overridePlan.getPositionId());
        params.put("total", overridePlan.getTotal());

        User currentUser = securityService.getCurrentUser();
        String key = "overridePlan.create";

        if (id == null) {
            params.put("createdBy", currentUser.getId());

        } else {
            key = "overridePlan.update";
            params.put("updatedBy", currentUser.getId());
            params.put("id", id);
        }

        long planId = sqlCache.updateReturningId(key, params, "id").longValue();

        return findOverridePlanDetail(planId);
    }

    public String findOverridePlans() {
        List<String> query = sqlCache.query("overridePlan.listAll", new HashMap<>(), new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? "[]" : query.get(0);
    }

    public String findOverridePlanDetail(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        List<String> query = sqlCache.query("overridePlan.findById", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? null : query.get(0);
    }

    public String findUserForOverrides(String search, Long positionId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("search", search + "%");
        params.put("positionId", positionId);

        List<String> query = sqlCache.query("overridePlan.findUsers", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? "[]" : query.get(0);
    }

    @Transactional
    public Optional<Long> cloneOverridePlan(Long id, CloneOverridePlan overridePlan, Long userId) throws SQLException, BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        boolean isBackdated = validateBackdatedPlan(overridePlan.getStartDate(), overridePlan.getBackdateApprovalCreds());

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);
        params.put("startDate", overridePlan.getStartDate());
        params.put("createdBy", securityService.getCurrentUser().getId());
        params.put("userId", userId);

        Array assignedUsersArray = createSqlArrayOfType("int", overridePlan.getAssignedUsers());
        params.put("assignedUsers", assignedUsersArray);

        Array receivingUsersArray = createSqlArrayOfType("int", overridePlan.getReceivingUsers());
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
        params.put("updatedBy", securityService.getCurrentUser().getId());

        sqlCache.updateReturningId("overridePlan.addReceivingUser", params, "id").longValue();

        return getReceivingUser(planId, receivingUser.getUserId());
    }

    public void updateReceivingUser(Long planId, OverrideReceivingUser receivingUser) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", receivingUser.getUserId());
        params.put("updatedBy", securityService.getCurrentUser().getId());
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
        params.put("updatedBy", securityService.getCurrentUser().getId());

        sqlCache.update("overridePlan.deleteReceivingUser", params);
    }

    public String getAssignedUserDetail(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);

        List<String> query = sqlCache.query("overridePlan.findUserHistory", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? null : query.get(0);
    }

    public String getAssignedUser(Long planId, Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", userId);

        Optional<String> result = sqlCache.get("overridePlan.getAssignedUser", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("[]");
    }

    @Transactional
    public String updateAssignedUser(Long planId, OverrideAssignedUser assignedUser)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        boolean isBackdatedPlan = validateBackdatedPlan(assignedUser);

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", assignedUser.getUserId());
        params.put("startDate", assignedUser.getStartDate());
        params.put("endDate", assignedUser.getEndDate());
        params.put("updatedBy", securityService.getCurrentUser().getId());

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

        return getAssignedUser(planId, assignedUser.getUserId());
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
        params.put("updatedBy", securityService.getCurrentUser().getId());

        sqlCache.update("overridePlan.deleteAssignedUser", params);
    }

    public void approvePlan(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("approvedBy", securityService.getCurrentUser().getId());
        params.put("statusId", OverridePlanStatus.ACTIVE.getId());

        sqlCache.update("overridePlan.approve", params);
    }

    public void inactivatePlan(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("updatedBy", securityService.getCurrentUser().getId());
        params.put("statusId", OverridePlanStatus.INACTIVE.getId());

        sqlCache.update("overridePlan.inactivate", params);
    }

    //    TODO: we need some checks around this
    public void deletePlan(Long id) {
        Map<String, Object> params = new HashMap<>();
        params.put("planId", id);
        sqlCache.update("overridePlan.deletePlan", params);
    }

    public String updateMilestone(Long planId, OverrideMilestone milestone) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("milestoneTypeId", milestone.getMilestoneTypeId());
        params.put("allocation", milestone.getAllocation());
        params.put("updatedBy", securityService.getCurrentUser().getId());

        Long id;
        if(null != milestone.getOverridePlanAllocationId()) {
            id = milestone.getOverridePlanAllocationId();
            params.put("id", id);
            sqlCache.update("overridePlan.updateMilestone", params);
        } else {
            id = sqlCache.updateReturningId("overridePlan.insertMilestone", params, "id").longValue();
        }

        return getOverridePlanAllocationMilestone(id);
    }

    public String getOverridePlanAllocationMilestone(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        Optional<String> result = sqlCache.get("overridePlan.getOverridePlanAllocationMilestone", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("{}");
    }

    public void deleteMilestone(Long planId, Long overridePlanAllocationId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("overridePlanAllocationId", overridePlanAllocationId);
        params.put("updatedBy", securityService.getCurrentUser().getId());

        sqlCache.update("overridePlan.deleteMilestone", params);
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

    private Array createSqlArrayOfType(String typeName, List<?> array) throws SQLException {
        if (array != null && !array.isEmpty()) {
            try (Connection connection = dataSource.getConnection()) {
                return connection.createArrayOf(typeName, array.toArray());
            }
        }
        return null;
    }

    private boolean validateBackdatedPlan(OverrideAssignedUser user)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        Date startDate = user.getStartDate();
        return validateBackdatedPlan(startDate, user.getApprovalCreds());
    }

    private boolean validateBackdatedPlan(Date startDate, BackdatedPlanApprovalCredentials credentials)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        final boolean IS_BACKDATED_PLAN = true;

        // if no start date is provided, then it doesn't make sense to check user hire dates
        if (startDate == null)
            return false;

        List<Payroll> approvedPayrolls = payroll.getApprovedPayrolls();
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
