package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.PayrollActionType;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.PayrollAdjustmentType;
import com.albatross.api.v1.company.blueraven.enums.commissionManagement.PayrollStatus;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.AccountSearchRequest;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.Payroll;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.PayrollSearch;
import com.albatross.api.v1.flow.model.OverrideResult;
import com.google.common.collect.ImmutableMap;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import javax.validation.constraints.NotNull;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class PayrollService {

    private final SqlCache sqlCache;
    private final DataSource dataSource;
    private final SecurityService securityService;

    public Long findCurrentPayroll() {
        List<Long> payrollIds = sqlCache.queryBySql("SELECT id FROM brs.payroll WHERE current IS TRUE", new HashMap<>(), new SingleColumnRowMapper<>(Long.class));

        if (payrollIds.size() > 1) {
            log.error("PAYROLL_ERROR: There are multiple payrolls marked as current and the first one will be returned.");
        } else if (payrollIds.isEmpty()) {
            log.error("PAYROLL_ERROR: No Current Payroll Available");
        }

        return payrollIds.isEmpty() ? null : payrollIds.get(0);
    }

    public String payrollSearch(PayrollSearch searchQuery) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("startDate", searchQuery.getStartDate());
        params.put("endDate", searchQuery.getEndDate());
        params.put("customerName", searchQuery.getCustomerName());
        params.put("salesRepId", searchQuery.getSalesRepId());
        params.put("projectId", searchQuery.getProjectId());
        Optional<String> results = sqlCache.get("payroll.search", params, new SingleColumnRowMapper<>(String.class));
        return results.orElse("[]");
    }

    public Optional<String> getPayrollById(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", id);
        return sqlCache.get("payroll.getById", params, new SingleColumnRowMapper<>(String.class));
    }

    public List<Payroll> getApprovedPayrolls() {
        return sqlCache.query("payroll.getApprovedPayrolls",
                Collections.emptyMap(),
                Payroll.class);
    }

    @Transactional
    public void submitToPay(Long payrollId) {

        Boolean success = createPayrollSnapshot(payrollId);
        if (!success) {
            throw new RuntimeException("Unable to create snapshot");
        }

        setPayrollStatus(payrollId, PayrollStatus.SUBMITTED);
        addPayrollHistory(payrollId, PayrollActionType.SUBMITTED, null);
    }

    @Transactional
    public void approvePayroll(Long payrollId, PayrollApproveRequest request) {

        Boolean success = copyPayrollToLedger(payrollId);
        if (!success) {
            throw new RuntimeException("Unable to copy to ledger");
        }

        setPayrollPayDate(payrollId, request.getPayDate());
        setPayrollStatus(payrollId, PayrollStatus.APPROVED);
        addPayrollHistory(payrollId, PayrollActionType.APPROVED, null);

        createPayroll();
    }

    private Boolean copyPayrollToLedger(Long payrollId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("currentUserId", securityService.getCurrentUser().getId());
        params.put("payrollId", payrollId);

        Optional<Boolean> created = sqlCache.getBySql("select brs.copy_snapshot_to_ledger(:payrollId::int, :currentUserId::int)", params, new SingleColumnRowMapper<>(Boolean.class));
        if (created.isPresent()) {
            return created.get();
        }
        return false;
    }

    @Transactional
    public void rejectPayroll(Long payrollId) {
        setPayrollStatus(payrollId, PayrollStatus.REJECTED);
        addPayrollHistory(payrollId, PayrollActionType.REJECTED, null);
    }

    private void addPayrollHistory(Long payrollId, PayrollActionType actionType, String note) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", payrollId);
        params.put("actionTypeId", actionType.getId());
        params.put("note", note);
        params.put("currentUserId", securityService.getCurrentUser().getId());

        sqlCache.update("payroll.addActionHistory", params);
    }

    private void setPayrollPayDate(Long payrollId, String payDate) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", payrollId);
        params.put("payDate", payDate);

        sqlCache.updateBySql("UPDATE brs.payroll SET paid_date = :payDate::DATE WHERE id = :payrollId", params);
    }

    private void setPayrollStatus(Long payrollId, PayrollStatus payrollStatus) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", payrollId);
        params.put("payrollStatusId", payrollStatus.getId());

        sqlCache.update("payroll.setStatus", params);
    }

    private Boolean createPayrollSnapshot(Long payrollId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("currentUserId", securityService.getCurrentUser().getId());
        params.put("payrollId", payrollId);

        Optional<Boolean> created = sqlCache.getBySql("select brs.create_payroll_snapshot(:payrollId::int, :currentUserId::int)", params, new SingleColumnRowMapper<>(Boolean.class));
        return created.orElse(false);
    }

    public String getAccountReview(AccountSearchRequest request) throws SQLException {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", request.getPayrollId());
        params.put("periodEndDate", request.getPeriodEnd());
        params.put("locked", request.getLocked());
        params.put("projectId", null);
        params.put("customerId", request.getCustomerId());
        params.put("salesRepId", request.getSalesRepId());
        params.put("cancelStartDate", request.getCancelStartDate());
        params.put("cancelEndDate", request.getCancelEndDate());
        params.put("overridePlanId", request.getOverridePlanId());
        params.put("commissionPlanId", request.getCommissionPlanId());
        params.put("selectedProjectIds", null != request.getSelectedProjectIds() ? createSqlArrayOfType("int", request.getSelectedProjectIds()) : null);

        if (request.getProjectId() != null) {
            params.put("selectedProjectIds", createSqlArrayOfType("int", Arrays.asList(request.getProjectId())));
        }

        Optional<String> bySql = sqlCache.get("payroll.getAccountReview", params, new SingleColumnRowMapper<>(String.class));
        return bySql.orElse("[]");
    }

    public String getPayrollSearchDetail(Long payrollId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", payrollId);
        Optional<String> bySql = sqlCache.get("payroll.getPayrollSearchDetail", params, new SingleColumnRowMapper<>(String.class));
        return bySql.orElse("[]");
    }

    public void preparePayrollSummary() {
        new SimpleJdbcCall(dataSource)
                .withCatalogName("brs")
                .withProcedureName("refresh_summary_view")
                .withoutProcedureColumnMetaDataAccess()
                .execute();
    }

    public String checkSummaryPreparationStatus() {
        String status = sqlCache.get("payroll.checkSummaryPreparationStatus", null, new SingleColumnRowMapper<>(String.class)).orElse("finished");

        if (status.equals("active")) {
            return "Summary is still being created. Please wait.";
        } else {
            return "Summary is ready to view.";
        }
    }

    public String getAccountSummaryForCurrentPayroll() {
        HashMap<String, Object> params = new HashMap<>();
        return sqlCache.get("payroll.getCurrentSummary", params, new SingleColumnRowMapper<>(String.class)).orElse("[]");
    }

    public String getAccountSummaryByPayrollId(Long payrollId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", payrollId);

        return sqlCache.get("payroll.getSummary", params, new SingleColumnRowMapper<>(String.class)).orElse("[]");
    }

    public List<OverrideResult> getAllOverrideDetails(Long payrollId) {
        Map<String, Object> params = ImmutableMap.of("payrollId", payrollId);
        Optional<Integer> payrollStatusId = sqlCache.get("payroll.status", params, SingleColumnRowMapper.newInstance(Integer.class));

        if (payrollStatusId.isPresent()) {
            String sqlKey;
            if (payrollStatusId.get() == 3)
                sqlKey = "payroll.overridesSnapshot";
            else
                sqlKey = "payroll.overridesOpen";

            List<OverrideResult> results = sqlCache.query(sqlKey, params, OverrideResult.class);
            return results;
        } else {
            log.info("Payroll {} requested but no status found.", payrollId);
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Payroll Not Found", new Exception());
        }
    }

    @Transactional
    public boolean updatePayroll(Long payrollId, PayrollUpdateRequest updateRequest) throws SQLException {
        Long currentUserId = securityService.getCurrentUser().getId();
        Map<String, Object> params = new HashMap<>();
        params.put("currentUserId", currentUserId);
        params.put("payrollId", payrollId);
        params.put("description", updateRequest.getDescription());
        params.put("periodEndDate", updateRequest.getPeriodEnd());
        params.put("projectIds", createSqlArrayOfType("bigint", updateRequest.getProjectIds()));

        int update = sqlCache.update("payroll.updatePayroll", params);

        return update != 0;
    }

    public void addPayrollAdjustment(Long payrollId, PayrollAdjustmentRequest adjustmentRequest) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", payrollId);
        params.put("projectId", adjustmentRequest.getProjectId());
        params.put("closerId", adjustmentRequest.getCloserId());
        params.put("amount", adjustmentRequest.getAmount());
        params.put("note", adjustmentRequest.getNote());
        params.put("createdById", securityService.getCurrentUser().getId());
        params.put("adjustmentTypeId", adjustmentRequest.getAdjustmentType().getId());

        sqlCache.update("payroll.addCommissionAdjustment", params);
    }

    public String getPayrollAdjustments(Long payrollId, Long projectId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("payrollId", payrollId);
        params.put("projectId", projectId);

        Optional<String> adjustmentsOpt = sqlCache.get("payroll.getCommissionAdjustments", params, new SingleColumnRowMapper<>(String.class));
        return adjustmentsOpt.orElse("[]");
    }

    public boolean createPayroll() {
        Long currentUserId = securityService.getCurrentUser().getId();

        HashMap<String, Object> params = new HashMap<>();
        params.put("currentUserId", currentUserId);

        Optional<Boolean> created = sqlCache.getBySql("SELECT brs.create_payroll(:currentUserId::int)", params, new SingleColumnRowMapper<>(Boolean.class));
        if (created.isPresent()) {
            return created.get();
        }

        return false;
    }

    private Array createSqlArrayOfType(String typeName, List<?> array) throws SQLException {
        try (Connection connection = dataSource.getConnection()) {
            return connection.createArrayOf(typeName, array.toArray());
        }
    }

    @Data
    public static class ProjectLocked {
        private Long id;
        private boolean locked;
    }

    @Data
    public static class PayrollUpdateRequest {
        private String description, periodEnd;
        private List<Integer> projectIds;
    }

    @Data
    public static class PayrollAdjustmentRequest {
        private Long projectId, closerId;
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
