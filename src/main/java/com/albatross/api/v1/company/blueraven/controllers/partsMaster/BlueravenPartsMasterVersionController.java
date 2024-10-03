package com.albatross.api.v1.company.blueraven.controllers.partsMaster;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.partsMaster.models.*;
import com.albatross.api.v1.company.blueraven.services.queries.BlueravenCustomFieldQuery;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;


@Slf4j
@Validated
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/partsMaster/versions")
@RequiredArgsConstructor
@PreAuthorize("hasCompanyAccess(3)")
public class BlueravenPartsMasterVersionController {
  private final PartsMasterVersionService partsMasterVersionService;
  private final SqlCache sqlCache;
  private final ObjectMapper om;

  @PostMapping
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public ResponseEntity<PartsMasterVersion> createPartsMasterVersion() {
    return ResponseEntity.of(partsMasterVersionService.createPartsMasterVersion());
  }

  @GetMapping
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN', 'PARTS_MASTER_MANAGE')")
  public Page<PartsMasterVersion> getPartsMasterVersions(
    @RequestParam(name = "published", defaultValue = "false") Boolean publishedOnly,
    Pageable pageable) {
    return partsMasterVersionService.getPartsMasterVersions(pageable, publishedOnly);
  }

  @GetMapping(value = "/{id}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterVersion> getPartsMasterVersion(@PathVariable Long id) {
    return partsMasterVersionService.getPartsMasterVersion(id);
  }

  @PostMapping(value = "/{id}/publish")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterVersion> publishPartsMasterVersion(@PathVariable Long id, @Valid @RequestBody PartsMasterPublishRequest request) {
    return partsMasterVersionService.publishPartsMasterVersion(id, request.message());
  }

  @GetMapping(value="/{id}/history")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public PartsMasterVersionHistoryChangeSet getPartsMasterVersionHistory(@PathVariable Long id){
    return partsMasterVersionService.getChangeHistory(id);
  }

  public record PartsMasterPublishRequest(@NotEmpty String message) {
  }

  @GetMapping(value = "/{id}/values/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterCustomValuesRow> getPartsMasterCustomFieldsByObjectCode(
    @PathVariable Long id, @PathVariable String objectCode) {
    return partsMasterVersionService.getPartsMasterCustomFieldValues(id, objectCode);
  }

  @PostMapping(value = "/{id}/values/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterCustomValuesRow> updatePartsMasterCustomFieldsByObjectCode(
    @PathVariable Long id,
    @PathVariable String objectCode,
    @Valid @RequestBody final PartsMasterCustomGroup group) {
    return partsMasterVersionService.updateCustomFieldValue(id, objectCode, group);
  }

  @PostMapping(value = "/{id}/values/{objectCode}/reset")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterCustomValuesRow> undoChangesToPartsMasterObject(
    @PathVariable Long id, @PathVariable String objectCode) {
    return partsMasterVersionService.resetPartsMasterVersionByCustomFieldByObjectCode(id, objectCode);
  }

  @DeleteMapping(value = "/{id}/values/{objectCode}/{groupUUID}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public ResponseEntity<?> deleteCustomFieldGroup(
    @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    Optional<PartsMasterCustomValuesRow> partsMasterCustomValuesRow = partsMasterVersionService.deleteCustomFieldGroup(id, objectCode, groupUUID);
    if (partsMasterCustomValuesRow.isPresent()) {
      return ResponseEntity.of(partsMasterCustomValuesRow);
    }
    return ResponseEntity.noContent().build();

  }
  @PostMapping(value = "/{id}/values/{objectCode}/{groupUUID}/archive")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public Optional<PartsMasterCustomValuesRow> archiveCustomFieldGroup(
    @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    return partsMasterVersionService.archiveCustomFieldGroup(id, objectCode, groupUUID);
  }

  @GetMapping(value = "/types")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterObjectType> getPartsMasterObjectTypes() {
    return partsMasterVersionService.getPartsMasterTypes();
  }

  @GetMapping(value = "/fields/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PARTS_MASTER_ADMIN')")
  public List<PartsMasterFieldObjectType> getPartsMasterCustomFieldsByObjectCode(
    @PathVariable String objectCode) {
    return partsMasterVersionService.getPartsMasterFieldsByObjectCode(objectCode);
  }


