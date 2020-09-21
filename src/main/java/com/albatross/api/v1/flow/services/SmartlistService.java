package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SmartlistService {

  private final SecurityService securityService;

  private final SqlCache sqlCache;

  private final ObjectMapper om;

  private final SystemListService systemListService;

  public List<Smartlist> getSmartlists() {
    return sqlCache.query("smartlist.get", null, Smartlist.class);
  }

  public Smartlist getSmartlist(Long id) {
    return sqlCache.get("smartlist.getById", Map.of("smartlistId", id), Smartlist.class).orElse(null);
  }

  public Smartlist addSmartlist(Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("name", smartlist.getName(), "companyObjectTypeId", smartlist.getCompanyObjectTypeId(), "ownerId", user.getId(), "createdById", user.getId());
    Long smartlistId = sqlCache.updateReturningId("smartlist.add", params, "id").longValue();
    return getSmartlist(smartlistId);
  }

  public void updateSmartlist(Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("id", smartlist.getId(), "name", smartlist.getName(), "companyObjectTypeId", smartlist.getCompanyObjectTypeId(), "shared", smartlist.isShared(), "userId", user.getId());
    sqlCache.update("smartlist.update", params);
  }

  public List<SmartlistFieldAssignment> getAvailableFields(Long objectTypeId) {
    List<SmartlistFieldAssignment> fields = sqlCache.query("smartlist.getAvailableFields", Map.of("companyId", securityService.getCurrentUser().getCompanyId(), "objectTypeId", objectTypeId), new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));

//    for (SmartlistFieldAssignment field : fields) {
//
//      if (field.getCustomFieldSqlKey() != null) {
//        final String sql = sqlCache.getByKey(field.getCustomFieldSqlKey());
//        if (sql != null) {
//          field.setListOfValues(sqlCache.queryBySql(sql, Collections.emptyMap(), ListOfValue.class));
//        }
//      } else if (field.getCompanySystemListId() != null) {
//        field.setListOfValues(systemListService.getSystemListOptionsForCompany(field.getCompanySystemListId(), true, field.getSystemListOptionIds()));
//      }
//    }

    return fields;
  }

    public SmartlistFieldAssignment getAvailableFieldByCfgaId(Long cfgaId) {
        SmartlistFieldAssignment field = sqlCache.get("smartlist.getAvailableFieldByCfgaId", Map.of("cfgaId", cfgaId), new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om)).orElse(null);

        if (field != null) {
            if (field.getCustomFieldSqlKey() != null) {
                final String sql = sqlCache.getByKey(field.getCustomFieldSqlKey());
                if (sql != null) {
                    field.setListOfValues(sqlCache.queryBySql(sql, Collections.emptyMap(), ListOfValue.class));
                }
            } else if (field.getCompanySystemListId() != null) {
                field.setListOfValues(systemListService.getSystemListOptionsForCompany(field.getCompanySystemListId(), true, field.getSystemListOptionIds()));
            }
        }

        return field;
    }

  public List<SmartlistFieldAssignment> getAssignedFields(Long smartlistId) {
    return sqlCache.query("smartlist.getAssignedFields", Map.of("smartlistId", smartlistId), new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
  }

  public SmartlistFieldAssignment getAssignedFieldById(Long assignmentId) {
    return sqlCache.get("smartlist.getAssignedFieldById", Map.of("id", assignmentId), SmartlistFieldAssignment.class).orElse(null);
  }

    public SmartlistRequirement getRequirementById(Long requirementId) {
        SmartlistRequirement requirement =  sqlCache.get("smartlist.getRequirementById", Map.of("requirementId", requirementId), new SmartlistRequirementMapper<>(SmartlistRequirement.class, om)).orElse(null);

        if (requirement != null && requirement.getCustomFieldSqlKey() != null) {
            final String sql = sqlCache.getByKey(requirement.getCustomFieldSqlKey());
            if (sql != null) {
                requirement.setAvailableListOfValues(sqlCache.queryBySql(sql, null, ListOfValue.class));
            }
        }

        return requirement;
    }

  public List<SmartlistLogic> getLogic(Long smartlistId) {
    return sqlCache.query("smartlist.getLogic", Map.of("smartlistId", smartlistId), SmartlistLogic.class);
  }

  @Transactional
  public List<SmartlistLogic> updateLogic(Long smartlistId, List<SmartlistLogic> logic) {
    User user = securityService.getCurrentUser();
    sqlCache.update("smartlist.archiveLogic", Map.of("smartlistId", smartlistId, "userId", user.getId()));

    if (!logic.isEmpty()) {
      HashMap<String, Object> params = null;
      int counter = 0;
      for (SmartlistLogic l : logic) {
        params = om.convertValue(l, HashMap.class);
        params.put("userId", user.getId());
        params.put("sqlOrder", counter++);
        sqlCache.update("smartlist.updateLogic", params);
      }
    }

    return this.getLogic(smartlistId);
  }

  public SmartlistFieldAssignment addField(SmartlistFieldAssignment assignment) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("smartlistId", assignment.getSmartlistId());
    params.put("smartlistFieldId", assignment.getSmartlistFieldId());
    params.put("customFieldGroupAssignmentId", assignment.getCustomFieldGroupAssignmentId());
    params.put("displayOrder", assignment.getDisplayOrder());
    params.put("createdById", user.getId());
    params.put("processStepId", assignment.getProcessStepId());
    Long assignmentId = sqlCache.updateReturningId("smartlist.addField", params, "id").longValue();
    return this.getAssignedFieldById(assignmentId);
  }

  public SmartlistRequirement addRequirement(Long smartlistId, SmartlistRequirement requirement) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = om.convertValue(requirement, HashMap.class);
    params.put("userId", user.getId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    Long requirementId = sqlCache.updateReturningId("smartlist.addRequirement", params, "id").longValue();
    return getRequirementById(requirementId);
  }

  public SmartlistRequirement updateRequirement(SmartlistRequirement requirement) {
    HashMap<String, Object> params = om.convertValue(requirement, HashMap.class);
    params.put("userId", securityService.getCurrentUser().getId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    sqlCache.update("smartlist.updateRequirement", params);
    return getRequirementById(requirement.getId());
  }

  public void deleteRequirement(Long requirementId) {
    sqlCache.update("smartlist.deleteRequirement", Map.of("requirementId", requirementId, "userId", securityService.getCurrentUser().getId()));
  }

  public void deleteFieldAssignment(Long fieldId) {
    sqlCache.update("smartlist.deleteField", Map.of("id", fieldId, "userId", securityService.getCurrentUser().getId()));
  }

  public void updateDisplayOrder(List<SmartlistFieldAssignment> fields) {
    fields.forEach(field -> {
      sqlCache.update("smartlist.updateDisplayOrder", Map.of("id", field.getId(), "displayOrder", field.getDisplayOrder(), "userId", securityService.getCurrentUser().getId()));
    });
  }

  public List<SmartlistRequirement> getRequirements(Long smartlistId) {
    List<SmartlistRequirement> requirements =  sqlCache.query("smartlist.getRequirements", Map.of("smartlistId", smartlistId, "companyId", securityService.getCurrentUser().getCompanyId()), new SmartlistRequirementMapper<>(SmartlistRequirement.class, om));

//    for (SmartlistRequirement r : requirements) {
//        if (r.getCustomFieldSqlKey() != null) {
//            final String sql = sqlCache.getByKey(r.getCustomFieldSqlKey());
//            if (sql != null) {
//                r.setAvailableListOfValues(sqlCache.queryBySql(sql, null, ListOfValue.class));
//            }
//        }
//    }

    return requirements;
  }

  public List<Smartlist> getSharedByType(Long objectTypeId) {
      User user = securityService.getCurrentUser();
      return sqlCache.query("project.getSharedByObjectType", Map.of("companyId", user.getCompanyId(), "objectTypeId", objectTypeId, "userId", user.getId()), Smartlist.class);
  }

  public SmartlistResult getSmartlistResults(Long smartlistId) {
      final String query = buildSql(smartlistId);
      List<SmartlistFieldAssignment> fields = this.getAssignedFields(smartlistId);
      List<Map<String, Object>> results = sqlCache.queryBySql(query, null, new ColumnMapRowMapper());

      return new SmartlistResult(fields, results);
  }

  public String getCsv(Long smartlistId) {
      final String query = buildSql(smartlistId);
      List<Map<String, Object>> results = sqlCache.queryBySql(query, null, new ColumnMapRowMapper());
      List<SmartlistFieldAssignment> fields = this.getAssignedFields(smartlistId);
      ArrayList<String> dateFields = new ArrayList<>();

      for(SmartlistFieldAssignment field : fields) {
         if (field.getDataTypeId() == 1) {
             dateFields.add(field.getName());
         }
  }

      return writeCsv(results, fields, dateFields);
  }

  public String buildSql(Long smartlistId) {

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    Smartlist smartlist = this.getSmartlist(smartlistId);
    if (smartlist == null) {
      return null;
    }

    //@TODO humes: grab custom field sql key stuff here to account for custom custom fields
    List<SmartlistFieldAssignment> fields = this.getAssignedFields(smartlistId);
    List<SmartlistRequirement> requirements = this.getRequirements(smartlistId);

    List<SmartlistFieldAssignment> joinTables = new ArrayList<>();

    StringBuilder withClause = new StringBuilder();

    StringBuilder query = new StringBuilder("select");

    for (SmartlistFieldAssignment f : fields) {

      final boolean isSystemProcessStepField = f.getCustomFieldGroupAssignmentId() == null && f.getProcessStepId() != null;
      final boolean isCustomSqlField = f.getCustomFieldSqlKey() != null && withClause.indexOf(f.getCustomFieldSqlKey()) == -1;

      if (f.getCustomFieldGroupAssignmentId() != null && joinTables.stream().noneMatch(t -> t.getId().equals(f.getId()))) {
          // When the field is custom (has a cfgaId), reference table will be a UUID to keep track of that specific relationship/join
          f.setReferenceTable(UUID.randomUUID().toString());

          // If field is a system list, we need the int_value from the object value table to get the actual display value (name column) from the with clause
          if (f.getSystemListTypeId() != null) {
              f.setValueReferenceTable(UUID.randomUUID().toString());
          }
          joinTables.add(f);
      } else if (isSystemProcessStepField) {

          // When the field is system but has a process step ID, reference table will be a UUID to keep track of that specific relationship/join to the same process step
          if (joinTables.stream().noneMatch(t -> t.getProcessStepId().equals(f.getProcessStepId()))) {
              f.setReferenceTable(UUID.randomUUID().toString());
              joinTables.add(f);
          } else {
              final String uuid = joinTables.stream()
                  .filter(t -> t.getProcessStepId().equals(f.getProcessStepId()))
                  .map(SmartlistFieldAssignment::getReferenceTable)
                  .findFirst()
                  .orElse(null);

              f.setReferenceTable(uuid);
          }
      }

      String location;

      final String referenceTable = joinTables.stream().filter(t -> t.getCustomFieldGroupAssignmentId().equals(f.getCustomFieldGroupAssignmentId())).map(SmartlistFieldAssignment::getReferenceTable).findFirst().orElse(null);

      // If field is custom, else it's system
      if (f.getCustomFieldGroupAssignmentId() != null && referenceTable != null) {
        final String column = ((f.getHasListValues() != null && f.getHasListValues() && !f.getAllowMultiple()) || f.getCustomFieldSqlKey() != null) ? "name" : getReferenceColumn(f.getDataTypeId());
        location = String.format("\"%s\".%s", referenceTable, column);
      } else {
          if (isSystemProcessStepField) {
              location = String.format("\"%s\".%s", f.getReferenceTable(), f.getReferenceColumn());
          } else {
              location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
          }

      }

      if (f.getDataTypeId() == 1 || f.getDataTypeId() == 2) {
        query.append(String.format(" %s as \"%s\",", location, f.getName()));
      } else if (f.getDataTypeId() == 7) {
          query.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s)), ',')) as \"%s\", ", location, f.getName()));
      } else if (f.getDataTypeId() == 9) {
          final String tempUuid = UUID.randomUUID().toString();
          final String subQuery = String.format("select * from flow.get_system_list_options(%s::int, %s::int, true, array%s::int[], \"%s\".int_value)", companyId, f.getCompanySystemListId(), f.getCustomField().getSystemListOptionIds(), f.getValueReferenceTable());
          final String sql = String.format(" (select \"%s\".name from (%s) as \"%s\" where \"%s\".id = \"%s\".int_value) as \"%s\", ", tempUuid, subQuery, tempUuid, tempUuid, f.getValueReferenceTable(), f.getName());
          query.append(sql);
      } else {
        query.append(String.format(" %s as \"%s\", ", location, f.getName()));
      }



      if (isCustomSqlField) {
          withClause.append(String.format(" \"%s\" as  (%s), ", f.getCustomFieldSqlKey(), sqlCache.getByKey(f.getCustomFieldSqlKey())));
      }
    }

    // Remove comma and space from last select field
    query.deleteCharAt(query.length() - 1);
    query.deleteCharAt(query.length() - 1);

    switch (smartlist.getObjectTypeId().intValue()) {
      case 1:
        query.append(" from flow.project ");

        query.append("left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");

          for (SmartlistFieldAssignment field: joinTables) {

              final Long objectTypeId = field.getObjectTypeId();
              final Boolean hasListValues = field.getHasListValues();
              final String customFieldSqlKey = field.getCustomFieldSqlKey();
              final Boolean allowMultiple = field.getAllowMultiple();
              final Long processStepId = field.getProcessStepId();
              final Long cfgaId = field.getCustomFieldGroupAssignmentId();
              String uuid;

              if (field.getSystemListTypeId() != null) {
                  uuid = field.getValueReferenceTable();
              } else {
                  uuid = field.getReferenceTable();
              }

          switch (objectTypeId.intValue()) {
            case 1:
              if (hasListValues || customFieldSqlKey != null) {

                final String pcfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));

                if (customFieldSqlKey != null) {
                    //custom value sql
                    query.append(String.format("left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", customFieldSqlKey, uuid, uuid, pcfvUUID));
                } else {
                    query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
                }
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 2:
              if (hasListValues || customFieldSqlKey != null) {

                final String ccfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));

                if (customFieldSqlKey != null) {
                    query.append(String.format("left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", customFieldSqlKey, uuid, uuid, ccfvUUID));
                } else {
                    query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
                }
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 4:
              final String ppsUUID = UUID.randomUUID().toString();

              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));

              if (hasListValues) {
                if (allowMultiple) {
                    query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
                } else {
                    final String ppscfvUUID = UUID.randomUUID().toString();
                    query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
                    query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
                }
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
              }

              break;
          }
        }
        break;
