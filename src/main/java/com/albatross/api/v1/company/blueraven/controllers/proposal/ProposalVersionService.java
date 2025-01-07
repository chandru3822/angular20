package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.*;
import com.albatross.api.v1.company.blueraven.controllers.proposal.query.ProposalToolQuery;
import com.albatross.api.v1.company.blueraven.models.Proposal;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.BeanUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
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
//TODO: don't allow edit of archived items

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
  public Optional<ProposalVersion> publishProposalVersion(Long id, String message) {
    final var currentUser = securityService.getCurrentUser();

    if (message == null || message.trim().isEmpty()) {
      throw new ApiException("A message is required to publish a proposal");
    }

    sqlCache.updateBySql(
      ProposalToolQuery.publishProposalVersion,
      Map.of(
        "statusId", ProposalVersionStatus.PUBLISHED.ordinal(),
        "id", id,
        "notes", message,
        "currentUserId", currentUser.getId()));

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

  public Page<ProposalVersion> getProposalVersions(Pageable pageable, Boolean publishedOnly) {
    final var currentUser = securityService.getCurrentUser();
    final Map<String, Object> params =
      Map.of(
        "companyId",
        currentUser.getCompanyId(),
        "publishedOnly",
        publishedOnly,
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

  @Transactional
  public List<ProposalCustomValuesRow> resetProposalVersionByCustomFieldByObjectCode(
    Long versionId, String objectCode) {
    Map<String, Object> params = Map.of("versionId", versionId, "objectCode", objectCode);

    sqlCache.updateBySql(ProposalToolQuery.resetCustomFieldGroup, params);
    sqlCache.updateBySql(ProposalToolQuery.unarchiveCustomFieldGroup, params);

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

    final ProposalVersion proposalVersion = getDraftProposalSettingsOrElseThrow(versionId);

    final var currentUser = securityService.getCurrentUser();
    var rowId = group.rowId() != null ? group.rowId() : UUID.randomUUID();

    final var removedItems = group.values().stream()
      .filter(proposalCustomFieldValue -> isCustomFieldEmpty(proposalCustomFieldValue.value()))
      .map(
        proposalCustomFieldValue ->
        {
          HashMap<String, Object> values = new HashMap<>();
          values.put("proposalVersionId", proposalVersion.getId());
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
   * @param versionId
   * @param objectCode
   * @param groupUUID
   * @return
   */
  @Transactional
  public Optional<ProposalCustomValuesRow> deleteCustomFieldGroup(
    Long versionId, String objectCode, UUID groupUUID) {
    final var currentUser = securityService.getCurrentUser();

    final ProposalVersion proposalVersion = getDraftProposalSettingsOrElseThrow(versionId);

    final Optional<ProposalCustomValuesRow> proposalCustomFieldValuesByGroupUUID =
      getProposalCustomFieldValuesByGroupUUID(proposalVersion.getId(), objectCode, groupUUID);

    // if we have a current value for this group and version then just delete it
    if (proposalCustomFieldValuesByGroupUUID.isPresent()) {
      sqlCache.updateBySql(
        ProposalToolQuery.deleteCustomFieldGroup,
        Map.of("currentUserId", currentUser.getId(),
          "groupUUID", groupUUID,
          "versionId", versionId));
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

    final ProposalVersion proposalVersion = getDraftProposalSettingsOrElseThrow(versionId);

    Map<String, Object> params = Map.of(
      "currentUserId", currentUser.getId(),
      "groupUUID", groupUUID,
      "versionId", proposalVersion.getId());

    final Optional<ProposalCustomValuesRow> proposalCustomFieldValuesByGroupUUID =
      getProposalCustomFieldValuesByGroupUUID(proposalVersion.getId(), objectCode, groupUUID)
        .filter(row -> row.getVersionId().equals(proposalVersion.getId()));

    // if we have a current value for this group and version then just delete it
    if (proposalCustomFieldValuesByGroupUUID.isPresent()) {
      sqlCache.updateBySql(ProposalToolQuery.deleteCustomFieldGroup, params);
    }

    sqlCache.updateBySql(ProposalToolQuery.archiveCustomFieldGroup, params);

    return getProposalCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID)
      .or(() -> proposalCustomFieldValuesByGroupUUID)
      .map(row -> {
        //because we are in a transaction these values aren't properly updated, so we manually set them here
        row.setVersionId(versionId);
        row.setArchived(true);
        return row;
      });
  }

  private ProposalVersion getDraftProposalSettingsOrElseThrow(@NonNull Long versionId) {
    return getProposalVersion(versionId)
      .filter(pv -> ProposalVersionStatus.DRAFT.equals(pv.getStatus()))
      .orElseThrow(
        () -> new RuntimeException("Proposal version not found or not eligible for edits"));
  }

  private Optional<ProposalCustomValuesRow> getProposalCustomFieldValuesByGroupUUID(
    Long versionId, String objectCode, UUID groupUUID) {
    final List<Map<String, Object>> query =
      sqlCache.queryBySql(
        ProposalToolQuery.proposalVersionCustomFieldValuesByUUID,
        Map.of("objectCode", objectCode, "versionId", versionId, "groupUUID", groupUUID),
        new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper, ProposalCustomValuesRow.class)).filter(Objects::nonNull).findFirst();
  }

  public List<ProposalCustomValuesRow> getProposalCustomFieldValues(
    Long versionId, String objectCode) {

    Map<String, Object> params = Map.of("objectCode", objectCode, "versionId", versionId);
    final List<Map<String, Object>> query =
      sqlCache.queryBySql(ProposalToolQuery.proposalVersionCustomFieldValues, params, new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper, ProposalCustomValuesRow.class)).filter(Objects::nonNull).toList();
  }

  public Optional<String> getKwhProposalValueForUtility(String utilityCompany) {
    Map<String, Object> params = Map.of("utilityCompany", utilityCompany);
    return sqlCache.getBySql(ProposalToolQuery.getKwhProposalValueForUtility, params, new SingleColumnRowMapper<>(String.class));
  }

  public List<Long> getProposalValuesFilterIds(@NonNull Proposal proposal, ProposalValueFilter filter) {
    try {

      final ProposalVersion proposalVersion =
        getProposalVersion(proposal.getProposalVersionId())
          .filter(pv -> !ProposalVersionStatus.DRAFT.equals(pv.getStatus()))
          .orElseThrow(
            () ->
              new ApiException("Proposal version not found or has not been published"));

      final PGobject varsObject = new PGobject();
      varsObject.setType("jsonb");
      varsObject.setValue(objectMapper.writeValueAsString(filter));

      Map<String, Object> params = Map.of(
        "versionId", proposalVersion.getId(),
        "stateId", proposal.getStateId(),
        "vars", varsObject);

      return sqlCache.queryBySql(
          ProposalToolQuery.findFilterableValues,
          params,
          new SingleColumnRowMapper<>(Long.class))
        .stream()
        .filter(Objects::nonNull)
        .toList();

    } catch (SQLException | JsonProcessingException e) {
      throw new ApiException(e);
    }
  }

  public ProposalVersionHistoryChangeSet getChangeHistory(@NonNull Long versionId) {

    ProposalVersion proposalVersion = getProposalVersion(versionId).orElseThrow(() -> new ApiException("Proposal Version does not exist"));

    List<ProposalVersionHistory> history = sqlCache.queryBySql(ProposalToolQuery.findVersionHistoryByVersionId, Map.of("versionId", versionId), new ColumnMapRowMapper())
      .stream()
      .map(getMapper(objectMapper, ProposalVersionHistory.class))
      .filter(Objects::nonNull)
      .toList();

    ProposalVersionHistoryChangeSet historyChangeSet = new ProposalVersionHistoryChangeSet();
    BeanUtils.copyProperties(proposalVersion, historyChangeSet);
    historyChangeSet.setHistory(history);

    return historyChangeSet;
  }

  /***
   * Returns a list of proposal value ids available after filtering by the custom field and value.
   * This result set excludes values from the custom field instead of including them
   *
   * @param versionId
   * @param fieldId
   * @param filterFieldId
   * @param filterFieldValue
   * @return
   */
  public List<Long> getProposalValueFilterIdsByCustomFieldAndValue(@NonNull Long versionId, @NonNull Long fieldId, Long filterFieldId, Object filterFieldValue, String objectCode) {
    Map<String, Object> params = new HashMap<>();
    params.put("versionId", versionId);
    params.put("fieldId", fieldId);
    params.put("filterFieldId", filterFieldId);
    params.put("filterFieldValue", filterFieldValue);
    params.put("objectCode", objectCode);

    return sqlCache.queryBySql(ProposalToolQuery.findFilterableValuesByFieldIdAndValue, params, new SingleColumnRowMapper<>(Long.class));
  }

  private <T> Function<Map<String, Object>, T> getMapper(ObjectMapper om, Class<T> type) {
    return m -> {
      final Object row = m.get("row");
      if (row instanceof PGobject gobject) {
        try {
          return om.readValue(gobject.getValue(), type);
        } catch (JsonProcessingException e) {
          log.error("Error reading proposal", e);
        }
      }
      return null;
    };
  }
}
