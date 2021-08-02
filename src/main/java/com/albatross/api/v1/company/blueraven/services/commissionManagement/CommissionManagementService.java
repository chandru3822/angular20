package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.CommissionPlanStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.*;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Sets;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class CommissionManagementService {

    private final SqlCache sqlCache;
    private final DataSource dataSource;
    private final SecurityService securityService;
    private final PayrollService payroll;
    private final ObjectMapper om;

    @Data
    public static class MilestoneType {
        private Long id, displayOrder;
        private String milestoneType;
    }

    public String updateCommissionPlan(CommissionPlan commissionPlan) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("name", commissionPlan.getName());
        params.put("description", commissionPlan.getDescription());
        params.put("total", commissionPlan.getTotal());
        params.put("positionId", commissionPlan.getPositionId());

        User currentUser = securityService.getCurrentUser();
        params.put("userId", currentUser.getId());

        String key = "commissionPlan.create";

        if (commissionPlan.getId() != null) {
            key = "commissionPlan.update";
            params.put("id", commissionPlan.getId());
        }

        long planId = sqlCache.updateReturningId(key, params, "id").longValue();

        return getCommissionPlanDetails(planId);
    }

    public List<MilestoneType> findActiveMilestones() {
        return sqlCache.query("commissionManagement.findActiveMilestones", Collections.emptyMap(), MilestoneType.class);
    }

    public List<MilestoneType> findAvailableMilestones(Long planId, Long positionId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        String sql = positionId == 4 ? "commissionManagement.findAvailableMilestonesForSetters" : "commissionManagement.findAvailableMilestonesForClosers";
        return sqlCache.query(sql, params, MilestoneType.class);
    }

    public List<CommissionPlan> getCommissionPlans(Long positionId) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("positionId", positionId);
      return sqlCache.query("commissionManagement.getCommissionPlans", params, CommissionPlan.class);
    }

    public String findUserForCommissions(String search, String positions, Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("search", search + "%");
        params.put("positions", positions);
        params.put("planId", planId);

        List<String> query = sqlCache.query("commissionManagement.findUsers", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? "[]" : query.get(0);
    }

    public List<Source> getAvailableSources(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);

        return sqlCache.query("commissionManagement.getAvailableSources", params, Source.class);
    }

    public List<ClosersPlan> getClosers() {
        List<ClosersPlan> closers = sqlCache.query("commissionManagement.getClosers", Collections.emptyMap(), new ClosersPlanMapper<>(ClosersPlan.class, om));
        List<Long> userIds = closers.stream().map(ClosersPlan::getUserId).collect(Collectors.toList());
        Set<Long> usersWithPlanGaps = getUsersWithPlanGaps(userIds);
        for (ClosersPlan closer : closers) {
            boolean hasCommissionPlanGap = usersWithPlanGaps.contains(closer.getUserId());
            closer.setHasCommissionPlanGap(hasCommissionPlanGap);
        }
        return closers;
    }

  public List<ClosersPlan> getSetters() {
    List<ClosersPlan> closers = sqlCache.query("commissionManagement.getSetters", Collections.emptyMap(), new ClosersPlanMapper<>(ClosersPlan.class, om));
    List<Long> userIds = closers.stream().map(ClosersPlan::getUserId).collect(Collectors.toList());
    Set<Long> usersWithPlanGaps = getUsersWithPlanGaps(userIds);
    for (ClosersPlan closer : closers) {
      boolean hasCommissionPlanGap = usersWithPlanGaps.contains(closer.getUserId());
      closer.setHasCommissionPlanGap(hasCommissionPlanGap);
    }
    return closers;
  }

    public List<Payroll> customerSearch(Long userId, String query) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("searchQuery", query);
        return sqlCache.query("commissionManagement.customerSearch", params, Payroll.class);
    }

    public Optional<Long> clonePlan(Long id, CommissionPlan commissionPlan)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException,
                   PlanStartDateBeforeHireDate {
        boolean isBackdatedPlan = validateBackdatedPlan(commissionPlan.getStartDate(), commissionPlan.getBackdateApprovalCreds(), commissionPlan.getPositionId());

        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);
        params.put("startDate", commissionPlan.getStartDate());
        params.put("positionId", commissionPlan.getPositionId());
        params.put("createdBy", securityService.getCurrentUser().getId());

        try (Connection connection = dataSource.getConnection()) {

            List<Long> users = commissionPlan.getUsers();
            if (users != null && !users.isEmpty()) {
                Array usersArray = connection.createArrayOf("int", users.toArray());
                params.put("users", usersArray);
            } else {
                params.put("users", null);

            }

        } catch (SQLException e) {
            log.error("COMMISSION: sql exception {}", e.getMessage());
            e.printStackTrace();
        }

        Optional<Long> clonedId = sqlCache.get("commissionPlan.clone", params, new SingleColumnRowMapper<>(Long.class));
        if (isBackdatedPlan && clonedId.isPresent()) {
            params.put("planId", clonedId.get());
            params.put("note", String.format("Backdated start date approved by %s",
                    commissionPlan.getBackdateApprovalCreds().getUsername()));
            sqlCache.update("commissionPlan.appendNoteToPlan", params);
        }
        return clonedId;
    }

    public String getCommissionPlanDetails(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);

        Optional<String> result = sqlCache.get("commissionManagement.getCommissionPlanDetails", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("{}");
    }

    public String getPlans(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);

        Optional<String> users = sqlCache.get("commissionManagement.getPlans", params, new SingleColumnRowMapper<>(String.class));
        return users.orElse("[]");
    }

    public String getCommissionPlanUsers(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", id);

        Optional<String> users = sqlCache.get("commissionManagement.getCommissionPlanUsers", params, new SingleColumnRowMapper<>(String.class));
        return users.orElse("[]");
    }

    public String getCommissionPlanUserHistory(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        List<String> query = sqlCache.query("commissionPlan.getCommissionPlanUserHistory", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? "[]" : query.get(0);
    }

    public void approvePlan(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("approvedBy", securityService.getCurrentUser().getId());
        params.put("statusId", CommissionPlanStatus.ACTIVE.getId());

        sqlCache.update("commissionPlan.approve", params);
    }

    public void updatePlanUser(Long planId, PlanUser planUser) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", planUser.getUserId());
        params.put("note", planUser.getNote());
        params.put("endDate", planUser.getEndDate());

        sqlCache.update("commissionPlan.updatePlanUser", params);
    }

    public void inactivatePlan(Long planId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("updatedBy", securityService.getCurrentUser().getId());
        params.put("statusId", CommissionPlanStatus.INACTIVE.getId());

        sqlCache.update("commissionPlan.inactivate", params);
    }

    public String getCloserDetails(Long userId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);

        List<String> query = sqlCache.query("commissionManagement.getCloserDetails", params, new SingleColumnRowMapper<>(String.class));
        return query.isEmpty() ? null : query.get(0);
    }

    public String getCommissionPlanAllocationMilestone(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        Optional<String> result = sqlCache.get("commissionManagement.getCommissionPlanAllocationMilestone", params, new SingleColumnRowMapper<>(String.class));
        return result.orElse("{}");
    }


    public String saveMilestone(Long planId, Milestone milestone) {
        Map<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("allocation", milestone.getAllocation());
        params.put("milestoneTypeId", milestone.getMilestoneTypeId());
        params.put("min", milestone.getMin());
        params.put("max", milestone.getMax());

        Long id = sqlCache.updateReturningId("commissionManagement.saveMilestone", params, "id").longValue();
        return getCommissionPlanAllocationMilestone(id);
    }

    public void updateMilestone(Long planId, Milestone milestone) {
        Map<String, Object> params = new HashMap<>();
        params.put("allocation", milestone.getAllocation());
        params.put("id", milestone.getCommissionPlanAllocationId());
        params.put("min", milestone.getMin());
        params.put("max", milestone.getMax());

        sqlCache.update("commissionManagement.updateMilestone", params);
    }

    public List<Source> getSources() {
        return sqlCache.query("commissionManagement.getSources", Collections.emptyMap(), Source.class);
    }

    public Source getSource(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        Optional<Source> result = sqlCache.get("commissionManagement.getSource", params, Source.class);
        return result.orElse(null);
    }

    public Source saveSource(Long planId, Source source) {
        Map<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("sourceId", source.getSourceId());
        params.put("milestoneId", source.getMilestoneId());
        params.put("feeAmount", source.getFeeAmount());
        params.put("feeTypeId", source.getFeeTypeId());

        Long id = sqlCache.updateReturningId("commissionManagement.saveSource", params, "id").longValue();
        return getSource(id);
    }