//      case 2:
//        query.append(" from flow.contact ");
//
//        query.append("left join flow.project on flow.project.contact_id = flow.contact.id ");
//
//        // join tables from object types which aren't the same as the report object type (used in `from` clause)
//        for (Map.Entry<Long, List<Object>> entry : joinObjectTypes.entrySet()) {
//          final Long cfgaId = entry.getKey();
//          List<Object> vals = entry.getValue();
//          final String uuid = vals.get(0).toString();
//          final Long objectTypeId = Long.parseLong(vals.get(1).toString());
//          final Boolean hasListValues = Boolean.parseBoolean((vals.get(3) == null) ? "false" : vals.get(3).toString());
//
//          switch (objectTypeId.intValue()) {
//            case 1:
//              if (hasListValues) {
//                final String pcfvUUID = UUID.randomUUID().toString();
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
//                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
//              } else {
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
//              }
//              break;
//            case 2:
//              if (hasListValues) {
//                final String ccfvUUID = UUID.randomUUID().toString();
//                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));
//                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
//              } else {
//                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
//              }
//              break;
//            case 4:
//              // @TODO: possibly check for vals.get(2) being null even though it "shouldn't" ever happen here
//              final Long processStepId = Long.parseLong(vals.get(2).toString());
//              final String ppsUUID = UUID.randomUUID().toString();
//
//              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));
//
//              if (hasListValues) {
//                final String ppscfvUUID = UUID.randomUUID().toString();
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
//                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
//              } else {
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
//              }
//
//              break;
//          }
//        }
//        break;
//      case 4:
//        query.append(" from flow.project_process_step ");
//
//        query.append("left join flow.process_step on flow.process_step.id = flow.project_process_step.process_step_id ");
//        query.append("left join flow.project on flow.project.id = flow.project_process_step.project_id ");
//        query.append("left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
//
//        // join tables from object types which aren't the same as the report object type (used in `from` clause)
//        for (Map.Entry<Long, List<Object>> entry : joinObjectTypes.entrySet()) {
//          final Long cfgaId = entry.getKey();
//          List<Object> vals = entry.getValue();
//          final String uuid = vals.get(0).toString();
//          final Long objectTypeId = Long.parseLong(vals.get(1).toString());
//          final Boolean hasListValues = Boolean.parseBoolean((vals.get(3) == null) ? "false" : vals.get(3).toString());
//
//          switch (objectTypeId.intValue()) {
//            case 1:
//              if (hasListValues) {
//                final String pcfvUUID = UUID.randomUUID().toString();
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
//                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
//              } else {
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
//              }
//              break;
//            case 2:
//              if (hasListValues) {
//                final String ccfvUUID = UUID.randomUUID().toString();
//                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));
//                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
//              } else {
//                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
//              }
//              break;
//            case 4:
//              // @TODO: possibly check for vals.get(2) being null even though it "shouldn't" ever happen here
//              final Long processStepId = Long.parseLong(vals.get(2).toString());
//              final String ppsUUID = UUID.randomUUID().toString();
//
//              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));
//
//              if (hasListValues) {
//                final String ppscfvUUID = UUID.randomUUID().toString();
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
//                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
//              } else {
//                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
//              }
//
//              break;
//          }
//        }
//        break;
    }

    StringBuilder additionalJoins = new StringBuilder();
    StringBuilder whereClause = new StringBuilder();

    // @TODO humes, add "with" tables in additional joins
      for (SmartlistRequirement r : requirements) {
          String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

          String referenceLocation = "";

          if (r.getCustomFieldGroupAssignmentId() != null) {

              String referenceColumn = ((r.getHasListValues() != null && r.getHasListValues() && !r.getAllowMultiple()) || r.getCustomFieldSqlKey() != null) ? "id" : getReferenceColumn(r.getDataTypeId());

              // see if table we need is already been joined, if so use it
              // @TODO humes, probably want to also check processStepId here is objectTypeId == 4
              final String referenceTable = joinTables.stream()
                  .filter(t -> t.getCustomFieldGroupAssignmentId().equals(r.getCustomFieldGroupAssignmentId()))
                  .map(t -> {
                      if (t.getValueReferenceTable() != null) {
                          return t.getValueReferenceTable();
                      } else {
                          return t.getReferenceTable();
                      }
                  })
                  .findFirst()
                  .orElse(null);

              if (referenceTable != null) {
                  //Only put quotes around table when dataTypeId == 7
                  referenceLocation = "\"" + referenceTable + "\"." + referenceColumn;
              } else {
                  // @TODO humes, need to get rest of the object types here
                  // Do a new join from custom field value table based on object type
                  if (r.getObjectTypeId() == 4) {
                      final String ppsUUID = UUID.randomUUID().toString();
                      final String ppscfvUUID = UUID.randomUUID().toString();
                      additionalJoins.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, r.getProcessStepId()));
                      additionalJoins.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, r.getCustomFieldGroupAssignmentId()));
                      // @TODO humes, reference column changes if field is a list or not.
                      referenceLocation = "\"" + ppscfvUUID + "\"." + referenceColumn;
                  } else {
                      final String newUuid = UUID.randomUUID().toString();

                      if (r.getCustomFieldSqlKey() != null) {

//                          query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
//                          query.append(String.format("left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", customFieldSqlKey, uuid, uuid, pcfvUUID));

                          additionalJoins.append(String.format("left join \"%s\" \"%s\" on \"%s\".id = %s", r.getCustomFieldSqlKey(), newUuid, newUuid, r.getListOfValueId()));
                          referenceLocation = "\"" + newUuid + "\".id";
                      } else {
                          additionalJoins.append(String.format("left join %s \"%s\"", getReferenceTable(r.getObjectTypeId()), newUuid));
                          referenceLocation = "\"" + newUuid + "\"." + referenceColumn;
                      }
                  }
              }
          } else {
              referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
          }

          Object requirementValue = getRequirementValue(r);

          // Check for a double negative between the operator and data type requirement value, the user might make a requirement like this for whatever reason
          if (!r.getIsCustomValue() && r.getOperatorTypeId() == 2 && requirementValue.toString().startsWith("not ")) {
              operator = operator.replace("not", "");
              requirementValue = requirementValue.toString().replace("not ", "");
          }

          // date, timestamp, and text (text only when it's a custom value) data types need single quotes around them
          if ((List.of(1L, 2L).contains(r.getDataTypeId())) || r.getDataTypeId() == 5 && r.getIsCustomValue()) {
              requirementValue = String.format("'%s'", requirementValue);
          } else if (r.getDataTypeId() == 9) {
              requirementValue = r.getListOfValueId();
          }

          if (r.getDataTypeId() == 7) {
              whereClause.append(String.format("sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
          } else {
              whereClause.append(String.format("%s %s %s and ", referenceLocation, operator, requirementValue));
          }
      }

    if (withClause.length() > 0) {
        // Remove comma and space from last with table
        withClause.deleteCharAt(withClause.length() - 1);
        withClause.deleteCharAt(withClause.length() - 1);

        query.insert(0, "with " + withClause.toString());
    }

    query.append(additionalJoins.toString());

    if (whereClause.length() > 0) {
        query.append(" where ").append(whereClause.toString());

        // remove the last "and "
        query = query.delete(query.length() - 5, query.length());
    }

    query.append(";");

    log.info(query.toString());

    return query.toString();
  }

  private String writeCsv(List<Map<String, Object>> data, List<SmartlistFieldAssignment> headers, ArrayList<String> dateFields) {
    CsvSchema.Builder builder = CsvSchema.builder();

    // Dates have to be set as string, else when written to buffer, they display as epoch milli
    for (int i = 0; i < data.size(); i++) {
      Map<String, Object> r = data.get(i);

      for (String field : dateFields) {
        r.put(field, (r.get(field) == null) ? "N/A" : r.get(field).toString());
      }
      data.set(i, r);
    }

    for (SmartlistFieldAssignment f : headers) {
      builder.addColumn(f.getName(), CsvSchema.ColumnType.NUMBER_OR_STRING);
    }

    CsvSchema schema = builder.build().withHeader();
    ObjectWriter w = new CsvMapper().writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    try (SequenceWriter toBuffer = w.writeValues(buffer)) {
      toBuffer.writeAll(data);
      toBuffer.flush();
      return buffer.toString(StandardCharsets.UTF_8);
    } catch (IOException e) {
      return null;
    }
  }

  private String getReferenceTable(Long objectTypeId) {
    switch (objectTypeId.intValue()) {
      case 1:
        return "flow.project_custom_field_value";
      case 2:
        return "flow.contact_custom_field_value";
      case 3:
        return "flow.user_custom_field_value";
      case 4:
        return "flow.project_process_step_custom_field_value";
      case 5:
        return "flow.organization_custom_field_value";
      default:
        return "";
    }
  }

    private String getReferenceColumn(Long dataTypeId) {
        switch (dataTypeId.intValue()) {
            case 1:
                return "date_value";
            case 2:
                return "timestamp_value";
            case 3:
                return "boolean_value";
            case 4:
                return "numeric_value";
            case 5:
                return "text_value";
            case 6:
            case 9:
                return "int_value";
            case 7:
                return "int_array_value";
            case 8:
                //@TODO: figure system value
                return "";
            default:
                return "";
        }
    }

    //@TODO humes: similar enough to project process step requirement stuff that should probably be merged at some point
    private Object getRequirementValue(SmartlistRequirement r) {

        String requirementValue = r.getRequirementValue();

        switch (r.getDataTypeId().intValue()) {
            case 1:
                if (r.getIsCustomValue()) {
                    LocalDate dateValue = (requirementValue != null) ? LocalDate.parse(requirementValue) : null;
                    return dateValue;
                }

                LocalDate nowDate = LocalDate.now();
                String secondaryDateValue = r.getSecondaryRequirementValue();

                //@TODO: format dates for sql query when returning
                switch (r.getDataTypeRequirementId().intValue()) {
                    case 1:
                        return nowDate.minusDays(Long.parseLong(secondaryDateValue));
                    case 2:
                        return nowDate.plusDays(Long.parseLong(secondaryDateValue));
                    case 3:
                        return nowDate;
                    case 4:
                    case 5:
                        return r.getDataTypeRequirement().getDataTypeValue();
                }
                break;
            case 2:
                if (r.getIsCustomValue()) {
                    LocalDateTime dateTimeValue = (requirementValue != null) ? LocalDateTime.parse(requirementValue).withSecond(0).withNano(0) : null;
                    return dateTimeValue;
                }

                LocalDateTime nowDateTime = LocalDateTime.now().withMinute(0).withSecond(0).withNano(0);
                String secondaryDateTimeValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

                switch (r.getDataTypeRequirementId().intValue()) {
                    case 6:
                        return nowDateTime.minusDays(Long.parseLong(secondaryDateTimeValue));
                    case 7:
                        return nowDateTime.plusDays(Long.parseLong(secondaryDateTimeValue));
                    case 8:
                        return nowDateTime.withHour(0);
                    case 9:
                        return nowDateTime.minusHours(Long.parseLong(secondaryDateTimeValue));
                    case 10:
                        return nowDateTime.plusHours(Long.parseLong(secondaryDateTimeValue));
                    case 11:
                        return nowDateTime;
                    case 12:
                    case 13:
                        return r.getDataTypeRequirement().getDataTypeValue();
                }
                break;

            case 3:
                return r.getDataTypeRequirement().getDataTypeValue();
            case 4:
                if (r.getIsCustomValue()) {
                    BigDecimal tempNumericVal = (requirementValue == null) ? null : new BigDecimal(requirementValue);
                    Double numericReqValue = (tempNumericVal == null) ? null : tempNumericVal.setScale(2, RoundingMode.DOWN).doubleValue();
                    return numericReqValue;
                }

                return r.getDataTypeRequirement().getDataTypeValue();
            case 5:
                if (r.getIsCustomValue()) {
                    return requirementValue;
                }
                return r.getDataTypeRequirement().getDataTypeValue();
            case 6:
                if (r.getIsCustomValue()) {
                    return (r.getHasListValues() && r.getListOfValueId() != null) ? r.getListOfValueId() : Long.parseLong(requirementValue);
                }
                return r.getDataTypeRequirement().getDataTypeValue();
            case 7:
                if (r.getIsCustomValue()) {
                    return r.getListOfValueIds();
                }
                return r.getDataTypeRequirement().getDataTypeValue();
            case 8:
                return r.getListOfValueId();
            default:
                return null;
        }
        return null;
    }

  private String getSqlOperator(Long operatorTypeId, Long dataTypeId, DataTypeRequirement r) {

    // List of whether the dataTypeRequirementId is being compared to `null` or `not null`
    List<Long> nullableIds = List.of(4L, 5L, 12L, 13L, 16L, 17L, 18L, 19L, 20L, 21L, 22L, 23L, 24L, 25L, 26L, 27L);

    switch (operatorTypeId.intValue()) {
      case 1:
          if (dataTypeId == 3) {
              return "is";
          } else {
              return (r != null && nullableIds.contains(r.getId())) ? "is" : "=";
          }
      case 2:
        if (dataTypeId == 3) {
            return "is not";
        } else {
            return (r != null && nullableIds.contains(r.getId())) ? "is not" : "!=";
        }
      case 3:
        return ">";
      case 4:
        return "<";
      case 5:
        return "<@";
      default:
        //@TODO: blow up?
        return null;
    }
  }

  public static class SmartlistRequirementMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper om;

    public SmartlistRequirementMapper(Class<T> mappedClass, ObjectMapper objectMaper) {
      super(mappedClass);
      this.om = objectMaper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<DataTypeRequirement> dataTypeRequirementRef = new TypeReference<>() {};
      bw.registerCustomEditor(Object.class, "dataTypeRequirement", new JsonCollectionDeserializer(dataTypeRequirementRef, om));

      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "listOfValues", new JsonCollectionDeserializer(listOfValueRef, om));

      TypeReference<List<Integer>> listOfValueIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "listOfValueIds", new JsonCollectionDeserializer(listOfValueIdsRef, om));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "systemListOptionIds", new JsonCollectionDeserializer(systemListOptionIdsRef, om));

      TypeReference<List<ListOfValue>> availableListOfValuesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "availableListOfValues", new JsonCollectionDeserializer(availableListOfValuesRef, om));

        TypeReference<CustomField> customFieldRef = new TypeReference<>() {};
        bw.registerCustomEditor(Object.class, "customField", new JsonCollectionDeserializer(customFieldRef, om));
    }
  }

  public static class SmartlistFieldAssignmentMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper om;

    public SmartlistFieldAssignmentMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.om = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ListOfValue>> listOfValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "listOfValues", new JsonCollectionDeserializer(listOfValueRef, om));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "systemListOptionIds", new JsonCollectionDeserializer(systemListOptionIdsRef, om));

        TypeReference<CustomField> customFieldRef = new TypeReference<>() {};
        bw.registerCustomEditor(Object.class, "customField", new JsonCollectionDeserializer(customFieldRef, om));
    }
  }
}
