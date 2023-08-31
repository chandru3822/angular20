package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.*;
import com.albatross.api.v1.company.blueraven.controllers.proposal.query.ProposalToolQuery;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.sql.SQLException;
import java.util.*;
import java.util.function.Function;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProposalVersionService {

  private final SecurityService securityService;
  private final SqlCache sqlCache;
  private final ObjectMapper objectMapper;

  @Transactional
  public Optional<ProposalVersion> createProposalVersion() {
    final var currentUser = securityService.getCurrentUser();

    final var versionNumber =
      sqlCache.updateBySqlReturningId(
        ProposalToolQuery.createCompanyProposalVersion,
        Map.of("currentUserId", currentUser.getId(), "companyId", currentUser.getCompanyId()),
        "version_number");

    final var proposalId =
      sqlCache.updateBySqlReturningId(
        ProposalToolQuery.createProposalVersion,
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

    sqlCache.updateBySql(
      ProposalToolQuery.publishProposalVersion,
      Map.of(
        "statusId",
        ProposalVersionStatus.PUBLISHED.ordinal(),
        "id",
        id,
        "notes",
        "",
        "currentUserId",
        currentUser.getId()));

    sqlCache.updateBySql(
      ProposalToolQuery.setAsCompanyPrimary,
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
    return sqlCache.getBySql(ProposalToolQuery.findById, Map.of("id", id), ProposalVersion.class);
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
      sqlCache.queryForObjectBySql(ProposalToolQuery.findAllByCompanyCount, params, Integer.class);
    final var query = sqlCache.queryBySql(ProposalToolQuery.findAllByCompany, params, ProposalVersion.class);

    return new PageImpl<>(query, pageable, count);
  }

  public List<ProposalObjectType> getProposalTypes() {
    return sqlCache.queryBySql(ProposalToolQuery.findObjectTypes, Map.of(), ProposalObjectType.class);
  }

  public List<ProposalFieldObjectType> getProposalFieldsByObjectCode(String objectCode) {
    return sqlCache.queryBySql(ProposalToolQuery.findProposalFieldsByObjectCode,
      Map.of("objectCode", objectCode),
      ProposalFieldObjectType.class);
  }

  public List<ProposalCustomValuesRow> resetProposalVersionByCustomFieldByObjectCode(
    Long versionId, String objectCode) {
    sqlCache.updateBySql(ProposalToolQuery.resetCustomFieldGroup,
      Map.of("versionId", versionId, "objectCode", objectCode));
    return getProposalCustomFieldValues(versionId, objectCode);
  }

  private boolean isCustomFieldEmpty(JsonNode jsonNode) {
    if (jsonNode.has("value")) {
      JsonNode value = jsonNode.get("value");
      return value.isNull() || ((value.isNumber() || value.isTextual()) && !StringUtils.hasLength(value.asText()));
    }

    return false;
  }

  @Transactional
  public Optional<ProposalCustomValuesRow> updateCustomFieldValue(
    Long versionId, String objectCode, ProposalCustomGroup group) {

    getProposalVersion(versionId)
      .filter(pv -> ProposalVersionStatus.DRAFT.equals(pv.getStatus()))
      .orElseThrow(
        () -> new RuntimeException("Proposal version not found or not eligible for edits"));

    final var currentUser = securityService.getCurrentUser();
    var rowId = group.rowId() != null ? group.rowId() : UUID.randomUUID();

    final var removedItems = group.values().stream()
      .filter(proposalCustomFieldValue -> isCustomFieldEmpty(proposalCustomFieldValue.value()))
      .map(
        proposalCustomFieldValue ->
        {
          HashMap<String, Object> values = new HashMap<>();
          values.put("proposalVersionId", versionId);
          values.put("groupUUID", rowId);
          values.put("objectCode", objectCode);
          values.put("fieldId", proposalCustomFieldValue.id());

          return values;
        }
      )
      .toList();

    if (!removedItems.isEmpty()) {
      sqlCache.updateBatchBySql(ProposalToolQuery.deleteEmptyCustomFieldValues, removedItems);
    }

    final var params =
      group.values().stream()
        .filter(proposalCustomFieldValue -> !isCustomFieldEmpty(proposalCustomFieldValue.value()))
        .map(
          proposalCustomFieldValue ->
          {
            HashMap<String, Object> values = new HashMap<>();
            values.put("proposalVersionId", versionId);
            values.put("groupUUID", rowId);
            values.put("objectCode", objectCode);
            values.put("currentUserId", currentUser.getId());
            values.put("value", proposalCustomFieldValue.value().toString());
            values.put("fieldId", proposalCustomFieldValue.id());

            return values;
          }
        )
        .toList();

    if (!params.isEmpty()) {
      sqlCache.updateBatchBySql(ProposalToolQuery.insertCustomValue, params);
    }

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
      sqlCache.updateBySql(
        ProposalToolQuery.deleteCustomFieldGroup,
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
      sqlCache.updateBySql(
        ProposalToolQuery.deleteCustomFieldGroup,
        Map.of(
          "currentUserId",
          currentUser.getId(),
          "groupUUID",
          groupUUID,
          "versionId",
          versionId));
    }

    sqlCache.updateBySql(
      ProposalToolQuery.archiveCustomFieldGroup,
      Map.of(
        "currentUserId", currentUser.getId(), "groupUUID", groupUUID, "versionId", versionId));

    return getProposalCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID);
  }

  public Optional<ProposalCustomValuesRow> getProposalCustomFieldValuesByGroupUUID(
    Long versionId, String objectCode, UUID groupUUID) {
    final List<Map<String, Object>> query =
      sqlCache.queryBySql(
        ProposalToolQuery.proposalVersionCustomFieldValuesByUUID,
        Map.of("objectCode", objectCode, "versionId", versionId, "groupUUID", groupUUID),
        new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper)).filter(Objects::nonNull).findFirst();
  }

  public List<ProposalCustomValuesRow> getProposalCustomFieldValues(
    Long versionId, String objectCode) {

    final List<Map<String, Object>> query =
      sqlCache.queryBySql(
        ProposalToolQuery.proposalVersionCustomFieldValues,
        Map.of("objectCode", objectCode, "versionId", versionId),
        new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper)).filter(Objects::nonNull).toList();
  }

  //  TODO: cacheable
  public List<Long> getProposalValuesByFieldId(@NonNull Long versionId, @NonNull Long fieldId) {
    return sqlCache.queryBySql(ProposalToolQuery.findFilterableValuesByFieldId,
      Map.of("versionId", versionId, "fieldId", fieldId), new SingleColumnRowMapper<>(Long.class));
  }

  //  TODO: cacheable
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

      return sqlCache.queryBySql(
          ProposalToolQuery.findFilterableValues,
          Map.of("versionId", proposalVersion.getId(), "vars", varsObject),
          new SingleColumnRowMapper<>(Long.class))
        .stream()
        .filter(Objects::nonNull)
        .toList();

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
