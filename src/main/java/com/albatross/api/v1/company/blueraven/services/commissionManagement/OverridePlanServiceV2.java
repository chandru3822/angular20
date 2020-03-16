package com.albatross.api.v1.company.blueraven.services.commissionManagement;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.CloserOverrideAssignment;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.OfficeOverrideAllowances;
import com.albatross.api.v1.company.blueraven.models.commissionManagement.OverrideReceiving;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableListMultimap;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Multimaps;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OverridePlanServiceV2 {
    private final SqlCache sqlCache;
    private final NamedParameterJdbcTemplate jdbc;

    public List<CloserOverrideAssignment> getAllCloserOverrideAssignments() {
        return sqlCache.query("overridesManagement.getAllAssignments",
                Collections.emptyMap(),
                CloserOverrideAssignment.class);
    }

    public List<CloserOverrideAssignment> getCloserOverrideAssignments(Long closerRegionalUserId) {
        return sqlCache.query("overridesManagement.getAssignmentsByRegion",
                ImmutableMap.of("closerRegionalUserId", closerRegionalUserId),
                CloserOverrideAssignment.class);
    }

    public List<CloserOverrideAssignment> getPendingCloserOverrideAssignments() {
        return sqlCache.query("overridesManagement.getAllPendingAssignments",
                Collections.emptyMap(),
                CloserOverrideAssignment.class);
    }

    public void setApprovalStatus(Long overrideCloserId,
                                  Long currentUserId,
                                  String effectiveDate,
                                  Integer statusTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("overrideCloserId", overrideCloserId);
        params.put("currentUserId", currentUserId);
        params.put("effectiveDate", effectiveDate);
        params.put("statusTypeId", statusTypeId);

        sqlCache.update("overridesManagement.setApprovalStatus", params);
    }

    public List<OfficeOverrideAllowances> getAllowances() {
        return sqlCache.query("overridesManagement.getOfficeAllowances",
                Collections.emptyMap(),
                OfficeOverrideAllowances.class);
    }

    public void saveOverrideAssignments(Long closerId,
                                        Long overrideCloserId,
                                        Long createdById,
                                        Long modifiedById,
                                        LocalDate effectiveDate,
                                        List<CloserOverrideAssignment.OverrideRecipient> recipients,
                                        Boolean isUpdate) {
        HashMap<String, Object> overridesOnCloserParams = new HashMap<>();

        // new assignments + overrides are added here
        if (!isUpdate) {
            HashMap<String, Object> overrideCloserParams = new HashMap<>();
            overrideCloserParams.put("closerId", closerId);
            overrideCloserParams.put("createdById", createdById);
            overrideCloserParams.put("effectiveDate", effectiveDate);

            Long id = sqlCache.updateReturningId("overridesManagement.createAssignment", overrideCloserParams, "id").longValue();

            overridesOnCloserParams.put("overrideCloserId", id);

            recipients.forEach(recipient -> {
                overridesOnCloserParams.put("amount", recipient.getAmount());
                overridesOnCloserParams.put("userId", recipient.getId());
                sqlCache.update("overridesManagement.insertCloserOverride", overridesOnCloserParams);
            });
        } else { // existing overrides are updated and any new overrides on an existing assignment are added
            overridesOnCloserParams.put("overrideCloserId", overrideCloserId);

            recipients.forEach(recipient -> {
                overridesOnCloserParams.put("amount", recipient.getAmount());

                if (recipient.getRowId() != null) {
                    overridesOnCloserParams.put("rowId", recipient.getRowId());
                    overridesOnCloserParams.put("modifiedById", modifiedById);
                    sqlCache.update("overridesManagement.updateCloserOverride", overridesOnCloserParams);
                } else {
                    overridesOnCloserParams.put("userId", recipient.getId());
                    sqlCache.update("overridesManagement.insertCloserOverride", overridesOnCloserParams);
                }
            });
        }
    }

    public void updateAllowances(Long officeId, List<OfficeOverrideAllowances.AllowanceEntry> allowances) {
        ImmutableListMultimap<Boolean, OfficeOverrideAllowances.AllowanceEntry> mAllowances = Multimaps.index(allowances, allowance -> allowance.getId() != null);

        // update the entries that already exist in the DB (i.e., have ids from the db)
        if (mAllowances.containsKey(true))
            persistAllowances(officeId, mAllowances.get(true), "overridesManagement.updateAllowancesForOffice");

        // save the entries that are new (i.e., don't have db ids)
        if (mAllowances.containsKey(false))
            persistAllowances(officeId, mAllowances.get(false), "overridesManagement.addNewAllowancesForOffice");
    }

    public List<User> getAssignableUsers() {
        return sqlCache.query("overridesManagement.getAssignableUsers",
                Collections.emptyMap(), User.class);
    }

    private void persistAllowances(Long officeId, ImmutableList<OfficeOverrideAllowances.AllowanceEntry> allowances1, String sqlKey) {
        SqlParameterSource[] objs = toSqlParameterSource(officeId, allowances1);
        String sql = sqlCache.getByKey(sqlKey);
        jdbc.batchUpdate(sql, objs);
    }

    private SqlParameterSource[] assignmentsToSqlParameterSource(Long closerId,
                                                                 Long officeId,
                                                                 Long overrideCloserId,
                                                                 LocalDate effectiveDate,
                                                                 List<CloserOverrideAssignment.OverrideRecipient> assignments) {
        return assignments.stream()
                .map(assignment -> {
                        MapSqlParameterSource m = new MapSqlParameterSource();
                        m.addValue("officeId", officeId)
                            .addValue("closerId", closerId)
                            .addValue("overrideCloserId", overrideCloserId)
                            .addValue("effectiveDate", effectiveDate)
                            .addValue("id", assignment.getId())
                            .addValue("amount", assignment.getAmount());
                        return m;
                }).toArray(SqlParameterSource[]::new);
    }

    private SqlParameterSource[] toSqlParameterSource(Long officeId, List<OfficeOverrideAllowances.AllowanceEntry> allowances) {
        return allowances.stream()
                .map(allowance -> {
                    MapSqlParameterSource m = new MapSqlParameterSource();
                    m.addValue("officeId", officeId)
                            .addValue("allowance", allowance.getAllowance())
                            .addValue("startDate", allowance.getStartDate())
                            .addValue("endDate", allowance.getEndDate())
                            .addValue("archived", allowance.getArchived())
                            .addValue("id", allowance.getId());
                    return m;
                }).toArray(SqlParameterSource[]::new);
    }

    public List<OverrideReceiving> getOverridesReceivedForOffice(Long userId, Boolean isCloserRegional, String effectiveDate) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("effectiveDate", effectiveDate);

        if (isCloserRegional) {
            return sqlCache.query("overridesManagement.getOverridesReceivedForCloserRegional",
                    params,
                    OverrideReceiving.class);
        } else {
            return sqlCache.query("overridesManagement.getOverridesReceivedForCloserOrManager",
                    params,
                    OverrideReceiving.class);
        }
    }
}
