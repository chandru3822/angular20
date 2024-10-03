package com.albatross.api.v1.company.blueraven.controllers.partsMaster;

import com.albatross.api.exception.ApiException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.partsMaster.models.*;
import com.albatross.api.v1.company.blueraven.controllers.partsMaster.query.PartsMasterQuery;
import com.albatross.api.v1.company.blueraven.services.queries.BlueravenCustomFieldQuery;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
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

import static com.albatross.api.v1.company.blueraven.controllers.partsMaster.models.PartsMasterVersionStatus.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class PartsMasterVersionService {
  //TODO: don't allow edit of archived items

  private final SecurityService securityService;
  private final SqlCache sqlCache;
  private final ObjectMapper objectMapper;

  @Transactional
  public Optional<PartsMasterVersion> createPartsMasterVersion() {
    final var currentUser = securityService.getCurrentUser();

    final var versionNumber =
      sqlCache.updateBySqlReturningId(
        PartsMasterQuery.createCompanyPartsMasterVersion,
        Map.of("currentUserId", currentUser.getId(), "companyId", currentUser.getCompanyId()),
        "version_number");

    final var partsMasterId =
      sqlCache.updateBySqlReturningId(
        PartsMasterQuery.createPartsMasterVersion,
        Map.of(
          "companyId",
          currentUser.getCompanyId(),
          "statusId",
          DRAFT.ordinal(),
          "version",
          versionNumber,
          "currentUserId",
          currentUser.getId()),
        "id");

    return getPartsMasterVersion(partsMasterId.longValue());
  }

  @Transactional
  public Optional<PartsMasterVersion> publishPartsMasterVersion(Long id, String message) {
    final var currentUser = securityService.getCurrentUser();

    if (message == null || message.trim().isEmpty()) {
      throw new ApiException("A message is required to publish a parts master version");
    }

    sqlCache.updateBySql(
      PartsMasterQuery.publishPartsMasterVersion,
      Map.of(
        "statusId", PUBLISHED.ordinal(),
        "id", id,
        "notes", message,
        "currentUserId", currentUser.getId()));

    sqlCache.updateBySql(
      PartsMasterQuery.setAsCompanyPrimary,
      Map.of(
        "versionId",
        id,
        "companyId",
        currentUser.getCompanyId(),
        "currentUserId",
        currentUser.getId()));

    return getPartsMasterVersion(id);
  }

  public Optional<PartsMasterVersion> getPartsMasterVersion(Long id) {
    return sqlCache.getBySql(PartsMasterQuery.findById, Map.of("id", id), PartsMasterVersion.class);
  }

  public Page<PartsMasterVersion> getPartsMasterVersions(Pageable pageable, Boolean publishedOnly) {
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
      sqlCache.queryForObjectBySql(PartsMasterQuery.findAllByCompanyCount, params, Integer.class);
    final var query = sqlCache.queryBySql(PartsMasterQuery.findAllByCompany, params, PartsMasterVersion.class);

    return new PageImpl<>(query, pageable, count);
  }

  public List<PartsMasterObjectType> getPartsMasterTypes() {
    return sqlCache.queryBySql(PartsMasterQuery.findObjectTypes, Map.of(), PartsMasterObjectType.class);
  }

  public List<PartsMasterFieldObjectType> getPartsMasterFieldsByObjectCode(String objectCode) {
    return sqlCache.queryBySql(PartsMasterQuery.findPartsMasterFieldsByObjectCode,
      Map.of("objectCode", objectCode),
      PartsMasterFieldObjectType.class);
  }

  @Transactional
  public List<PartsMasterCustomValuesRow> resetPartsMasterVersionByCustomFieldByObjectCode(
    Long versionId, String objectCode) {
    Map<String, Object> params = Map.of("versionId", versionId, "objectCode", objectCode);

    sqlCache.updateBySql(PartsMasterQuery.resetCustomFieldGroup, params);
    sqlCache.updateBySql(PartsMasterQuery.unarchiveCustomFieldGroup, params);

    return getPartsMasterCustomFieldValues(versionId, objectCode);
  }

  private boolean isCustomFieldEmpty(JsonNode jsonNode) {
    if (jsonNode.has("value")) {
      JsonNode value = jsonNode.get("value");
      return value.isNull() || ((value.isNumber() || value.isTextual()) && !StringUtils.hasLength(value.asText()));
    }

    return false;
  }

  @SneakyThrows
  @Transactional
  public Optional<PartsMasterCustomValuesRow> updateCustomFieldValue(
    Long versionId, String objectCode, PartsMasterCustomGroup group) {

    final PartsMasterVersion partsMasterVersion = getDraftPartsMasterSettingsOrElseThrow(versionId);

    final var currentUser = securityService.getCurrentUser();
    var rowId = group.rowId() != null ? group.rowId() : UUID.randomUUID();

    final var removedItems = group.values().stream()
      .filter(partsMasterCustomFieldValue -> isCustomFieldEmpty(partsMasterCustomFieldValue.value()))
      .map(
        partsMasterCustomFieldValue ->
        {
          HashMap<String, Object> values = new HashMap<>();
          values.put("partsMasterVersionId", partsMasterVersion.getId());
          values.put("groupUUID", rowId);
          values.put("objectCode", objectCode);
          values.put("fieldId", partsMasterCustomFieldValue.id());

          return values;
        }
      )
      .toList();

    if (!removedItems.isEmpty()) {
      sqlCache.updateBatchBySql(PartsMasterQuery.deleteEmptyCustomFieldValues, removedItems);
    }

    final var params =
      group.values().stream()
        .filter(partsMasterCustomFieldValue -> !isCustomFieldEmpty(partsMasterCustomFieldValue.value()))
        .map(
          partsMasterCustomFieldValue ->
          {
            HashMap<String, Object> values = new HashMap<>();
            values.put("partsMasterVersionId", versionId);
            values.put("groupUUID", rowId);
            values.put("objectCode", objectCode);
            values.put("currentUserId", currentUser.getId());
            values.put("value", partsMasterCustomFieldValue.value().toString());
            values.put("fieldId", partsMasterCustomFieldValue.id());

            return values;
          }
        )
        .toList();

    if (!params.isEmpty()) {
      sqlCache.updateBatchBySql(PartsMasterQuery.insertCustomValue, params);
    }

    var row = getPartsMasterCustomFieldValuesByGroupUUID(versionId, objectCode, rowId);

    if (row.isPresent() && !params.isEmpty()) {

      var fields = row.get().getRow();

      // BRSID is a dropdown custom field. It is autogenerated when a new part is added. The format is objectCode (minus the prefix `PARTS_`), manufacturer, and part number in kabob case.
      // Only generate if one doesn't exist. Don't update if one already exists. Generate only if/when part has a manufacturer and part number.

      // doesn't have a BRSID
      if (!fields.containsKey("731")) {

        // has a manufacturer and part number, to construct a BRSID
        if (fields.containsKey("729") && fields.containsKey("730")) {

          var manufacturer = objectMapper.convertValue(fields.get("729"), JsonNode.class);
          var partNumber = objectMapper.convertValue(fields.get("730"), JsonNode.class);

          final var code = objectCode.substring(6).toLowerCase();
          final var brsID = String.format("%s-%s-%s", code, manufacturer.get("value").asText(), partNumber.get("value").asText());

          Map<String, Object> lovParams = Map.of("name", brsID, "parentId", 2608, "createdById", currentUser.getId());

          final var lovID = sqlCache.queryForObjectBySql(BlueravenCustomFieldQuery.upsertListOfValue, lovParams, Long.class);

          HashMap<String, Object> values = new HashMap<>();
          values.put("partsMasterVersionId", versionId);
          values.put("groupUUID", rowId);
          values.put("objectCode", objectCode);
          values.put("currentUserId", currentUser.getId());
          values.put("value", objectMapper.writeValueAsString(Map.of("type", "integer", "intValue", lovID, "value", brsID)));
          values.put("fieldId", 731);

          sqlCache.updateBatchBySql(PartsMasterQuery.insertCustomValue, List.of(values));
          row = getPartsMasterCustomFieldValuesByGroupUUID(versionId, objectCode, rowId);
        }
      }
    }

    return row;
  }

  /**
   * @param versionId
   * @param objectCode
   * @param groupUUID
   * @return
   */
  @Transactional
  public Optional<PartsMasterCustomValuesRow> deleteCustomFieldGroup(
    Long versionId, String objectCode, UUID groupUUID) {
    final var currentUser = securityService.getCurrentUser();

    final PartsMasterVersion partsMasterVersion = getDraftPartsMasterSettingsOrElseThrow(versionId);

    final Optional<PartsMasterCustomValuesRow> partsMasterCustomFieldValuesByGroupUUID =
      getPartsMasterCustomFieldValuesByGroupUUID(partsMasterVersion.getId(), objectCode, groupUUID);

    // if we have a current value for this group and version then just delete it
    if (partsMasterCustomFieldValuesByGroupUUID.isPresent()) {
      sqlCache.updateBySql(
        PartsMasterQuery.deleteCustomFieldGroup,
        Map.of("currentUserId", currentUser.getId(),
          "groupUUID", groupUUID,
          "versionId", versionId));
    }

    return getPartsMasterCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID);
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
  public Optional<PartsMasterCustomValuesRow> archiveCustomFieldGroup(
    Long versionId, String objectCode, UUID groupUUID) {
    final var currentUser = securityService.getCurrentUser();

    final PartsMasterVersion partsMasterVersion = getDraftPartsMasterSettingsOrElseThrow(versionId);

    Map<String, Object> params = Map.of(
      "currentUserId", currentUser.getId(),
      "groupUUID", groupUUID,
      "versionId", partsMasterVersion.getId());

    final Optional<PartsMasterCustomValuesRow> partsMasterCustomFieldValuesByGroupUUID =
      getPartsMasterCustomFieldValuesByGroupUUID(partsMasterVersion.getId(), objectCode, groupUUID)
        .filter(row -> row.getVersionId().equals(partsMasterVersion.getId()));

    // if we have a current value for this group and version then just delete it
    if (partsMasterCustomFieldValuesByGroupUUID.isPresent()) {
      sqlCache.updateBySql(PartsMasterQuery.deleteCustomFieldGroup, params);
    }

    sqlCache.updateBySql(PartsMasterQuery.archiveCustomFieldGroup, params);

    return getPartsMasterCustomFieldValuesByGroupUUID(versionId, objectCode, groupUUID)
      .or(() -> partsMasterCustomFieldValuesByGroupUUID)
      .map(row -> {
        //because we are in a transaction these values aren't properly updated, so we manually set them here
        row.setVersionId(versionId);
        row.setArchived(true);
        return row;
      });
  }

  private PartsMasterVersion getDraftPartsMasterSettingsOrElseThrow(@NonNull Long versionId) {
    return getPartsMasterVersion(versionId)
      .filter(pv -> DRAFT.equals(pv.getStatus()))
      .orElseThrow(() -> new RuntimeException("Parts Master version not found or not eligible for edits"));
  }

  private Optional<PartsMasterCustomValuesRow> getPartsMasterCustomFieldValuesByGroupUUID(
    Long versionId, String objectCode, UUID groupUUID) {
    final List<Map<String, Object>> query =
      sqlCache.queryBySql(
        PartsMasterQuery.partsMasterVersionCustomFieldValuesByUUID,
        Map.of("objectCode", objectCode, "versionId", versionId, "groupUUID", groupUUID),
        new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper, PartsMasterCustomValuesRow.class)).filter(Objects::nonNull).findFirst();
  }

  public List<PartsMasterCustomValuesRow> getPartsMasterCustomFieldValues(
    Long versionId, String objectCode) {

    Map<String, Object> params = Map.of("objectCode", objectCode, "versionId", versionId);
    final List<Map<String, Object>> query =
      sqlCache.queryBySql(PartsMasterQuery.partsMasterVersionCustomFieldValues, params, new ColumnMapRowMapper());

    return query.stream().map(getMapper(objectMapper, PartsMasterCustomValuesRow.class)).filter(Objects::nonNull).toList();
  }

  //  TODO: cacheable
  public List<Long> getPartsMasterValuesFilterIds(@NonNull Long versionId, PartsMasterValueFilter filter) {
    try {

      final PartsMasterVersion partsMasterVersion =
        getPartsMasterVersion(versionId)
          .filter(pv -> !DRAFT.equals(pv.getStatus()))
          .orElseThrow(
            () ->
              new ApiException("Parts Master version not found or has not been published"));

      final PGobject varsObject = new PGobject();
      varsObject.setType("jsonb");
      varsObject.setValue(objectMapper.writeValueAsString(filter));

      return sqlCache.queryBySql(
          PartsMasterQuery.findFilterableValues,
          Map.of("versionId", partsMasterVersion.getId(), "vars", varsObject),
          new SingleColumnRowMapper<>(Long.class))
        .stream()
        .filter(Objects::nonNull)
        .toList();

    } catch (SQLException | JsonProcessingException e) {
      throw new ApiException(e);
    }
  }

  public PartsMasterVersionHistoryChangeSet getChangeHistory(@NonNull Long versionId) {

    PartsMasterVersion partsMasterVersion = getPartsMasterVersion(versionId).orElseThrow(() -> new ApiException("Parts Master Version does not exist"));

    List<PartsMasterVersionHistory> history = sqlCache.queryBySql(PartsMasterQuery.findVersionHistoryByVersionId, Map.of("versionId", versionId), new ColumnMapRowMapper())
      .stream()
      .map(getMapper(objectMapper, PartsMasterVersionHistory.class))
      .filter(Objects::nonNull)
      .toList();

    PartsMasterVersionHistoryChangeSet historyChangeSet = new PartsMasterVersionHistoryChangeSet();
    BeanUtils.copyProperties(partsMasterVersion, historyChangeSet);
    historyChangeSet.setHistory(history);

    return historyChangeSet;
  }

  /***
   * Returns a list of partsMaster value ids available after filtering by the custom field and value.
   * This result set excludes values from the custom field instead of including them
   *
   * @param versionId
   * @param fieldId
   * @param filterFieldId
   * @param filterFieldValue
   * @return
   */
  public List<Long> getPartsMasterValueFilterIdsByCustomFieldAndValue(@NonNull Long versionId, @NonNull Long fieldId, Long filterFieldId, Object filterFieldValue, String objectCode) {
    Map<String, Object> params = new HashMap<>();
    params.put("versionId", versionId);
    params.put("fieldId", fieldId);
    params.put("filterFieldId", filterFieldId);
    params.put("filterFieldValue", filterFieldValue);
    params.put("objectCode", objectCode);

    return sqlCache.queryBySql(PartsMasterQuery.findFilterableValuesByFieldIdAndValue, params, new SingleColumnRowMapper<>(Long.class));
  }

  private <T> Function<Map<String, Object>, T> getMapper(ObjectMapper om, Class<T> type) {
    return m -> {
      final Object row = m.get("row");
      if (row instanceof PGobject gobject) {
        try {
          return om.readValue(gobject.getValue(), type);
        } catch (JsonProcessingException e) {
          log.error("Error reading parts Master", e);
        }
      }
      return null;
    };
  }
}
