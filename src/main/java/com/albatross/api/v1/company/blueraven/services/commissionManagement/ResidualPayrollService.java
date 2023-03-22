package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.PayrollAdjustmentType;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.PayrollStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Payroll;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.PayrollSearch;
import com.albatross.api.v1.company.blueraven.services.commissionManagement.queries.ResidualPayrollQuery;
import com.albatross.api.v1.flow.services.SqlArrayService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import javax.validation.constraints.NotNull;
import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ResidualPayrollService {

  private final SqlCache sqlCache;
  private final DataSource dataSource;
  private final SqlArrayService sqlArrayService;
  private final SecurityService securityService;

  public String residualSearch(PayrollSearch searchQuery) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", searchQuery.getStartDate());
    params.put("endDate", searchQuery.getEndDate());
    params.put("userId", searchQuery.getUserId());
    params.put("userFirstName", searchQuery.getUserFirstName());
    params.put("userLastName", searchQuery.getUserLastName());

    Optional<String> results = sqlCache.getBySql(ResidualPayrollQuery.search, params, new SingleColumnRowMapper<>(String.class));

    return results.orElse("[]");
  }

  public Long findCurrentResidual() {
    List<Long> residualIds =
      sqlCache.queryBySql(
        ResidualPayrollQuery.getCurrentResidualId, Collections.emptyMap(), new SingleColumnRowMapper<>(Long.class));

    if (residualIds.size() > 1) {
      log.error(
        "RESIDUAL: There are multiple residuals marked as current and the first one will be returned.");
    } else if (residualIds.isEmpty()) {
      log.error("RESIDUAL: No Current Residual Available");
    }

    return residualIds.isEmpty() ? null : residualIds.get(0);
  }

  public Optional<String> getResidualById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", id);
    return sqlCache.getBySql(ResidualPayrollQuery.getById, params, new SingleColumnRowMapper<>(String.class));
  }

  public List<Payroll> getApprovedResiduals() {
    return sqlCache.queryBySql(ResidualPayrollQuery.getApprovedResiduals, Collections.emptyMap(), Payroll.class);
  }

  @Transactional
  public void submitToPay(Long residualId) {

    Boolean success = createResidualSnapshot(residualId);
    if (!success) {
      throw new RuntimeException("Unable to create snapshot");
    }

    setPayrollStatus(residualId, PayrollStatus.SUBMITTED);
  }

  @Transactional
  public void approveResidual(Long residualId, PayrollApproveRequest request) {

    Boolean success = copyResidualToLedger(residualId);
    if (!success) {
      throw new RuntimeException("Unable to copy to ledger");
    }

    setResidualPayDate(residualId, request.getPayDate());
    setPayrollStatus(residualId, PayrollStatus.APPROVED);

    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", residualId);

    createResidual();
  }

  private Boolean copyResidualToLedger(Long residualId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());
    params.put("residualId", residualId);

    Optional<Boolean> created =
      sqlCache.getBySql(
        "select brs.copy_residual_snapshot_to_ledger(:residualId::bigint, :currentUserId::bigint)",
        params,
        new SingleColumnRowMapper<>(Boolean.class));
    return created.orElse(false);
  }

  @Transactional
  public void rejectResidual(Long residualId) {
    setPayrollStatus(residualId, PayrollStatus.REJECTED);
  }

  private void setResidualPayDate(Long residualId, String payDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", residualId);
    params.put("payDate", payDate);

    sqlCache.updateBySql(
      "UPDATE brs.residual SET paid_date = :payDate::DATE WHERE id = :residualId", params);
  }

  private void setPayrollStatus(Long residualId, PayrollStatus payrollStatus) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", residualId);
    params.put("payrollStatusId", payrollStatus.getId());

    sqlCache.updateBySql(ResidualPayrollQuery.setStatus, params);
  }

  private Boolean createResidualSnapshot(Long residualId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", securityService.getCurrentUser().trueUserId());
    params.put("residualId", residualId);

    Optional<Boolean> created =
      sqlCache.getBySql(
        "select brs.create_residual_snapshot(:residualId::bigint, :currentUserId::bigint)",
        params,
        new SingleColumnRowMapper<>(Boolean.class));
    return created.orElse(false);
  }

  @Transactional
  public boolean updateResidual(Long residualId, PayrollUpdateRequest updateRequest)
    throws SQLException {
    Long currentUserId = securityService.getCurrentUser().trueUserId();
    Map<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUserId);
    params.put("residualId", residualId);
    params.put("description", updateRequest.getDescription());
    params.put(
      "userIds",
      sqlArrayService.createSqlArrayOfType("bigint", updateRequest.getUserIds()));

    int update = sqlCache.updateBySql(ResidualPayrollQuery.updateResidual, params);

    return update != 0;
  }

  public String getResidualSearchDetail(Long residualId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", residualId);

    Optional<String> bySql = sqlCache.getBySql(ResidualPayrollQuery.getResidualSearchDetail, params, new SingleColumnRowMapper<>(String.class));

    return bySql.orElse("[]");
  }

  public void addResidualAdjustment(Long residualId, PayrollAdjustmentRequest adjustmentRequest) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", residualId);
    params.put("userId", adjustmentRequest.getUserId());
    params.put("amount", adjustmentRequest.getAmount());
    params.put("note", adjustmentRequest.getNote());
    params.put("createdById", securityService.getCurrentUser().trueUserId());
    params.put("adjustmentTypeId", 3L);

    sqlCache.updateBySql(ResidualPayrollQuery.addResidualAdjustment, params);
  }

  public String getResidualAdjustments(Long residualId, Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("residualId", residualId);
    params.put("userId", userId);

    Optional<String> adjustmentsOpt =
      sqlCache.getBySql(
        ResidualPayrollQuery.getResidualAdjustments, params, new SingleColumnRowMapper<>(String.class));
    return adjustmentsOpt.orElse("[]");
  }

  public boolean createResidual() {
    Long currentUserId = securityService.getCurrentUser().trueUserId();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUserId);

    Optional<Boolean> created =
      sqlCache.getBySql(
        "SELECT brs.create_residual(:currentUserId::bigint)",
        params,
        new SingleColumnRowMapper<>(Boolean.class));
    return created.orElse(false);
  }

  @Data
  public static class UserLocked {
    private Long id;
    private boolean locked;
  }

  @Data
  public static class PayrollUpdateRequest {
    private String description;
    private List<Integer> projectIds, userIds;
  }

  @Data
  public static class PayrollAdjustmentRequest {
    private Long userId;
    private Double amount;
    private String note;

    @NotNull
    private PayrollAdjustmentType adjustmentType;
  }

  @Data
  public static class PayrollApproveRequest {
    private String payDate;
  }
}