//    public boolean validateBackdatedPlan(PlanUser user)
//            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
//        Date startDate = user.getStartDate();
//        BackdatedPlanApprovalCredentials approvalCreds = user.getApprovalCreds();
//        return validateBackdatedPlan(startDate, approvalCreds);
//    }

    public boolean validateBackdatedPlan(Date startDate, BackdatedPlanApprovalCredentials credentials, Long positionId)
            throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        // if no start date is provided, then it doesn't make sense to say the clone is backdated
        if (startDate == null)
            return false;

        final boolean IS_BACKDATED_PLAN = true;

        List<Payroll> approvedPayrolls = payroll.getApprovedPayrolls(positionId);
        if (approvedPayrolls.size() > 0) {
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
        }
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
        //todo figure out user roles
//        List<UserRoleDO> roles = securityService.getUserRoles(user.getId());
//        if (roles == null)
//            return false;
//        return roles.stream()
//                .map(UserRoleDO::getRoleName)
//                .anyMatch("Executive"::equalsIgnoreCase);
        return false;
    }

    public void insertUser(Long planId, PlanUser user, Long positionId) throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
        final BackdatedPlanApprovalCredentials approvalCreds = user.getApprovalCreds();
        final Date newStartDate = user.getStartDate();
        boolean isBackdatedPlan = newStartDate != null
                                  && startDateChanged(user)
                                  && validateBackdatedPlan(newStartDate, approvalCreds, positionId);

        Map<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("userId", user.getUserId());
        params.put("startDate", newStartDate);
        params.put("endDate", user.getEndDate());

        if (user.getId() != null) {
            params.put("id", user.getId());
            sqlCache.update("commissionManagement.updateUser", params);
        } else {

            sqlCache.update("commissionManagement.insertEndDate", params);
            sqlCache.update("commissionManagement.insertUser", params);
        }

        if (isBackdatedPlan) {
            params.put("note", "backdated plan entry approved by "
                    + user.getApprovalCreds().getUsername());
            sqlCache.update("commissionPlan.appendNote", params);
        }
    }

    private boolean startDateChanged(PlanUser user) {
        if (user.getId() == null)
            return true;  // no existing entry in database? then start is new

        final Optional<UserDateRange> existingDateRange = sqlCache.get("commissionPlan.getUserDateRange",
                ImmutableMap.of("rowId", user.getId(),
                                "userId", user.getUserId()),
                UserDateRange.class);
        final LocalDate newStartDate = user.getStartDate()
                                           .toInstant()
                                           .atZone(ZoneOffset.UTC)
                                           .toLocalDate();
        final Optional<LocalDate> existingStartDate = existingDateRange.map(UserDateRange::getStartDate);
        return existingDateRange.isPresent()
                && !newStartDate.equals(existingStartDate);
    }

    public Source updateSource(Long planId, Source source) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", source.getId());
        params.put("feeAmount", source.getFeeAmount());
        params.put("feeTypeId", source.getFeeTypeId());
        params.put("milestoneId", source.getMilestoneId());

        sqlCache.update("commissionManagement.updateSource", params);
        return getSource(source.getId());
    }

    public void removeSource(Long planId, Long sourceId) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", sourceId);
        sqlCache.update("commissionManagement.removeSource", params);
    }

    public void deletePlan(Long id) {
        Map<String, Object> params = new HashMap<>();
        params.put("planId", id);
        sqlCache.update("commissionManagement.deletePlan", params);
    }

    public void removeMilestone(Long planId, Long id) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        sqlCache.update("commissionManagement.removeMilestone", params);
    }

    public void deleteUser(Long planId, Long commissionPlanUserId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("planId", planId);
        params.put("commissionPlanUserId", commissionPlanUserId);
        sqlCache.update("commissionPlan.deleteUser", params);
    }

    public Set<Long> getUsersWithPlanGaps(List<Long> userIds) {
        Map<String, Object> params = ImmutableMap.of("userIds", userIds);
        List<UserDateRange> closerDates = sqlCache.query("commissions.getUserDatesAsCloser",
                params, UserDateRange.class);

        // Make sets of all days the users have been closers...
        Map<Long, Set<LocalDate>> allUsersDatesNotCoveredByPlan = new HashMap<>();
        for (UserDateRange closer : closerDates)
            if (closer.getNumDaysInRange() > 0)
                allUsersDatesNotCoveredByPlan.merge(closer.getUserId(), closer.getDateRange(), Sets::union);

        // Now remove from those sets the days covered by plans
        List<UserDateRange> commissionPlanDates = sqlCache.query("commissions.getUserDatesOnCommissionPlans",
                params, UserDateRange.class);

        for (UserDateRange plan : commissionPlanDates) {
            if (allUsersDatesNotCoveredByPlan.containsKey(plan.getUserId())) {
                Set<LocalDate> datesAsCloser = allUsersDatesNotCoveredByPlan.get(plan.getUserId()),
                               datesNotCoveredByPlan = Sets.difference(datesAsCloser, plan.getDateRange());
                if (datesNotCoveredByPlan.isEmpty())
                    allUsersDatesNotCoveredByPlan.remove(plan.getUserId());
                else
                    allUsersDatesNotCoveredByPlan.put(plan.getUserId(), datesNotCoveredByPlan);
            }
        }

        return allUsersDatesNotCoveredByPlan.keySet();
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

    @EqualsAndHashCode(callSuper = true)
    @Data
    public static class PlanStartDateBeforeHireDate extends Exception {
        private final Date startDate;
        private final List<User> problematicUsers;

        public PlanStartDateBeforeHireDate(Date startDate, List<User> problematicUsers) {
            super("Some users' plan start dates are before their hire dates");
            this.startDate = startDate;
            this.problematicUsers = problematicUsers;
        }
    }

    public static class ClosersPlanMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper objectMapper;

        public ClosersPlanMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
            super(mappedClass);
            this.objectMapper = objectMapper;
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<ReceivingPlan>> receivingPlanRef = new TypeReference<>() {};
            bw.registerCustomEditor(List.class, "receivingPlans",
                new JsonCollectionDeserializer(receivingPlanRef, objectMapper));
        }
    }
}
