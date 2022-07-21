package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.*;
import java.util.function.Function;

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccessLevel('PROPOSALS_ADMIN')")
@RequiredArgsConstructor
public class ProposalVersionService {

  private final SecurityService securityService;
  private final SqlCache sqlCache;
  private final ObjectMapper objectMapper;

  @Transactional
  public Optional<ProposalVersion> createProposalVersion() {
    final var currentUser = securityService.getCurrentUser();

    final var versionNumber =
        sqlCache.updateReturningId(
            "propTool.createCompanyProposalVersion",
            Map.of("currentUserId", currentUser.getId(), "companyId", currentUser.getCompanyId()),
            "version_number");

    final var proposalId =
        sqlCache.updateReturningId(
            "propTool.createProposalVersion",
            Map.of(
                "companyId",
                currentUser.getCompanyId(),
                "statusId",
                ProposalVersionStatus.DRAFT.ordinal(),
                "version",
                versionNumber,
                "currentUserId",
                currentUser.getId()),
            "id");

    return getProposalVersion(proposalId.longValue());
  }

  @Transactional
  public Optional<ProposalVersion> publishProposalVersion(Long id) {
    final var currentUser = securityService.getCurrentUser();

    sqlCache.update(
        "propTool.publishProposalVersion",
        Map.of(
            "statusId",
            ProposalVersionStatus.PUBLISHED.ordinal(),
            "id",
            id,
            "notes",
            "",
            "currentUserId",
            currentUser.getId()));

    sqlCache.update(
        "propTool.setAsCompanyPrimary",
        Map.of(
            "versionId",
            id,
            "companyId",
            currentUser.getCompanyId(),
            "currentUserId",
            currentUser.getId()));

    return getProposalVersion(id);
  }

  public Optional<ProposalVersion> getProposalVersion(Long id) {
    return sqlCache.get("propTool.findById", Map.of("id", id), ProposalVersion.class);
  }

  public Page<ProposalVersion> getProposalVersions(Pageable pageable) {
    final var currentUser = securityService.getCurrentUser();
    final Map<String, Object> params =
        Map.of(
            "companyId",
            currentUser.getCompanyId(),
            "limit",
            pageable.getPageSize(),
            "offset",
            pageable.getOffset());

    final var count =
        sqlCache.queryForObject("propTool.findAllByCompany.count", params, Integer.class);
    final var query = sqlCache.query("propTool.findAllByCompany", params, ProposalVersion.class);

    return new PageImpl<>(query, pageable, count);
  }

  public List<ProposalObjectType> getProposalTypes() {
    return sqlCache.query("propTool.findObjectTypes", Map.of(), ProposalObjectType.class);
  }

  public List<ProposalFieldObjectType> getProposalFieldsByObjectCode(String objectCode) {
    return sqlCache.query(
        "propTool.findProposalFieldsByObjectCode",
        Map.of("objectCode", objectCode),
        ProposalFieldObjectType.class);
  }

  public List<ProposalCustomValuesRow> resetProposalVersionByCustomFieldByObjectCode(
      Long versionId, String objectCode) {
    sqlCache.update(
        "propTool.resetCustomFieldGroup", Map.of("versionId", versionId, "objectCode", objectCode));
    return getProposalCustomFieldValues(versionId, objectCode);
  }

  @Transactional
  public Optional<ProposalCustomValuesRow> updateCustomFieldValue(
      Long versionId, String objectCode, ProposalCustomGroup group) {

    final var currentUser = securityService.getCurrentUser();
    var rowId = group.rowId() != null ? group.rowId() : UUID.randomUUID();

    final var params =
        group.values().stream()
            .map(
                proposalCustomFieldValue ->
                    Map.of(
                        "proposalVersionId",
                        versionId,
                        "groupUUID",
                        rowId,
                        "objectCode",
                        objectCode,
                        "value",
                        proposalCustomFieldValue.value().toString(),
                        "fieldId",
                        proposalCustomFieldValue.id(),
                        "currentUserId",
                        currentUser.getId()))
            .toList();

    sqlCache.updateBatch("propTool.insertCustomValue", params);

    return getProposalCustomFieldValuesByGroupUUID(versionId, objectCode, rowId);
  }