  // todo: this is a temporary endpoint for initial parts master data intake
  @SneakyThrows
  @PostMapping(value = "/intake")
  @Transactional
  @PreAuthorize("hasRootLevelAccess()")
  public Void doCSVIntake(@RequestBody Map<String, String> body) {

    Path path = Paths.get(ClassLoader.getSystemResource("csv/" + body.get("file")).toURI());

    try (CSVReader reader = new CSVReaderBuilder(Files.newBufferedReader(path)).withSkipLines(0).build()) {

      List<Map<String, Object>> data = new ArrayList<>();
      String[] headers = reader.readNext();

      String[] dataValues;
      while ((dataValues = reader.readNext()) != null) {
        Map<String, Object> mapData = new LinkedHashMap<>();
        for (int i = 0; i < headers.length; i++) {
          mapData.put(headers[i], dataValues[i]);
        }
        data.add(mapData);
      }

      var fields = getFields(headers);

      var versionID = Long.parseLong(body.get("versionId"));
      var objectCode = body.get("objectCode");

      for (int i = 0; i < data.size(); i++) {
        Map<String, Object> row = data.get(i);

        var formattedVals = new ArrayList<PartsMasterCustomFieldValue>();

        // go through each field to see if it is a dropdown/multiselect
        Iterator<Map.Entry<String, Object>> iterator = row.entrySet()
                                                          .iterator();
        while (iterator.hasNext()) {
          Map.Entry<String, Object> field = iterator.next();

          var key = field.getKey();
          var value = field.getValue().toString();

          // skip if BRSID field. This will be auto-generated for all fields on intake
          if (Objects.equals(key, "BRSID")) {
            continue;
          }

          // skip if field is blank/empty
          if (value.isBlank()) {
            continue;
          }

          var matchedField = fields.stream()
                                   .filter(f -> Objects.equals(f.get("fieldName").toString(), key))
                                   .findFirst()
                                   .orElse(null);

          if (matchedField == null) {
            log.error("[ERROR] field: {}", key);
            throw new RuntimeException();
          }

          var dataTypeID = Long.parseLong(matchedField.get("companyDataTypeId").toString());
          var cfvMap = new LinkedHashMap<String, Object>();
          cfvMap.put("type", matchedField.get("dataType").toString());

          // dropdowns
          if (dataTypeID == 7) {

            var parentLOVID = Long.parseLong(matchedField.get("listOfValueId").toString());
            Map<String, Object> lovParams = Map.of("name", value, "parentId", parentLOVID, "createdById", 99999999L);
            final var lovID = sqlCache.queryForObjectBySql(BlueravenCustomFieldQuery.upsertListOfValue, lovParams, Long.class);

            data.get(i).put(key, lovID);
            cfvMap.put("value", value);
            cfvMap.put("intValue", lovID);

          } else if (dataTypeID == 8) {

            // multiselects
            var parentLOVID = Long.parseLong(matchedField.get("listOfValueId").toString());

            var values = Arrays.stream(value.split(",")).toList();
            var matchedValues = new ArrayList<Long>();

            // multiselect values are comma delimited. Split by comma and get lovID for each one. Recombine lovIDs into final field value
            for (String v : values) {

              // skip if value is blank/empty
              if (v.isBlank()) {
                continue;
              }

              Map<String, Object> lovParams = Map.of("name", v.trim(), "parentId", parentLOVID, "createdById", 99999999L);
              final var lovID = sqlCache.queryForObjectBySql(BlueravenCustomFieldQuery.upsertListOfValue, lovParams, Long.class);
              matchedValues.add(lovID);
            }
            data.get(i).put(key, matchedValues);
            cfvMap.put("value", values);
            cfvMap.put("intArrayValue", matchedValues);
          } else {
            cfvMap.put("value", value);
          }

          var cfv = new PartsMasterCustomFieldValue(Long.parseLong(matchedField.get("id").toString()), om.convertValue(cfvMap, JsonNode.class));
          formattedVals.add(cfv);
        }

        var group = new PartsMasterCustomGroup(formattedVals, null);
        partsMasterVersionService.updateCustomFieldValue(versionID, objectCode, group);
      }
    }
    return null;
  }

  private List<Map<String, Object>> getFields(String[] fields) {
    var query = """
      select
        cf.id,
        cf.field_name as "fieldName",
        cf.list_of_value_id as "listOfValueId",
        cf.company_data_type_id as "companyDataTypeId",
        dt.data_type as "dataType"
      from brs.custom_field cf
      inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
      inner join flow.data_type dt on dt.id = cdt.data_type_id
      where cf.field_name ilike any(array[ :fields ]) and cf.archived is false
      order by cdt.id, cf.field_name;""";

    return sqlCache.queryBySql(query, Map.of("fields", fields), new ColumnMapRowMapper());
  }
}
