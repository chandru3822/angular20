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
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
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

    for (SmartlistFieldAssignment field : fields) {

      if (field.getCustomFieldSqlKey() != null) {
        final String sql = sqlCache.getByKey(field.getCustomFieldSqlKey());
        if (sql != null) {
          field.setListOfValues(sqlCache.queryBySql(sql, Collections.emptyMap(), ListOfValue.class));
        }
      } else if (field.getCompanySystemListId() != null) {
        field.setListOfValues(systemListService.getSystemListOptionsForCompany(field.getCompanySystemListId(), true, field.getSystemListOptionIds()));
      }
    }

    return fields;
  }

  public List<SmartlistFieldAssignment> getAssignedFields(Long smartlistId) {
    return sqlCache.query("smartlist.getAssignedFields", Map.of("smartlistId", smartlistId), SmartlistFieldAssignment.class);
  }

  public SmartlistFieldAssignment getAssignedFieldById(Long assignmentId) {
    return sqlCache.get("smartlist.getAssignedFieldById", Map.of("id", assignmentId), SmartlistFieldAssignment.class).orElse(null);
  }

  public SmartlistRequirement getRequirementById(Long requirementId) {
    return sqlCache.get("smartlist.getRequirementById", Map.of("requirementId", requirementId), new SmartlistRequirementMapper<>(SmartlistRequirement.class, om)).orElse(null);
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
    Long requirementId = sqlCache.updateReturningId("smartlist.addRequirement", params, "id").longValue();
    return this.getRequirementById(requirementId);
  }

  public SmartlistRequirement updateRequirement(SmartlistRequirement requirement) {
    HashMap<String, Object> params = om.convertValue(requirement, HashMap.class);
    params.put("userId", securityService.getCurrentUser().getId());
    sqlCache.update("smartlist.updateRequirement", params);
    return sqlCache.get("smartlist.getRequirementById", Map.of("requirementId", requirement.getId()), new SmartlistRequirementMapper<>(SmartlistRequirement.class, om)).orElse(null);
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
    return sqlCache.query("smartlist.getRequirements", Map.of("smartlistId", smartlistId, "companyId", securityService.getCurrentUser().getCompanyId()), new SmartlistRequirementMapper<>(SmartlistRequirement.class, om));
  }

  public String generate(Long smartlistId) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("smartlistId", smartlistId);
    Smartlist smartlist = sqlCache.get("smartlist.getById", params, Smartlist.class).orElse(null);
    if (smartlist == null) {
      return null;
    }

    //@TODO humes: grab custom field sql key stuff here to account for custom custom fields
    List<SmartlistFieldAssignment> fields = sqlCache.query("smartlist.getAssignedFields", params, SmartlistFieldAssignment.class);
    List<SmartlistRequirement> requirements = sqlCache.query("smartlist.getRequirements", params, new SmartlistRequirementMapper<>(SmartlistRequirement.class, om));

    // Map storing custom field group assignment ID as key,
    // - value 0: a UUID alias for the join table
    // - value 1: object type ID
    // - value 2: process step ID
    // - value 3: hasListValue (from company_data_type)
    HashMap<Long, List<Object>> joinObjectTypes = new HashMap<>();

    ArrayList<String> dateFields = new ArrayList<>();
    StringBuilder query = new StringBuilder("select");


    for (SmartlistFieldAssignment f : fields) {

      final Long fieldObjectTypeId = f.getObjectTypeId();
      final boolean checkCfgaId = f.getCustomFieldGroupAssignmentId() != null && !joinObjectTypes.containsKey(f.getCustomFieldGroupAssignmentId());

      if (checkCfgaId) {

        List<Object> mapVals = new ArrayList<>();
        mapVals.add(UUID.randomUUID());
        mapVals.add(f.getObjectTypeId());
        mapVals.add(f.getProcessStepId());
        mapVals.add(f.getHasListValues());

        joinObjectTypes.put(f.getCustomFieldGroupAssignmentId(), mapVals);
      }

      String location;

      if (f.getCustomFieldGroupAssignmentId() != null && joinObjectTypes.containsKey(f.getCustomFieldGroupAssignmentId())) {
        final String table = joinObjectTypes.get(f.getCustomFieldGroupAssignmentId()).get(0).toString();
        final String column = (f.getHasListValues() != null && f.getHasListValues()) ? "name" : getReferenceColumn(f.getDataTypeId());
        location = String.format("\"%s\".%s", table, column);
      } else {
        location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
      }


      if (f.getDataTypeId() == 1) {
        query.append(String.format(" date(%s) as \"%s\",", location, f.getName()));
        dateFields.add(f.getName());
      } else {
        query.append(String.format(" %s as \"%s\",", location, f.getName()));
      }
    }

    // Remove comma from last select field
    query.deleteCharAt(query.length() - 1);

    switch (smartlist.getObjectTypeId().intValue()) {
      case 1:
        query.append(" from flow.project ");

        //@TODO humes: optimizing, Only join these tables if a field uses them
        query.append("left join flow.user_position on flow.user_position.id = flow.project.user_position_id and flow.user_position.archived is not true ");
        query.append("left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
        query.append("left join flow.user on flow.user.id = flow.user_position.user_id and flow.user.archived is not true ");
        query.append("left join flow.org on flow.org.id = flow.user_position.org_id and flow.org.archived is not true ");


        // @TODO humes: Go through each smartlist.objectTypeId case use the main user_position join for all the other user_position joins if it makes sense. I think I'm making a few unnecessary join to user_position.
        // objectTypeId 1 is done

        // join tables from object types which aren't the same as the report object type (used in `from` clause)
        for (Map.Entry<Long, List<Object>> entry : joinObjectTypes.entrySet()) {
          final Long cfgaId = entry.getKey();
          List<Object> vals = entry.getValue();
          final String uuid = vals.get(0).toString();
          final Long objectTypeId = Long.parseLong(vals.get(1).toString());
          final Boolean hasListValues = Boolean.parseBoolean((vals.get(3) == null) ? "false" : vals.get(3).toString());

          switch (objectTypeId.intValue()) {
            case 1:
              if (hasListValues) {
                final String pcfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 2:
              if (hasListValues) {
                final String ccfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 3:
              if (hasListValues) {
                final String ucfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = flow.user_position.user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ucfvUUID, ucfvUUID, ucfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ucfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = flow.user_position.user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 4:
              // @TODO: possibly check for vals.get(2) being null even though it "shouldn't" ever happen here
              final Long processStepId = Long.parseLong(vals.get(2).toString());
              final String ppsUUID = UUID.randomUUID().toString();

              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));

              if (hasListValues) {
                final String ppscfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
              }

              break;
            case 5:

              if (hasListValues) {
                final String ocfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = flow.user_position.org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ocfvUUID, ocfvUUID, ocfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ocfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = flow.user_position.org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
          }
        }
        break;
      case 2:
        query.append(" from flow.contact ");

        query.append("left join flow.user_position on flow.user_position.id = flow.contact.owner_user_position_id ");
        query.append("left join flow.project on flow.project.contact_id = flow.contact.id ");
        query.append("left join flow.user on flow.user.id = flow.user_position.user_id and flow.user.archived is not true ");
        query.append("left join flow.org on flow.org.id = flow.user_position.org_id and flow.org.archived is not true ");

        // join tables from object types which aren't the same as the report object type (used in `from` clause)
        for (Map.Entry<Long, List<Object>> entry : joinObjectTypes.entrySet()) {
          final Long cfgaId = entry.getKey();
          List<Object> vals = entry.getValue();
          final String uuid = vals.get(0).toString();
          final Long objectTypeId = Long.parseLong(vals.get(1).toString());
          final Boolean hasListValues = Boolean.parseBoolean((vals.get(3) == null) ? "false" : vals.get(3).toString());

          switch (objectTypeId.intValue()) {
            case 1:
              if (hasListValues) {
                final String pcfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 2:
              if (hasListValues) {
                final String ccfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 3:
              final String upUUID = UUID.randomUUID().toString();

              if (hasListValues) {
                final String ucfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", upUUID, upUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = \"%s\".user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ucfvUUID, ucfvUUID, upUUID, ucfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ucfvUUID));
              } else {
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", upUUID, upUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = \"%s\".user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, upUUID, uuid, cfgaId));
              }
              break;
            case 4:
              // @TODO: possibly check for vals.get(2) being null even though it "shouldn't" ever happen here
              final Long processStepId = Long.parseLong(vals.get(2).toString());
              final String ppsUUID = UUID.randomUUID().toString();

              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));

              if (hasListValues) {
                final String ppscfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
              }

              break;
            case 5:
              final String userPositionUUID = UUID.randomUUID().toString();

              if (hasListValues) {
                final String ocfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", userPositionUUID, userPositionUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = \"%s\".org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ocfvUUID, ocfvUUID, userPositionUUID, ocfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ocfvUUID));
              } else {
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", userPositionUUID, userPositionUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = \"%s\".org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, userPositionUUID, uuid, cfgaId));
              }
              break;
          }
        }
        break;
      case 3:
        query.append(" from flow.user ");

        query.append("left join flow.user_position on flow.user_position.user_id = flow.user.id and flow.user_position.archived is not true ");
        query.append("left join flow.project on flow.project.user_position_id = flow.user_position.id ");
        query.append("left join flow.contact on flow.contact.owner_user_position_id = flow.user_position.id and flow.contact.archived is not true ");
        query.append("left join flow.org on flow.org.id = flow.user_position.org_id and flow.org.archived is not true ");

        // join tables from object types which aren't the same as the report object type (used in `from` clause)
        for (Map.Entry<Long, List<Object>> entry : joinObjectTypes.entrySet()) {
          final Long cfgaId = entry.getKey();
          List<Object> vals = entry.getValue();
          final String uuid = vals.get(0).toString();
          final Long objectTypeId = Long.parseLong(vals.get(1).toString());
          final Boolean hasListValues = Boolean.parseBoolean((vals.get(3) == null) ? "false" : vals.get(3).toString());

          switch (objectTypeId.intValue()) {
            case 1:
              if (hasListValues) {
                final String pcfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 2:
              if (hasListValues) {
                final String ccfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 3:
              final String upUUID = UUID.randomUUID().toString();

              if (hasListValues) {
                final String ucfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", upUUID, upUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = \"%s\".user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ucfvUUID, ucfvUUID, upUUID, ucfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ucfvUUID));
              } else {
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", upUUID, upUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = \"%s\".user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, upUUID, uuid, cfgaId));
              }
              break;
            case 4:
              // @TODO: possibly check for vals.get(2) being null even though it "shouldn't" ever happen here
              final Long processStepId = Long.parseLong(vals.get(2).toString());
              final String ppsUUID = UUID.randomUUID().toString();

              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));

              if (hasListValues) {
                final String ppscfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
              }

              break;
            case 5:
              final String userPositionUUID = UUID.randomUUID().toString();

              if (hasListValues) {
                final String ocfvUUID = UUID.randomUUID().toString();
                //@TODO: already joining to user_position. Should remove this extraneous join
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", userPositionUUID, userPositionUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = \"%s\".org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ocfvUUID, ocfvUUID, userPositionUUID, ocfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ocfvUUID));
              } else {
                //@TODO: already joining to user_position. Should remove this extraneous join
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", userPositionUUID, userPositionUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = \"%s\".org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, userPositionUUID, uuid, cfgaId));
              }
              break;
          }
        }
        break;
      case 4:
        query.append(" from flow.project_process_step ");

        query.append("left join flow.process_step on flow.process_step.id = flow.project_process_step.process_step_id ");

        query.append("left join flow.user_position on flow.user_position.id = flow.project_process_step.user_position_id and flow.user_position.archived is not true ");
        query.append("left join flow.project on flow.project.id = flow.project_process_step.project_id ");
        query.append("left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
        query.append("left join flow.user on flow.user.id = flow.user_position.user_id and flow.user.archived is not true ");
        query.append("left join flow.org on flow.org.id = flow.user_position.org_id and flow.org.archived is not true ");

        // join tables from object types which aren't the same as the report object type (used in `from` clause)
        for (Map.Entry<Long, List<Object>> entry : joinObjectTypes.entrySet()) {
          final Long cfgaId = entry.getKey();
          List<Object> vals = entry.getValue();
          final String uuid = vals.get(0).toString();
          final Long objectTypeId = Long.parseLong(vals.get(1).toString());
          final Boolean hasListValues = Boolean.parseBoolean((vals.get(3) == null) ? "false" : vals.get(3).toString());

          switch (objectTypeId.intValue()) {
            case 1:
              if (hasListValues) {
                final String pcfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 2:
              if (hasListValues) {
                final String ccfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 3:
              if (hasListValues) {
                final String ucfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = flow.user_position.user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ucfvUUID, ucfvUUID, ucfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ucfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = flow.user_position.user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 4:
              // @TODO: possibly check for vals.get(2) being null even though it "shouldn't" ever happen here
              final Long processStepId = Long.parseLong(vals.get(2).toString());
              final String ppsUUID = UUID.randomUUID().toString();

              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));

              if (hasListValues) {
                final String ppscfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
              }

              break;
            case 5:

              if (hasListValues) {
                final String ocfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = flow.user_position.org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ocfvUUID, ocfvUUID, ocfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ocfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = flow.user_position.org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
          }
        }
        break;
      case 5:
        query.append(" from flow.org ");

        query.append("left join flow.user_position on flow.user_position.org_id = flow.org.id and flow.user_position.archived is not true ");
        query.append("left join flow.project on flow.project.user_position_id = flow.user_position.id ");
        query.append("left join flow.contact on flow.contact.owner_user_position_id = flow.user_position.id and flow.contact.archived is not true ");
        query.append("left join flow.user on flow.user.id = flow.user_position.user_id and flow.user.archived is not true ");

        // join tables from object types which aren't the same as the report object type (used in `from` clause)
        for (Map.Entry<Long, List<Object>> entry : joinObjectTypes.entrySet()) {
          final Long cfgaId = entry.getKey();
          List<Object> vals = entry.getValue();
          final String uuid = vals.get(0).toString();
          final Long objectTypeId = Long.parseLong(vals.get(1).toString());
          final Boolean hasListValues = Boolean.parseBoolean((vals.get(3) == null) ? "false" : vals.get(3).toString());

          switch (objectTypeId.intValue()) {
            case 1:
              if (hasListValues) {
                final String pcfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), pcfvUUID, pcfvUUID, pcfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, pcfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 2:
              if (hasListValues) {
                final String ccfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ccfvUUID, ccfvUUID, ccfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ccfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".contact_id = flow.project.contact_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
            case 3:
              final String upUUID = UUID.randomUUID().toString();

              if (hasListValues) {
                final String ucfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", upUUID, upUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = \"%s\".user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ucfvUUID, ucfvUUID, upUUID, ucfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ucfvUUID));
              } else {
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", upUUID, upUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".user_id = \"%s\".user_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, upUUID, uuid, cfgaId));
              }
              break;
            case 4:
              // @TODO: possibly check for vals.get(2) being null even though it "shouldn't" ever happen here
              final Long processStepId = Long.parseLong(vals.get(2).toString());
              final String ppsUUID = UUID.randomUUID().toString();

              query.append(String.format("left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, processStepId));

              if (hasListValues) {
                final String ppscfvUUID = UUID.randomUUID().toString();
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ppscfvUUID));
              } else {
                query.append(String.format("left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, ppsUUID, uuid, cfgaId));
              }

              break;
            case 5:
              final String userPositionUUID = UUID.randomUUID().toString();

              if (hasListValues) {
                final String ocfvUUID = UUID.randomUUID().toString();
                //@TODO: already joining to user_position. Should remove this extraneous join
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = flow.org.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), ocfvUUID, ocfvUUID, ocfvUUID, cfgaId));
                query.append(String.format("left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", uuid, uuid, ocfvUUID));

              } else {
                //@TODO: already joining to user_position. Should remove this extraneous join
                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".org_id = flow.org.id and \"%s\".user_id = flow.user.id ", userPositionUUID, userPositionUUID, userPositionUUID));
//                query.append(String.format("left join flow.user_position \"%s\" on \"%s\".id = flow.contact.owner_user_position_id ", userPositionUUID, userPositionUUID));
                query.append(String.format("left join %s \"%s\" on \"%s\".org_id = flow.user_position.org_id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(objectTypeId), uuid, uuid, uuid, cfgaId));
              }
              break;
          }
        }
        break;
    }

    query.append(" where ");

    for (SmartlistRequirement r : requirements) {
      String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeRequirement());

      // @TODO: requirements need to take into account
      switch (r.getDataTypeId().intValue()) {
        case 1:
          query.append(String.format("%s.%s %s '%s' and ", r.getReferenceTable(), r.getReferenceColumn(), operator, getRequirementValue(r)));
          break;
        case 5:
          query.append(String.format("%s.%s %s %s and ", r.getReferenceTable(), r.getReferenceColumn(), operator, getRequirementValue(r)));
          break;
      }
    }

    // remvoe the last "and "
    query = query.delete(query.length() - 4, query.length());

    query.append(";");

    log.info(query.toString());

    //@TODO: wrap in try/catch and gracefully handle failed queries
    List<Map<String, Object>> results = sqlCache.queryBySql(query.toString(), null, new ColumnMapRowMapper());

    return writeCsv(results, fields, dateFields);
  }

  private String writeCsv(List<Map<String, Object>> data, List<SmartlistFieldAssignment> headers, ArrayList<String> dateFields) {
    CsvSchema.Builder builder = CsvSchema.builder();

    // Dates have to be set as string, else when written to buffer, they display as epoch milli
    for (int i = 0; i < data.size(); i++) {
      Map<String, Object> r = data.get(i);

      for (String field : dateFields) {
        r.put(field, r.get(field).toString());
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
        return "int_value";
      case 7:
        return "int_array_value";
      case 8:
        //@TODO: figure system value
        return "";
      case 9:
        //@TODO: figure system list. I think this uses the same int_value column??
        return "";
      default:
        return "";
    }
  }

  //@TODO humes: similar enough to project process step requirement stuff that should probably be merged at some point
  private Object getRequirementValue(SmartlistRequirement r) {
    switch (r.getDataTypeId().intValue()) {
      case 1:
        LocalDate requirementValue = (r.getRequirementValue() !=  null) ? LocalDate.parse(r.getRequirementValue()) : null;
        LocalDate now = LocalDate.now();
        String secondaryValue = r.getSecondaryRequirementValue();

        //@TODO: format dates for sql query when returning
        switch (r.getDataTypeRequirementId().intValue()) {
          case 1:
            return now.minusDays(Long.parseLong(secondaryValue));
          case 2:
            return now.plusDays(Long.parseLong(secondaryValue));
          case 3:
            return now;
        }
      case 5:
        switch (r.getDataTypeRequirementId().intValue()) {
          case 18:
          case 19:
            return r.getDataTypeRequirement().getDataTypeValue();
        }
      default:
        return null;
    }
  }

  private String getSqlOperator(Long operatorTypeId, DataTypeRequirement r) {

    // List of whether the dataTypeRequirementId is being compared to `null` or `not null`
    List<Long> nullableIds = List.of(4L, 5L, 12L, 13L, 16L, 17L, 18L, 19L, 20L, 21L, 22L, 23L, 24L, 25L, 26L, 27L);

    switch (operatorTypeId.intValue()) {
      case 1:
        return (nullableIds.contains(r.getId()) ? "is" : "=");
      case 2:
        return (nullableIds.contains(r.getId()) ? "is" : "!=");
      case 3:
        return ">";
      case 4:
        return "<";
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
    }
  }
}