  /**
   * This does a hard delete and removes all values associated to the field group
   *
   * @param versionId
   * @param objectCode
   * @param groupUUID
   * @return
   */
  @Transactional
  public Optional<ProposalCustomValuesRow> deleteCustomFieldGroup(
      Long versionId, String objectCode, UUID groupUUID) {
    final var currentUser = securityService.getCurrentUser();

    final ProposalVersion proposalVersion =
        getProposalVersion(versionId)
            .filter(pv -> ProposalVersionStatus.DRAFT.equals(pv.getStatus()))
            .orElseThrow(
                () -> new RuntimeException("Proposal version not found or not eligible for edits"));

    final Optional<ProposalCustomValuesRow> proposalCustomFieldValuesByGroupUUID =
        getProposalCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID)
            .filter(row -> row.getVersionId().equals(versionId));

    // if we have a current value for this group and version then just delete it
    if (proposalCustomFieldValuesByGroupUUID.isPresent()) {
      sqlCache.update(
          "propTool.deleteCustomFieldGroup",
          Map.of(
              "currentUserId",
              currentUser.getId(),
              "groupUUID",
              groupUUID,
              "versionId",
              versionId));
    }

    return getProposalCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID);
  }

  /**
   * This removes any values for the current version and marks the row as "archived" This means we
   * don't want to bring this particular group forward in future versions
   *
   * @param versionId
   * @param objectCode
   * @param groupUUID
   * @return
   */
  @Transactional
  public Optional<ProposalCustomValuesRow> archiveCustomFieldGroup(
      Long versionId, String objectCode, UUID groupUUID) {
    final var currentUser = securityService.getCurrentUser();

    final ProposalVersion proposalVersion =
        getProposalVersion(versionId)
            .filter(pv -> ProposalVersionStatus.DRAFT.equals(pv.getStatus()))
            .orElseThrow(
                () -> new RuntimeException("Proposal version not found or not eligible for edits"));

    final Optional<ProposalCustomValuesRow> proposalCustomFieldValuesByGroupUUID =
        getProposalCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID)
            .filter(row -> row.getVersionId().equals(versionId));

    // if we have a current value for this group and version then just delete it
    if (proposalCustomFieldValuesByGroupUUID.isPresent()) {
      sqlCache.update(
          "propTool.deleteCustomFieldGroup",
          Map.of(
              "currentUserId",
              currentUser.getId(),
              "groupUUID",
              groupUUID,
              "versionId",
              versionId));
    }

    sqlCache.update(
        "propTool.archiveCustomFieldGroup",
        Map.of(
            "currentUserId", currentUser.getId(), "groupUUID", groupUUID, "versionId", versionId));

    return getProposalCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID);
  }

  public Optional<ProposalCustomValuesRow> getProposalCustomFieldValuesByGroupUUID(
      Long versionId, String objectCode, UUID groupUUID) {
    final List<Map<String, Object>> query =
        sqlCache.query(
            "propTool.proposalVersionCustomFieldValuesByUUID",
            Map.of("objectCode", objectCode, "versionId", versionId, "groupUUID", groupUUID),
            new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper)).filter(Objects::nonNull).findFirst();
  }

  public List<ProposalCustomValuesRow> getProposalCustomFieldValues(
      Long versionId, String objectCode) {

    final List<Map<String, Object>> query =
        sqlCache.query(
            "propTool.proposalVersionCustomFieldValues",
            Map.of("objectCode", objectCode, "versionId", versionId),
            new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper)).filter(Objects::nonNull).toList();
  }

  public List<Long> getProposalValuesFilterIds(
      @NonNull Long versionId, ProposalValueFilter filter) {
    try {

      final ProposalVersion proposalVersion =
          getProposalVersion(versionId)
              .filter(pv -> !ProposalVersionStatus.DRAFT.equals(pv.getStatus()))
              .orElseThrow(
                  () ->
                      new ApiException("Proposal version not found or has not been published"));

      final PGobject varsObject = new PGobject();
      varsObject.setType("jsonb");
      varsObject.setValue(objectMapper.writeValueAsString(filter));

    return sqlCache.queryForList(
          "propTool.findFilterableValues",
          Map.of("versionId", proposalVersion.getId(), "vars", varsObject),
          Long.class);

    } catch (SQLException | JsonProcessingException e) {
      throw new ApiException(e);
    }
  }

  private Function<Map<String, Object>, ProposalCustomValuesRow> getMapper(ObjectMapper om) {
    return m -> {
      final Object row = m.get("row");
      if (row instanceof PGobject) {
        try {
          return om.readValue(((PGobject) row).getValue(), ProposalCustomValuesRow.class);
        } catch (JsonProcessingException e) {
          log.error("Error reading proposal", e);
        }
      }
      return null;
    };
  }
}
