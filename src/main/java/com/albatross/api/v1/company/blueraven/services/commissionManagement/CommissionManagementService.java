package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.CommissionPlanStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.*;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.queries.CommissionManagementQuery;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.ProjectQuery;
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
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommissionManagementService {

  private final SqlCache sqlCache;
  private final DataSource dataSource;
  private final SecurityService securityService;
  private final PayrollService payroll;
  private final ObjectMapper om;

  public String updateCommissionPlan(CommissionPlan commissionPlan) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("name", commissionPlan.getName());
    params.put("description", commissionPlan.getDescription());
    params.put("total", commissionPlan.getTotal());
    params.put("positionId", commissionPlan.getPositionId());

    User currentUser = securityService.getCurrentUser();
    params.put("userId", currentUser.trueUserId());

    long planId;
    if (commissionPlan.getId() != null) {
      params.put("id", commissionPlan.getId());
      planId = sqlCache.updateBySqlReturningId(CommissionManagementQuery.update, params, "id").longValue();
    }
    else {
      planId = sqlCache.updateBySqlReturningId(CommissionManagementQuery.create, params, "id").longValue();
    }

    return getCommissionPlanDetails(planId);
  }

  public void saveProjectToPlan(Long planId, Long projectId) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("projectId", projectId);

    //see if project is valid.  this is the smallest pre-existing query even though it returns the company id
    Optional<Long> companyId = sqlCache.queryForObjectOptionalBySql(ProjectQuery.getCompanyId, params, Long.class);

    //see if project is already assigned
    Optional<Long> commissionPlanId = sqlCache.queryForObjectOptionalBySql(CommissionManagementQuery.checkProjectAssignment, params, Long.class);

    if(companyId.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Project ID", new Exception());
    } else if(commissionPlanId.isPresent()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Project is already assigned to a plan.", new Exception());
    } else {
      sqlCache.updateBySql(CommissionManagementQuery.assignProject, params);
    }


  }

  public List<MilestoneType> findActiveMilestones() {
    return sqlCache.queryBySql(
      CommissionManagementQuery.findActiveMilestones, Collections.emptyMap(), MilestoneType.class);
  }

  public List<MilestoneType> findAvailableMilestones(Long planId, Long positionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);

    if (positionId == 4) {
      return sqlCache.queryBySql(CommissionManagementQuery.findAvailableMilestonesForSetters, params, MilestoneType.class);
    }
    else {
      return sqlCache.queryBySql(CommissionManagementQuery.findAvailableMilestonesForClosers, params, MilestoneType.class);
    }
  }

  public List<CommissionPlan> getCommissionPlans(Long positionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("positionId", positionId);
    return sqlCache.queryBySql(CommissionManagementQuery.getCommissionPlans, params, CommissionPlan.class);
  }

  public String findUserForCommissions(String search, String positions, Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("search", search + "%");
    params.put("positions", positions);
    params.put("planId", planId);

    List<String> query =
        sqlCache.queryBySql(
          CommissionManagementQuery.findUsers, params, new SingleColumnRowMapper<>(String.class));
    return query.isEmpty() ? "[]" : query.get(0);
  }

  public List<Source> getAvailableSources(Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);

    return sqlCache.queryBySql(CommissionManagementQuery.getAvailableSources, params, Source.class);
  }

  public List<ClosersPlan> getClosers() {
    List<ClosersPlan> closers =
        sqlCache.queryBySql(
          CommissionManagementQuery.getClosers,
            Collections.emptyMap(),
            new ClosersPlanMapper<>(ClosersPlan.class, om));
    List<Long> userIds = closers.stream().map(ClosersPlan::getUserId).toList();
    Set<Long> usersWithPlanGaps = getUsersWithPlanGaps(userIds);
    for (ClosersPlan closer : closers) {
      boolean hasCommissionPlanGap = usersWithPlanGaps.contains(closer.getUserId());
      closer.setHasCommissionPlanGap(hasCommissionPlanGap);
    }
    return closers;
  }

  public List<ClosersPlan> getSetters() {
    List<ClosersPlan> closers =
        sqlCache.queryBySql(
          CommissionManagementQuery.getSetters,
            Collections.emptyMap(),
            new ClosersPlanMapper<>(ClosersPlan.class, om));
    List<Long> userIds = closers.stream().map(ClosersPlan::getUserId).toList();
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
    return sqlCache.queryBySql(CommissionManagementQuery.customerSearch, params, Payroll.class);
  }

  public Optional<Long> clonePlan(Long id, CommissionPlan commissionPlan)
      throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException,
          PlanStartDateBeforeHireDate {
    boolean isBackdatedPlan =
        validateBackdatedPlan(
            commissionPlan.getStartDate(),
            commissionPlan.getBackdateApprovalCreds(),
            commissionPlan.getPositionId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", id);
    params.put("startDate", commissionPlan.getStartDate());
    params.put("positionId", commissionPlan.getPositionId());
    params.put("createdBy", securityService.getCurrentUser().trueUserId());

    try (Connection connection = dataSource.getConnection()) {

      List<Long> users = commissionPlan.getUsers();
      if (users != null && !users.isEmpty()) {
        Array usersArray = connection.createArrayOf("int", users.toArray());
        params.put("users", usersArray);
      } else {
        params.put("users", null);
      }

    } catch (SQLException e) {
      log.error("COMMISSION: sql exception", e);
    }

    Optional<Long> clonedId =
        sqlCache.getBySql(CommissionManagementQuery.clone, params, new SingleColumnRowMapper<>(Long.class));
    if (isBackdatedPlan && clonedId.isPresent()) {
      params.put("planId", clonedId.get());
      params.put(
          "note",
          String.format(
              "Backdated start date approved by %s",
              commissionPlan.getBackdateApprovalCreds().getUsername()));
      sqlCache.updateBySql(CommissionManagementQuery.appendNoteToPlan, params);
    }
    return clonedId;
  }

  public String getCommissionPlanDetails(Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);

    Optional<String> result =
        sqlCache.getBySql(
          CommissionManagementQuery.getCommissionPlanDetails,
            params,
            new SingleColumnRowMapper<>(String.class));
    return result.orElse("{}");
  }

  public String getPlans(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    Optional<String> users =
        sqlCache.getBySql(
          CommissionManagementQuery.getPlans, params, new SingleColumnRowMapper<>(String.class));
    return users.orElse("[]");
  }

  public String getCommissionPlanUsers(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", id);

    Optional<String> users =
        sqlCache.getBySql(
            CommissionManagementQuery.getCommissionPlanUsers,
            params,
            new SingleColumnRowMapper<>(String.class));
    return users.orElse("[]");
  }

  public String getCommissionPlanUserHistory(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    List<String> query =
        sqlCache.queryBySql(
            CommissionManagementQuery.getCommissionPlanUserHistory,
            params,
            new SingleColumnRowMapper<>(String.class));
    return query.isEmpty() ? "[]" : query.get(0);
  }

  public void approvePlan(Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("approvedBy", securityService.getCurrentUser().trueUserId());
    params.put("statusId", CommissionPlanStatus.ACTIVE.getId());

    sqlCache.updateBySql(CommissionManagementQuery.approve, params);
  }

  public void updatePlanUser(Long planId, PlanUser planUser) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("userId", planUser.getUserId());
    params.put("note", planUser.getNote());
    params.put("endDate", planUser.getEndDate());

    sqlCache.updateBySql(CommissionManagementQuery.updatePlanUser, params);
  }

  public void inactivatePlan(Long planId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("updatedBy", securityService.getCurrentUser().trueUserId());
    params.put("statusId", CommissionPlanStatus.INACTIVE.getId());

    sqlCache.updateBySql(CommissionManagementQuery.inactivate, params);
  }

  public String getCloserDetails(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    List<String> query =
        sqlCache.queryBySql(
            CommissionManagementQuery.getCloserDetails,
            params,
            new SingleColumnRowMapper<>(String.class));
    return query.isEmpty() ? null : query.get(0);
  }

  public String getCommissionPlanAllocationMilestone(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<String> result =
        sqlCache.getBySql(
            CommissionManagementQuery.getCommissionPlanAllocationMilestone,
            params,
            new SingleColumnRowMapper<>(String.class));
    return result.orElse("{}");
  }

  public String saveMilestone(Long planId, Milestone milestone) {
    Map<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("allocation", milestone.getAllocation());
    params.put("milestoneTypeId", milestone.getMilestoneTypeId());
    params.put("min", milestone.getMin());
    params.put("max", milestone.getMax());

    Long id =
        sqlCache.updateBySqlReturningId(CommissionManagementQuery.saveMilestone, params, "id").longValue();
    return getCommissionPlanAllocationMilestone(id);
  }

  public void updateMilestone(Long planId, Milestone milestone) {
    Map<String, Object> params = new HashMap<>();
    params.put("allocation", milestone.getAllocation());
    params.put("id", milestone.getCommissionPlanAllocationId());
    params.put("min", milestone.getMin());
    params.put("max", milestone.getMax());

    sqlCache.updateBySql(CommissionManagementQuery.updateMilestone, params);
  }

  public List<Source> getSources() {
    return sqlCache.queryBySql(CommissionManagementQuery.getSources, Collections.emptyMap(), Source.class);
  }

  public Source getSource(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<Source> result = sqlCache.getBySql(CommissionManagementQuery.getSource, params, Source.class);
    return result.orElse(null);
  }

  public Source saveSource(Long planId, Source source) {
    Map<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("sourceId", source.getSourceId());
    params.put("milestoneId", source.getMilestoneId());
    params.put("feeAmount", source.getFeeAmount());
    params.put("feeTypeId", source.getFeeTypeId());

    Long id =
        sqlCache.updateBySqlReturningId(CommissionManagementQuery.saveSource, params, "id").longValue();
    return getSource(id);
  }

  public boolean validateBackdatedPlan(
      Date startDate, BackdatedPlanApprovalCredentials credentials, Long positionId)
      throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
    // if no start date is provided, then it doesn't make sense to say the clone is backdated
    if (startDate == null) return false;

    final boolean IS_BACKDATED_PLAN = true;

    List<Payroll> approvedPayrolls = payroll.getApprovedPayrolls(positionId);
    if (approvedPayrolls.size() > 0) {
      Payroll mostRecent = approvedPayrolls.get(0);
      if (startDate.before(
          mostRecent.getPeriodEnd())) { // "if this change is a backdated change..."
        if (credentials == null) { // throw exception if not credentials are provided
          throw new BackdatedPlanApprovalRequiredException(
              startDate, mostRecent.getId(), mostRecent.getPeriodEnd());
        }
        if (!areValidBackdatedPlanApprovalCredentials(
            credentials)) { // throw exception if credentials are inadequate
          throw new BackdatedPlanApprovalBadCredentialsException();
        }
        // if we get here, we're all good! backdated change included appropriate approval
        // credentials
        return IS_BACKDATED_PLAN;
      }
      // not a backdated change, so nothing to validate
    }
    return !IS_BACKDATED_PLAN;
  }

  private boolean areValidBackdatedPlanApprovalCredentials(BackdatedPlanApprovalCredentials creds) {
    Boolean isApproved = false;
    try {
      String username = creds.getUsername(), password = creds.getPassword();
      User approvingUser = securityService.getUser(username);
      isApproved =
          userExists(approvingUser)
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
    // todo figure out user roles
    //        List<UserRoleDO> roles = securityService.getUserRoles(user.getId());
    //        if (roles == null)
    //            return false;
    //        return roles.stream()
    //                .map(UserRoleDO::getRoleName)
    //                .anyMatch("Executive"::equalsIgnoreCase);
    return false;
  }

  public void insertUser(Long planId, PlanUser user, Long positionId)
      throws BackdatedPlanApprovalRequiredException, BackdatedPlanApprovalBadCredentialsException {
    final BackdatedPlanApprovalCredentials approvalCreds = user.getApprovalCreds();
    final Date newStartDate = user.getStartDate();
    boolean isBackdatedPlan =
        newStartDate != null
            && startDateChanged(user)
            && validateBackdatedPlan(newStartDate, approvalCreds, positionId);

    Map<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("userId", user.getUserId());
    params.put("startDate", newStartDate);
    params.put("endDate", user.getEndDate());

    if (user.getId() != null) {
      params.put("id", user.getId());
      sqlCache.updateBySql(CommissionManagementQuery.updateUser, params);
    } else {

      sqlCache.updateBySql(CommissionManagementQuery.insertEndDate, params);
      sqlCache.updateBySql(CommissionManagementQuery.insertUser, params);
    }

    if (isBackdatedPlan) {
      params.put(
          "note", "backdated plan entry approved by " + user.getApprovalCreds().getUsername());
      sqlCache.updateBySql(CommissionManagementQuery.appendNote, params);
    }
  }

  private boolean startDateChanged(PlanUser user) {
    if (user.getId() == null) return true; // no existing entry in database? then start is new

    final Optional<UserDateRange> existingDateRange =
        sqlCache.getBySql(
            CommissionManagementQuery.getUserDateRange,
            ImmutableMap.of(
                "rowId", user.getId(),
                "userId", user.getUserId()),
            UserDateRange.class);

    final LocalDate newStartDate =
        user.getStartDate().toInstant().atZone(ZoneOffset.UTC).toLocalDate();

    final Optional<LocalDate> existingStartDate =
        existingDateRange.map(UserDateRange::getStartDate);

    return existingStartDate.isPresent() && !newStartDate.equals(existingStartDate.get());
  }

  public Source updateSource(Long planId, Source source) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", source.getId());
    params.put("feeAmount", source.getFeeAmount());
    params.put("feeTypeId", source.getFeeTypeId());
    params.put("milestoneId", source.getMilestoneId());

    sqlCache.updateBySql(CommissionManagementQuery.updateSource, params);
    return getSource(source.getId());
  }

  public void removeSource(Long planId, Long sourceId) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", sourceId);
    sqlCache.updateBySql(CommissionManagementQuery.removeSource, params);
  }

  public void deletePlan(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("planId", id);
    sqlCache.updateBySql(CommissionManagementQuery.deletePlan, params);
  }

  public void removeMilestone(Long planId, Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.updateBySql(CommissionManagementQuery.removeMilestone, params);
  }

  public void deleteUser(Long planId, Long commissionPlanUserId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("planId", planId);
    params.put("commissionPlanUserId", commissionPlanUserId);
    sqlCache.updateBySql(CommissionManagementQuery.deleteUser, params);
  }

  public Set<Long> getUsersWithPlanGaps(List<Long> userIds) {
    Map<String, Object> params = ImmutableMap.of("userIds", userIds);
    List<UserDateRange> closerDates =
        sqlCache.queryBySql(CommissionManagementQuery.getUserDatesAsCloser, params, UserDateRange.class);

    // Make sets of all days the users have been closers...
    Map<Long, Set<LocalDate>> allUsersDatesNotCoveredByPlan = new HashMap<>();
    for (UserDateRange closer : closerDates)
      if (closer.getNumDaysInRange() > 0)
        allUsersDatesNotCoveredByPlan.merge(closer.getUserId(), closer.getDateRange(), Sets::union);

    // Now remove from those sets the days covered by plans
    List<UserDateRange> commissionPlanDates =
        sqlCache.queryBySql(CommissionManagementQuery.getUserDatesOnCommissionPlans, params, UserDateRange.class);

    for (UserDateRange plan : commissionPlanDates) {
      if (allUsersDatesNotCoveredByPlan.containsKey(plan.getUserId())) {
        Set<LocalDate> datesAsCloser = allUsersDatesNotCoveredByPlan.get(plan.getUserId()),
            datesNotCoveredByPlan = Sets.difference(datesAsCloser, plan.getDateRange());
        if (datesNotCoveredByPlan.isEmpty()) allUsersDatesNotCoveredByPlan.remove(plan.getUserId());
        else allUsersDatesNotCoveredByPlan.put(plan.getUserId(), datesNotCoveredByPlan);
      }
    }

    return allUsersDatesNotCoveredByPlan.keySet();
  }

  @Data
  public static class MilestoneType {
    private Long id, displayOrder;
    private String milestoneType;
  }

  @Getter
  public static class BackdatedPlanApprovalRequiredException extends Exception {
    private final Date userStartDate;
    private final Long payrollId;
    private final Date payrollEndDate;

    public BackdatedPlanApprovalRequiredException(
        Date userStartDate, Long payrollId, Date payrollEndDate) {
      super(
          String.format(
              "Provided user start date (%s) is before most"
                  + " recent payroll's end date (payroll id %d; end date %s);"
                  + " executive approval required",
              userStartDate, payrollId, payrollEndDate));
      this.userStartDate = userStartDate;
      this.payrollId = payrollId;
      this.payrollEndDate = payrollEndDate;
    }
  }

  public static class BackdatedPlanApprovalBadCredentialsException extends Exception {
    public BackdatedPlanApprovalBadCredentialsException() {
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
      bw.registerCustomEditor(
          List.class,
          "receivingPlans",
          new JsonCollectionDeserializer(receivingPlanRef, objectMapper));
    }
  }
}
