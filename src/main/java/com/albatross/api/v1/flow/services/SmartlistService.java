package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SmartlistService {

  private final SecurityService securityService;

  private final SqlCache sqlCache;

  private final SqlCacheRO sqlCacheRO;

  private final ObjectMapper om;

  private final SystemListService systemListService;

  public List<Smartlist> getSmartlists() {
    User user = securityService.getCurrentUser();

    if (securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("ADMIN", "VIEW_ALL"))) {
      return sqlCache.query("smartlist.getAll", Map.of("companyId", user.getCompanyId(), "userId", user.getId()), Smartlist.class);
    } else {
      return sqlCache.query("smartlist.getOwnAndShared", Map.of("companyId", user.getCompanyId(), "userId", user.getId()), Smartlist.class);
    }
  }

  public Smartlist getSmartlist(Long id) {
    User user = securityService.getCurrentUser();
    final boolean canViewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("VIEW_ALL"));
    return sqlCache.get("smartlist.getById", Map.of("smartlistId", id, "companyId", user.getCompanyId(), "userId", user.getId(), "canViewAll", canViewAll), Smartlist.class).orElse(null);
  }

  public Smartlist addSmartlist(Smartlist smartlist) {
    if (!this.isNameUnique(smartlist.getName())) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Smartlist name already taken", new Exception());
    }

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = om.convertValue(smartlist, HashMap.class);
    params.put("ownerId", user.getId());
    params.put("createdById", user.trueUserId());
    Long smartlistId = sqlCache.updateReturningId("smartlist.add", params, "id").longValue();
    return getSmartlist(smartlistId);
  }

  public void updateSmartlist(Smartlist smartlist) {

    Smartlist existingSmartlist = this.getSmartlist(smartlist.getId());

    if (existingSmartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to find given smartlist", new RuntimeException());
    }

    final boolean updatingName = !existingSmartlist.getName().trim().equalsIgnoreCase(smartlist.getName().trim().toLowerCase());

    if (updatingName && !this.isNameUnique(smartlist.getName())) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Smartlist name already taken", new Exception());
    }

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = om.convertValue(smartlist, HashMap.class);
    params.put("userId", user.trueUserId());

    // enforce rule that only project, process step, and contact row types can have a table view display
    if (!List.of(1, 2, 4).contains(smartlist.getObjectTypeId().intValue())) {
      params.put("viewObjectTypeId", null);
    }

    sqlCache.update("smartlist.update", params);
  }

  public void deleteSmartlist(Long smartlistId) {
    sqlCache.update("smartlist.delete", Map.of("id", smartlistId, "userId", securityService.getCurrentUser().getId()));
  }

  @Transactional
  public void toggleProjectDetails(Long smartlistId) {
    Smartlist smartlist = this.getSmartlist(smartlistId);

    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to find given smartlist", new RuntimeException());
    }

    smartlist.setProjectDetails(!smartlist.isProjectDetails());
    this.updateSmartlist(smartlist);

    sqlCache.update("smartlist.clearFieldsAndRequirements", Map.of("smartlistId", smartlistId, "userId", securityService.getCurrentUser().getId()));
  }

  @Transactional
  public Smartlist updateObjectType(Smartlist smartlist) {
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to find given smartlist", new RuntimeException());
    }

    smartlist.setProjectDetails(false);

    if (!List.of(3, 5).contains(smartlist.getObjectTypeId().intValue())) {
      smartlist.setPrimaryUserPosition(false);
    }

    if (!List.of(1, 2, 4).contains(smartlist.getObjectTypeId().intValue())) {
      smartlist.setPrimaryUserPosition(true);
      smartlist.setMainProcessSteps(true);
    }

    updateSmartlist(smartlist);
    sqlCache.update("smartlist.clearFieldsAndRequirements", Map.of("smartlistId", smartlist.getId(), "userId", securityService.getCurrentUser().getId()));
    return getSmartlist(smartlist.getId());
  }

  public boolean isNameUnique(String name) {
    User user = securityService.getCurrentUser();
    List<Smartlist> smartlists = sqlCache.query("smartlist.getAll", Map.of("companyId", user.getCompanyId(), "userId", user.getId()), Smartlist.class);
    for (Smartlist s: smartlists) {
      if (s.getName().trim().toLowerCase().equals(name.trim().toLowerCase())) {
        return false;
      }
    }
    return true;
  }

  public List<SmartlistFieldAssignment> getAvailableFields(Long objectTypeId) {
    Map<String, Object> params = Map.of("companyId", securityService.getCurrentUser().getCompanyId(), "objectTypeId", objectTypeId);
    return sqlCache.query("smartlist.getAvailableFields", params, new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
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
              field.setListOfValues(systemListService.getSystemListOptionsForCompany(field.getCompanySystemListId(), true, field.getSystemListOptionIds(), field.getCompanyId()));
            }
        }

        return field;
    }

  public List<SmartlistFieldAssignment> getAvailableProjectDetailsFields() {
    return sqlCache.query("smartlist.getAvailableProjectDetailsFields", null, new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
  }

  public List<SmartlistFieldAssignment> getAssignedFields(Long smartlistId) {
    return sqlCache.query("smartlist.getAssignedFields", Map.of("smartlistId", smartlistId), new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
  }

  public SmartlistFieldAssignment getAssignedFieldById(Long assignmentId) {
    return sqlCache.get("smartlist.getAssignedFieldById", Map.of("id", assignmentId), SmartlistFieldAssignment.class).orElse(null);
  }

  public List<SmartlistFieldAssignment> getAssignedProjectDetailsFields(Long smartlistId) {
    return sqlCache.query("smartlist.getAssignedProjectDetailsFields", Map.of("smartlistId", smartlistId), new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
  }

    public SmartlistRequirement getRequirementById(Long requirementId) {
        User user = securityService.getCurrentUser();
        Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
        SmartlistRequirement requirement =  sqlCache.get("smartlist.getRequirementById", Map.of("requirementId", requirementId, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany), new SmartlistRequirementMapper<>(SmartlistRequirement.class, om)).orElse(null);

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
    sqlCache.update("smartlist.archiveLogic", Map.of("smartlistId", smartlistId, "userId", user.trueUserId()));

    if (!logic.isEmpty()) {
      HashMap<String, Object> params = null;
      int counter = 0;
      for (SmartlistLogic l : logic) {
        params = om.convertValue(l, HashMap.class);
        params.put("userId", user.trueUserId());
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
    params.put("createdById", user.trueUserId());
    params.put("processStepId", assignment.getProcessStepId());
    params.put("projectDetailsColumn", assignment.getProjectDetailsColumn());
    Long assignmentId = sqlCache.updateReturningId("smartlist.addField", params, "id").longValue();
    return this.getAssignedFieldById(assignmentId);
  }

  public SmartlistRequirement addRequirement(Long smartlistId, SmartlistRequirement requirement) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = om.convertValue(requirement, HashMap.class);
    params.put("userId", user.trueUserId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    Long requirementId = sqlCache.updateReturningId("smartlist.addRequirement", params, "id").longValue();
    return getRequirementById(requirementId);
  }

  public SmartlistRequirement updateRequirement(SmartlistRequirement requirement) {
    HashMap<String, Object> params = om.convertValue(requirement, HashMap.class);
    params.put("userId", securityService.getCurrentUser().trueUserId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    sqlCache.update("smartlist.updateRequirement", params);
    return getRequirementById(requirement.getId());
  }

  public void deleteRequirement(Long requirementId) {
    sqlCache.update("smartlist.deleteRequirement", Map.of("requirementId", requirementId, "userId", securityService.getCurrentUser().trueUserId()));
  }

  public void deleteFieldAssignment(Long fieldId) {
    sqlCache.update("smartlist.deleteField", Map.of("id", fieldId, "userId", securityService.getCurrentUser().trueUserId()));
  }

  public void updateDisplayOrder(List<SmartlistFieldAssignment> fields) {
    fields.forEach(field -> {
      sqlCache.update("smartlist.updateDisplayOrder", Map.of("id", field.getId(), "displayOrder", field.getDisplayOrder(), "userId", securityService.getCurrentUser().trueUserId()));
    });
  }

  public List<SmartlistRequirement> getRequirements(Long smartlistId, boolean includeListValues) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Map<String, Object> params = Map.of("smartlistId", smartlistId, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany, "parentCompanyId", user.getHighestParentCompanyId());
    List<SmartlistRequirement> requirements = sqlCache.query("smartlist.getRequirements", params, new SmartlistRequirementMapper<>(SmartlistRequirement.class, om));

    if (includeListValues) {
        for (SmartlistRequirement r : requirements) {
            if (r.getCustomFieldSqlKey() != null) {
                final String sql = sqlCache.getByKey(r.getCustomFieldSqlKey());
                if (sql != null) {
                    r.setAvailableListOfValues(sqlCache.queryBySql(sql, null, ListOfValue.class));
                }
            }
        }
    }

    return requirements;
  }

  public List<Smartlist> getSharedByType(Long objectTypeId) {
      User user = securityService.getCurrentUser();
      return sqlCache.query("smartlist.getSharedByObjectType", Map.of("companyId", user.getCompanyId(), "objectTypeId", objectTypeId, "userId", user.getId()), Smartlist.class);
  }

  @Transactional
  public Smartlist copy(Long smartlistId) {

    User user = securityService.getCurrentUser();
    Smartlist smartlist = getSmartlist(smartlistId);

    if (smartlist.getId() == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No smartlist with given ID", new RuntimeException());
    }

    long copyNumber = 0L;
    String newName;
    boolean unique;

    do {
      newName = String.format("%s (%s)", smartlist.getName(), ++copyNumber);
      unique = sqlCache.queryForObject("smartlist.isNameUnique", Map.of("name", newName, "companyId", user.getCompanyId()), Boolean.class);
    } while (!unique);

    Smartlist newSmartlist = new Smartlist();
    newSmartlist.setName(newName);
    newSmartlist.setCompanyObjectTypeId(smartlist.getCompanyObjectTypeId());
    newSmartlist.setShared(smartlist.isShared());
    newSmartlist.setViewObjectTypeId(smartlist.getViewObjectTypeId());
    newSmartlist.setMainProcessSteps(smartlist.isMainProcessSteps());
    newSmartlist.setProjectDetails(smartlist.isProjectDetails());

    HashMap<String, Object> params = om.convertValue(newSmartlist, HashMap.class);
    params.put("ownerId", user.getId());
    params.put("createdById", user.trueUserId());
    Long newSmartlistId = sqlCache.updateReturningId("smartlist.add", params, "id").longValue();

    sqlCache.update("smartlist.copyAssignedFields", Map.of("newId", newSmartlistId, "userId", user.trueUserId(), "oldId", smartlistId));
    sqlCache.update("smartlist.copyRequirements", Map.of("newId", newSmartlistId, "userId", user.trueUserId(), "oldId", smartlistId));

    return getSmartlist(newSmartlistId);
  }

  public String getSmartlistSqlString(Long smartlistId) {
    Smartlist smartlist = this.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

    log.info("SMARTLIST: Running smartlist ID: " + smartlistId);
    List<SmartlistFieldAssignment> fields = this.getAssignedFields(smartlistId);
    String query;

    if (smartlist.getObjectTypeId() == 4) {
      query = buildProcessStepSql(smartlist, fields);
    } else {
      query = (smartlist.isProjectDetails()) ? this.buildProjectDetailsSql(smartlist) : buildSql(smartlist, fields);
    }

    return query;
  }

  public SmartlistResult getSmartlistResults(Long smartlistId) {
    Smartlist smartlist = this.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

    log.info("SMARTLIST: Running smartlist ID: " + smartlistId);
    List<SmartlistFieldAssignment> fields = this.getAssignedFields(smartlistId);
    String query;

    if (smartlist.getObjectTypeId() == 4) {
      query = buildProcessStepSql(smartlist, fields);
    } else {
      query = (smartlist.isProjectDetails()) ? this.buildProjectDetailsSql(smartlist) : buildSql(smartlist, fields);
    }

    List<Map<String, Object>> results = sqlCacheRO.queryBySql(query, null, new ColumnMapRowMapper());

    return new SmartlistResult(fields, results);
  }

  public String getCsv(Long smartlistId, String timezone) throws JsonProcessingException {
    Smartlist smartlist = this.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

    final List<SmartlistFieldAssignment> fields = (smartlist.isProjectDetails()) ? this.getAssignedProjectDetailsFields(smartlistId) : this.getAssignedFields(smartlistId);

    if (null == smartlist.getWorkQueueTypeId() && fields.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist must have at least 1 field", new Exception());
    }

    if (!smartlist.isProjectDetails()) {
      for (SmartlistFieldAssignment f: fields) {
        // Truncate field name if it's longer than postgres' column/field limit of 63
        if (f.getName().length() > 63) {
          f.setName(f.getName().substring(0, 60) + "...");
        }

        if (f.getObjectTypeId() == 4) {
          final String append = String.format(" (%s)", f.getProcessStepId());
          if (f.getName().length() + append.length() > 63) {
            f.setName(f.getName().substring(0, f.getName().length() - append.length() - 3) + append + "...");
          } else {
            f.setName(f.getName() + append);
          }
        }
      }
    }

    log.info("SMARTLIST: Running smartlist ID: " + smartlistId);
    String query;

    //dont run the processStepSql if it is for a work queue list. i only put the work queue code into the buildSql funtion
    if (smartlist.getObjectTypeId() == 4 && null == smartlist.getWorkQueueTypeId() && !smartlist.isProjectDetails()) {
      query = buildProcessStepSql(smartlist, fields);
    } else {
      query = (smartlist.isProjectDetails()) ? this.buildProjectDetailsSql(smartlist) : buildSql(smartlist, fields, timezone, null);
    }

//    log.info("*** {}", query);
    final List<Map<String, Object>> results = sqlCacheRO.queryBySql(query, null, new ColumnMapRowMapper());

    if (results.isEmpty()) {
      return writeEmptyCsv(fields);
    } else {
      return writeCsv(results, fields, null != smartlist.getWorkQueueTypeId());
    }
  }

  public String buildProjectDetailsSql(Smartlist smartlist) {

    List<SmartlistFieldAssignment> fields = this.getAssignedProjectDetailsFields(smartlist.getId());
    List<SmartlistRequirement> requirements = this.getRequirements(smartlist.getId(), false);

    StringBuilder query = new StringBuilder();

    long ahjCount = fields.stream().filter(f -> Objects.equals(f.getCustomFieldSqlKey(), "customFieldSql.brs.ahjList")).count();
    ahjCount += requirements.stream().filter(r -> Objects.equals(r.getCustomFieldSqlKey(), "customFieldSql.brs.ahjList")).count();

    if (ahjCount > 0) {
      query.append(String.format(" with \"customFieldSql.brs.ahjList\" as (%s)", sqlCache.getByKey("customFieldSql.brs.ahjList")));
    }

    query.append(" select");

    for (SmartlistFieldAssignment f: fields) {
      if (f.getDataTypeId() == 1) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD') as \"%s\", ", f.getProjectDetailsColumn(), f.getName()));
      } else if(f.getDataTypeId() == 2) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getProjectDetailsColumn(), f.getName()));
      } else if (f.getCustomFieldSqlKey() != null) {
        query.append(String.format("  \"%s\".name as \"%s\", ",f.getCustomFieldSqlKey(), f.getName()));
      } else {
        query.append(String.format("  %s as \"%s\", ", f.getProjectDetailsColumn(), f.getName()));
      }
    }

    // Remove comma and space from last select field
    query.deleteCharAt(query.length() - 1);

    query.append(" flow.project.id as project_id,");
    query.append(" flow.project.contact_id as contact_id");

    // @TODO: Eventually de-hardcode brs schema
    query.append(" from brs.project_details");
    query.append(" inner join flow.project on flow.project.id = brs.project_details.project_id");

    if (ahjCount > 0) {
      query.append(" left join \"customFieldSql.brs.ahjList\" on \"customFieldSql.brs.ahjList\".id = brs.project_details.ahj");
    }

    query.append(" where");

    // If user is in a parent company, get all rows. else if user is the child, limit rows to that company
    User user = securityService.getCurrentUser();
    boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());

    if (inParentCompany) {
      query.append(String.format(" brs.project_details.company_id = any(select id from flow.company c where (c.id = %s or c.parent_company_id = %s) and c.archived is not true) and ", user.getCompanyId(), user.getCompanyId()));
    } else {
      query.append(String.format(" brs.project_details.company_id = %s and ", user.getCompanyId()));
    }

    for (SmartlistRequirement r: requirements) {
      String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());
      Object requirementValue = getRequirementValue(r);

      //Check for double negative with "nots" between operator and requirement
      if (r.getDataTypeRequirementId() != null) {
        if (requirementValue != null && requirementValue.toString().contains("not") &&  operator != null && operator.contains("not")) {
          operator = operator.replace("not", "");

          if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
            requirementValue = requirementValue.toString().replace("not", "");
          }
        }
      }

      if (r.getDataTypeId() == 7) {
        if (r.getDataTypeRequirementId() != null) {
          query.append(String.format(" %s %s %s and ", r.getProjectDetailsColumn(), operator, requirementValue));
        } else {
          query.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", r.getProjectDetailsColumn(), operator, requirementValue));
        }
      } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
        query.append(String.format(" %s %s %s and ", r.getProjectDetailsColumn(), operator, requirementValue));
      } else {
        if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
          query.append(String.format(" %s %s %s and ", r.getProjectDetailsColumn(), operator, requirementValue));
        } else {
          query.append(String.format(" %s %s '%s' and ", r.getProjectDetailsColumn(), operator, requirementValue));
        }
      }
    }

    // remove the last "and "
    query = query.delete(query.length() - 5, query.length());

    query.append(";");

    return query.toString();
  }

  public String buildSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields) {
    return buildSql(smartlist, fields, null, null);
  }

  public String buildSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields, String timezone, List<Long> installationCrewIds) {

    //@TODO humes: there is a lot of duplication in this function which could/should be abstracted out

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    List<SmartlistRequirement> requirements = this.getRequirements(smartlist.getId(), false);

    List<SmartlistFieldAssignment> joinTables = new ArrayList<>();

    List<Long> usedProcessStepIds = new ArrayList<>();

    StringBuilder withClause = new StringBuilder();
    StringBuilder additionalJoins = new StringBuilder();
    StringBuilder whereClause = new StringBuilder();

    // Get smartlist system lists
    withClause.append(String.format(" \"smartlistSystemList_1\" as (select * from flow.get_smartlist_system_list_options(1::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_2\" as (select * from flow.get_smartlist_system_list_options(2::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_3\" as (select id, name from flow.get_smartlist_system_list_options(3::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_4\" as (select id, name from flow.get_smartlist_system_list_options(4::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_5\" as (select id, name from flow.get_smartlist_system_list_options(5::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_6\" as (select id, name from flow.get_smartlist_system_list_options(6::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_7\" as (select id, name from flow.get_smartlist_system_list_options(7::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_8\" as (select id, name from flow.get_smartlist_system_list_options(8::int, %s::int)), ", companyId));
    withClause.append(String.format(" \"smartlistSystemList_9\" as (select id, name from flow.get_smartlist_system_list_options(9::int, %s::int)), ", companyId));

    // Get tables for system lists
    withClause.append(" \"systemList_1\" as (select up.id, concat(u.first_name, ' ', u.last_name::text) as name from flow.user_position up inner join flow.user u on u.id = up.user_id), ");
    withClause.append(" \"systemList_3\" as (select id, org_name::text as name from flow.org), ");
    withClause.append(" \"systemList_4\" as (select id, concat(first_name, ' ', last_name::text) as name from flow.user), ");

    if(null != smartlist.getWorkQueueTypeId()) {
      withClause.append(" \"ps_wq_statuses\" as (\n" +
        "    select pswqtpsst.process_step_status_type_id,\n" +
        "           pswqtpsst.company_process_step_status_type_id,\n" +
        "           pswqt.process_step_id\n" +
        "    from flow.process_step_work_queue_type_process_step_status_type pswqtpsst\n" +
        "             inner join flow.process_step_work_queue_type pswqt on pswqtpsst.process_step_work_queue_type_id = pswqt.id\n" +
        "             inner join flow.process_step ps on pswqt.process_step_id = ps.id\n" +
        "    where pswqt.work_queue_type_id = " + smartlist.getWorkQueueTypeId() + "\n" +
        "      and pswqt.archived is not true\n" +
        "      and pswqtpsst.archived is not true\n" +
        "      and ps.archived is not true\n" +
        "      and ps.company_id = any\n" +
        "                        (select id from flow.company_hierarchy_filter_down(" + companyId + "))\n" +
        "      and pswqtpsst.archived is not true\n" +
        "),\n" +
        "     \"pj_wq_statuses\" as (\n" +
        "         select pswqtpsst.project_status_type_id,\n" +
        "                pswqtpsst.company_project_status_type_id,\n" +
        "                pswqt.process_step_id\n" +
        "         from flow.process_step_work_queue_type_project_status_type pswqtpsst\n" +
        "                  inner join flow.process_step_work_queue_type pswqt on pswqtpsst.process_step_work_queue_type_id = pswqt.id\n" +
        "                  inner join flow.process_step ps on pswqt.process_step_id = ps.id\n" +
        "         where pswqt.work_queue_type_id = " + smartlist.getWorkQueueTypeId() + "\n" +
        "           and pswqt.archived is not true\n" +
        "           and pswqtpsst.archived is not true\n" +
        "           and ps.archived is not true\n" +
        "           and ps.company_id = any\n" +
        "                        (select id from flow.company_hierarchy_filter_down(" + companyId + "))\n" +
        "           and pswqtpsst.archived is not true\n" +
        "     ), ");
    }

    StringBuilder query = new StringBuilder(" select ");

    if(null != smartlist.getWorkQueueTypeId()) {
      query.append(
        "       flow.project.project_name                                                                             as \"Project Name\",\n" +
        "       flow.process_step.process_step_name                                                                   as \"Process Step Name\",\n" +
        "       cpsst.process_step_status_type                                                                        as \"Process Step Status Type\",\n" +
          "       (select coalesce((select extract(days from now()::timestamp - wqc.date_entered_queue)\n" +
          "          from flow.work_queue_cycle wqc\n" +
          "            inner join flow.process_step_work_queue_type_process_step_status_type pswqtpstt on wqc.process_step_work_queue_type_process_step_status_type_id = pswqtpstt.id\n" +
          "            inner join flow.process_step_work_queue_type pswqt2 on  pswqt2.id = pswqtpstt.process_step_work_queue_type_id\n" +
          "          where wqc.project_process_step_id = flow.project_process_step.id\n" +
          "            and pswqt2.id = pswqt.id\n" +
          "            and wqc.date_exited_queue is null\n" +
          "            and pswqt2.archived is false\n" +
          "            and pswqtpstt.archived is false\n" +
          "       ), DATE_PART('day', now() - flow.project_process_step.date_created))) as \"Days In Queue\", \n" +
        "       st.abbreviation                                                                                       as \"State Abbreviation\",\n" +
        "       case when u.id is not null then concat(u.first_name, ' ', u.last_name) end                            AS \"Owner\",\n" +
          " (select array_to_string(array(\n" +
          "                                    select ps2.process_step_name\n" +
          "                                    from flow.project_process_step pps2\n" +
          "                                           inner join flow.process_step ps2 on ps2.id = pps2.process_step_id\n" +
          "                                           inner join flow.company_process_step_status_type cpsst2\n" +
          "                                                      on cpsst2.id = pps2.company_process_step_status_type_id\n" +
          "                                           inner join flow.process_step_status_type psst2\n" +
          "                                                      on psst2.id = cpsst2.process_step_status_type_id\n" +
          "                                    where pps2.project_id = flow.project.id\n" +
          "                                      and cpsst2.process_step_status_type_id = 1\n" +
          "                                      and pps2.archived is not true\n" +
          "                                      and pps2.id != flow.project_process_step.id\n" +
          "                                    order by ps2.process_step_name\n" +
          "                                  ), ', ')) as \"Active Process Steps\",\n" +
        "       flow.process_step.id                                                                                  as \"processStepId\",\n" +
        "       flow.project_process_step.id                                                                          as \"projectProcessStepId\",\n" +
        "       wqt.work_queue_type                                                                                   as \"workQueueType\",\n" +
        "       wqt.id                                                                                                as \"workQueueTypeId\",\n" +
        "       pswqt.id                                                                                              as \"processStepWorkQueueTypeId\",\n" +
        "       flow.project_process_step.project_id                                                                  as \"projectId\",\n" +
        "       flow.project.company_project_status_type_id                                                           as \"companyProjectStatusTypeId\",\n" +
        "       cpst.project_status_type_id                                                                           as \"projectStatusTypeId\",\n" +
        "       flow.project.contact_id                                                                               as \"contactId\",\n" +
        "       to_char(coalesce(flow.project_process_step.date_modified, flow.project_process_step.date_created), 'MM-DD-YYYY HH12:MI:SS AM')             as \"lastUpdated\",\n" +
        "       coalesce((\n" +
        "                    SELECT array_to_json(array_agg(row_to_json(owningPositions)))\n" +
        "                    FROM (\n" +
        "                             SELECT pspop.id,\n" +
        "                                    pspop.process_step_process_id as \"processStepProcessId\",\n" +
        "                                    pspop.position_id             as \"positionId\",\n" +
        "                                    pspop.archived\n" +
        "                             FROM flow.process_step_process_owning_position pspop\n" +
        "                                      inner join flow.process_step_process psp on psp.id = pspop.process_step_process_id\n" +
        "                             WHERE psp.process_step_id = flow.process_step.id\n" +
        "                               and pspop.archived is not true) owningPositions), '[]')  AS \"Owning Positions\",\n" +
        "       coalesce((\n" +
        "                    SELECT array_to_json(array_agg(row_to_json(notes)))\n" +
        "                    FROM (\n" +
        "                             select n.id,\n" +
        "                                    n.note,\n" +
        "                                    n.archived,\n" +
        "                                    n.parent_id as \"parentId\",\n" +
        "                                    n.date_created as \"dateCreated\",\n" +
        "                                    n.date_modified as \"dateModified\",\n" +
        "                                    n.created_by_id as \"createdById\",\n" +
        "                                    n.follow_up_date as \"followUpDate\",\n" +
        "                                    concat(creator.first_name, ' ', creator.last_name) as \"createdBy\",\n" +
        "                                    n.modified_by_id as \"modifiedById\",\n" +
        "                                    pn.project_process_step_id as \"projectProcessStepId\",\n" +
        "                                    pn.process_step_work_queue_type_id as \"processStepWorkQueueTypeId\",\n" +
        "                                    coalesce((\n" +
        "                                                 SELECT array_to_json(array_agg(row_to_json(childNotes)))\n" +
        "                                                 FROM (\n" +
        "                                                          select n2.id,\n" +
        "                                                                 n2.note,\n" +
        "                                                                 n2.archived,\n" +
        "                                                                 n2.date_created as \"dateCreated\",\n" +
        "                                                                 n2.date_modified as \"dateModified\",\n" +
        "                                                                 n2.created_by_id as \"createdById\",\n" +
        "                                                                 n2.follow_up_date as \"followUpDate\",\n" +
        "                                                                 concat(creator2.first_name, ' ', creator2.last_name) as \"createdBy\",\n" +
        "                                                                 n2.modified_by_id as \"modifiedById\",\n" +
        "                                                                 pn2.project_process_step_id as \"projectProcessStepId\",\n" +
        "                                                                 pn2.process_step_work_queue_type_id as \"processStepWorkQueueTypeId\"\n" +
        "                                                          from flow.note n2\n" +
        "                                                                   inner join flow.project_process_step_process_step_work_queue_type_note pn2 on pn2.note_id = n2.id\n" +
        "                                                                   inner join flow.user creator2 on creator2.id = n2.created_by_id\n" +
        "                                                          where n2.archived is not true\n" +
        "                                                            and n2.parent_id = n.id\n" +
        "                                                          order by n2.date_created\n" +
        "                                                      ) childNotes), '[]') AS \"childNotes\"\n" +
        "                             from flow.note n\n" +
        "                                      inner join flow.project_process_step_process_step_work_queue_type_note pn on pn.note_id = n.id\n" +
        "                                      inner join flow.user creator on creator.id = n.created_by_id\n" +
        "                             where n.archived is not true\n" +
        "                               and n.parent_id is null\n" +
        "                               and pn.project_process_step_id = flow.project_process_step.id\n" +
        "                               and pn.process_step_work_queue_type_id = pswqt.id\n" +
        "                             order by n.date_created desc\n" +
        "\n" +
        "                         ) notes), '[]') AS \"Notes\", \n");
    }

    if (List.of(1, 2, 4).contains(smartlist.getObjectTypeId().intValue())) {
      query.append(" flow.project.id as project_id, ");
      query.append(" flow.contact.id as contact_id, ");
    }

    for (SmartlistFieldAssignment f : fields) {

      if (f.getProcessStepId() != null) {
        usedProcessStepIds.add(f.getProcessStepId());
      }

      if (f.getSmartlistSystemListId() == null)  {
        if (f.getCustomFieldGroupAssignmentId() != null && joinTables.stream().noneMatch(t -> t.getId().equals(f.getId()))) {
          // When the field is custom (has a cfgaId), reference table will be a UUID to keep track of that specific relationship/join
          f.setReferenceTable(UUID.randomUUID().toString());

          // If field is a system list, we need the int_value from the object value table to get the actual display value (name column) from the with clause
          if (f.getSystemListTypeId() != null || f.getAllowMultiple()) {
            f.setValueReferenceTable(UUID.randomUUID().toString());
          }
          f.setPpsTable(UUID.randomUUID().toString());
          joinTables.add(f);
        } else if (f.getCustomFieldGroupAssignmentId() == null && f.getProcessStepId() != null && smartlist.getObjectTypeId() != 4) {

          // When the field is system but has a process step ID, reference table will be a UUID to keep track of that specific relationship/join to the same process step
          if (Objects.equals(f.getReferenceTable(), "flow.user") || joinTables.stream().noneMatch(t -> t.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))) {
            if (f.getJoinTable() != null && f.getJoinColumn() != null) {
              // System fields with joins will use this property (for now at least) instead of referenceTable
              f.setValueReferenceTable(UUID.randomUUID().toString());
            } else if (f.getReferenceTable() == null) {
              f.setReferenceTable(UUID.randomUUID().toString());
            }
            f.setPpsTable(UUID.randomUUID().toString());
            joinTables.add(f);
          } else {
            final String uuid = joinTables.stream()
              .filter(t -> t.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))
              .map(t -> {
                if (Objects.equals(f.getReferenceTable(), "flow.user") || Objects.equals(f.getReferenceTable(), "flow.process_step") || Objects.equals(f.getReferenceTable(), "flow.project_process_step")) {
                  return t.getPpsTable();
                } else {
                  return t.getReferenceTable();
                }
              })
              .findFirst()
              .orElse(null);

            if (f.getReferenceTable().equals("flow.user") || Objects.equals(f.getReferenceTable(), "flow.process_step")) {
              f.setValueReferenceTable(uuid);
            } else {
              f.setReferenceTable(uuid);
            }
          }
        } else if (f.getJoinTable() != null && f.getJoinColumn() != null) {
          f.setValueReferenceTable(UUID.randomUUID().toString());
          f.setPpsTable((UUID.randomUUID().toString()));
          joinTables.add(f);
        }
      } else {
        f.setValueReferenceTable(UUID.randomUUID().toString());
        f.setPpsTable(UUID.randomUUID().toString());
        joinTables.add(f);
      }

      String location = "";

      final String referenceTable = joinTables.stream()
        .filter(t -> t.getCustomFieldGroupAssignmentId() != null && t.getCustomFieldGroupAssignmentId().equals(f.getCustomFieldGroupAssignmentId()))
        .map(t -> {
          if (Objects.equals(f.getReferenceTable(), "flow.project_process_step")) {
            return t.getPpsTable();
          } else if (t.getAllowMultiple()) {
            return t.getValueReferenceTable();
          } else {
            return t.getReferenceTable();
          }
        })
        .findFirst()
        .orElse(null);

      if (f.getSmartlistSystemListId() != null) {

        final String smartlistSystemListTable = "smartlistSystemList_" + f.getSmartlistSystemListId();

        if (List.of(1, 3, 5, 6, 7, 8, 9).contains(f.getSmartlistSystemListId().intValue())) {
          location = String.format("(select name from \"%s\" where \"%s\".id = %s.%s)", smartlistSystemListTable, smartlistSystemListTable, f.getJoinTable(), f.getJoinColumn());
        } else if (f.getSmartlistSystemListId() == 2 || f.getSmartlistSystemListId() == 4) {

//          if (smartlist.getObjectTypeId() == 4) {
//            location = String.format("(" +
//              "select name " +
//              "from \"%s\" " +
//              "inner join flow.company_process_step_status_type cpsst on cpsst.id = flow.project_process_step.%s " +
//              "where \"%s\".id = cpsst.process_step_status_type_id)", smartlistSystemListTable, f.getJoinColumn(), smartlistSystemListTable);
//          } else {
          String ppsTable;

          try {
            ppsTable = joinTables.stream()
              .filter(t -> t.getProcessStepId() != null && f.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))
              .map(t -> {
                if (t.getPpsTable() != null) {
                  return t.getPpsTable();
                } else {
                  return t.getValueReferenceTable();
                }
              })
              .findFirst()
              .orElse(null);

            if (ppsTable == null) {
              ppsTable = UUID.randomUUID().toString();
            }
          } catch (NullPointerException e) {
            ppsTable = UUID.randomUUID().toString();
          }

          if (f.getSmartlistSystemListId() == 2) {
            location = String.format("(" +
              "select name " +
              "from \"%s\" " +
              "inner join %s cpsst on cpsst.id = \"%s\".%s " +
              "where \"%s\".id = cpsst.id)", smartlistSystemListTable, f.getJoinTable(), ppsTable, f.getJoinColumn(), smartlistSystemListTable);
          } else {
            location = String.format("(" +
              "select name " +
              "from \"%s\" " +
              "inner join %s cpsst on cpsst.id = \"%s\".%s " +
              "where \"%s\".id = cpsst.process_step_status_type_id)", smartlistSystemListTable, f.getJoinTable(), ppsTable, f.getJoinColumn(), smartlistSystemListTable);
          }
        }
//        }
      }
      // If field is custom, else it's system
      else if (f.getCustomFieldGroupAssignmentId() != null && referenceTable != null) {
        final String column = ((f.getHasListValues() != null && f.getHasListValues() && !f.getAllowMultiple()) || f.getCustomFieldSqlKey() != null) ? "name" : getReferenceColumn(f.getDataTypeId());
        // if data type id == 2 and timezone is not null, then String.format("(\"%s\".%s at time zone \'%s\')", referenceTable, column, timezone)
//        ppscfv.timestamp_value
        if(null != timezone && f.getDataTypeId() == 2) {
//          (site_survey_verified_date AT TIME ZONE 'US/Mountain') AT TIME ZONE 'UTC')
          location = String.format("((\"%s\".%s at time zone \'UTC\') at time zone \'%s\')", referenceTable, column, timezone);
//          location = String.format("\"%s\".%s", referenceTable, column);
        } else {
          location = String.format("\"%s\".%s", referenceTable, column);
        }
      } else if (Objects.equals(f.getReferenceTable(), "flow.user") && f.getObjectTypeId() != 3 && f.getObjectTypeId() != 5) {
        location = (f.getObjectTypeId() != 4) ? f.getReferenceColumn() : String.format("concat(\"%s\".first_name, ' ', \"%s\".last_name)", f.getValueReferenceTable(), f.getValueReferenceTable());
      } else if (Objects.equals(f.getReferenceTable(), "flow.project_user") || Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
        location = f.getReferenceColumn();
      } else {
        if (smartlist.getObjectTypeId() == 4) {
          location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
        } else {
          if (f.getCustomFieldGroupAssignmentId() != null || f.getProcessStepId() != null || (f.getJoinTable() != null && f.getJoinColumn() != null)) {
            String table;

            if (Objects.equals(f.getReferenceTable(), "flow.project_process_step")) {
              table = f.getPpsTable();
            } else {
              table = (f.getJoinTable() != null && f.getJoinColumn() != null) ? f.getValueReferenceTable() : f.getReferenceTable();
            }

            location = String.format("\"%s\".%s", table, f.getReferenceColumn());
          } else {
            location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
          }
        }
      }

      boolean showProcessStepName = null != smartlist.getWorkQueueTypeId() && null != f.getProcessStepId();
      String fieldName = showProcessStepName ? f.getProcessStepName() + " - " + f.getName() : f.getName();
      if (Objects.equals(f.getReferenceTable(), "flow.process_step")) {
        if (smartlist.getObjectTypeId() == 4) {
          query.append(String.format("  (select %s from %s where %s.id = %s) as \"%s\", ", f.getReferenceColumn(), f.getReferenceTable(), f.getReferenceTable(), f.getProcessStepId(), fieldName));
        } else {
          query.append(String.format("  (select %s from %s where %s.id = \"%s\".process_step_id) as \"%s\", ", f.getReferenceColumn(), f.getReferenceTable(), f.getReferenceTable(), f.getValueReferenceTable(), fieldName));
        }
      } else if (f.getDataTypeId() == 1) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD') as \"%s\", ", location, fieldName));
      } else if(f.getDataTypeId() == 2) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", location, fieldName));
      } else if (f.getDataTypeId() == 7 && f.getSmartlistSystemListId() == null) {
          query.append(String.format("  (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s)), ',')) as \"%s\", ", location, fieldName));
      } else if (f.getDataTypeId() == 9) {
          final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

          final String sql = String.format("  (select name from \"%s\" where \"%s\".id = \"%s\".int_value) as \"%s\", ", "systemList_" + systemListNumber, "systemList_" + systemListNumber, f.getValueReferenceTable(), fieldName);
          query.append(sql);
      } else {
        query.append(String.format("  %s as \"%s\", ", location, fieldName));
      }

      if (f.getCustomFieldSqlKey() != null && withClause.indexOf(f.getCustomFieldSqlKey()) == -1) {
          withClause.append(String.format("  \"%s\" as  (%s), ", f.getCustomFieldSqlKey(), sqlCache.getByKey(f.getCustomFieldSqlKey() + ".smartlist")));
      }
    }

    for (SmartlistRequirement r: requirements) {

        if (r.getProcessStepId() != null) {
          usedProcessStepIds.add(r.getProcessStepId());
        }

        // If this custom sql is not already in the "with" clause, add it
        if (r.getCustomFieldSqlKey() != null && withClause.indexOf(r.getCustomFieldSqlKey()) == -1) {
            withClause.append(String.format("  \"%s\" as  (%s), ", r.getCustomFieldSqlKey(), sqlCache.getByKey(r.getCustomFieldSqlKey() + ".smartlist")));
        }
    }

    query.deleteCharAt(query.length() - 2);

    final String companySubquery = String.format("select id from flow.company where id = %s or parent_company_id = %s", companyId, companyId);

    if(null == smartlist.getWorkQueueTypeId()) {

      // @TODO: if active flag is false, maybe this should be a user status requirement though
      // assume mountain time for date comparisons
      LocalDateTime dateTimeNow = LocalDateTime.ofInstant(Instant.now(), ZoneId.of("UTC")).withMinute(0).withSecond(0).withNano(0);
      ZonedDateTime zonedNow = dateTimeNow.atZone(ZoneId.of("UTC")).withZoneSameInstant(ZoneId.of("America/Denver"));
      String now = zonedNow.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

      switch (smartlist.getObjectTypeId().intValue()) {
      case 1:
        query.append(" from flow.project ");
        query.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id ");
        query.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id ");
        query.append(" inner join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id ");
        query.append(" inner join flow.project_status_type on flow.project_status_type.id = flow.company_project_status_type.project_status_type_id ");
        query.append(" left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
        query.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id ");
        query.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id ");
        query.append(" left join flow.org on flow.org.id = \"project_user_position\".org_id ");

        whereClause.append(" flow.project.archived is not true and ");
        whereClause.append(String.format(" flow.company_project_status_type.company_id = any(%s) and ", companySubquery));
        break;
      case 2:
        query.append(" from flow.contact ");
        query.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id ");
        query.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id ");
        query.append(" left join flow.project on flow.project.contact_id = flow.contact.id ");
        query.append(" left join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id ");
        query.append(" left join flow.project_status_type on flow.project_status_type.id = flow.company_project_status_type.project_status_type_id ");
        query.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id ");
        query.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id ");
        query.append(" left join flow.org on flow.org.id = \"contact_user_position\".org_id ");

          whereClause.append(" flow.project.archived is not true and ");
          whereClause.append(String.format(" flow.contact.company_id = any(%s) and ", companySubquery));
          break;
      case 3:
        query.append(" from flow.user ");
        query.append(" inner join flow.user_position on flow.user_position.user_id = flow.user.id and flow.user_position.archived is not true ");
        query.append(" inner join flow.position on flow.position.id = flow.user_position.position_id and flow.position.archived is not true ");
        query.append(" inner join flow.company_user_status on flow.company_user_status.user_id = flow.user.id and flow.company_user_status.archived is not true ");
        query.append(" inner join flow.user_status_type on flow.user_status_type.id = flow.company_user_status.user_status_type_id and flow.user_status_type.archived is not true ");
        query.append(" inner join flow.org on flow.org.id = flow.user_position.org_id and flow.org.archived is not true ");
        query.append(" inner join flow.org_type on flow.org_type.id = flow.org.org_type_id and flow.org_type.archived is not true ");
        query.append(" inner join flow.org_level on flow.org_level.id = flow.org_type.org_level_id ");
        query.append(" inner join flow.user_position_hierarchy_vw on flow.user_position_hierarchy_vw.user_id = flow.user.id and flow.user_position_hierarchy_vw.org_id = flow.org.id and flow.user_position_hierarchy_vw.position_id = flow.position.id ");
        // TODO: Level = 5 for Region is BlueRaven specific, make generic at some point to support other companies
        query.append(" left join lateral jsonb_array_elements(user_position_hierarchy_vw.hierarchy) obj(val) ON obj.val->>'level' = '5' ");


        whereClause.append(" flow.user.archived is not true and ");
        whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));
        whereClause.append(String.format(" flow.position.company_id = any(%s) and ", companySubquery));
        whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));
        whereClause.append(String.format(" flow.org.company_id = any(%s) and ", companySubquery));

        if (smartlist.isPrimaryUserPosition()) {
          whereClause.append(" flow.user_position.primary_flag is true and ");
        }

        break;
      case 5:
        query.append(" from flow.org ");
        query.append(" inner join flow.org_type on flow.org_type.id = flow.org.org_type_id and flow.org_type.archived is not true ");
        query.append(" inner join flow.org_level on flow.org_level.id = flow.org_type.org_level_id ");

        whereClause.append(" flow.org.archived is not true and ");
        whereClause.append(String.format(" flow.org.company_id = any(%s) and ", companySubquery));

        final boolean anyUserField = fields.stream().anyMatch(f -> f.getObjectTypeId() == 3);
        final boolean anyUserRequirement = requirements.stream().anyMatch(r -> r.getObjectTypeId() == 3);

        if (anyUserField || anyUserRequirement) {
          query.append(" inner join flow.user_position on flow.user_position.org_id = flow.org.id and flow.user_position.archived is not true ");
          query.append(" inner join flow.user on flow.user.id = flow.user_position.user_id and flow.user.archived is not true ");
          query.append(" inner join flow.position on flow.position.id = flow.user_position.position_id and flow.position.archived is not true ");
          query.append(" inner join flow.company_user_status on flow.company_user_status.user_id = flow.user.id and flow.company_user_status.archived is not true ");
          query.append(" inner join flow.user_status_type on flow.user_status_type.id = flow.company_user_status.user_status_type_id and flow.user_status_type.archived is not true ");
          query.append(" inner join flow.user_position_hierarchy_vw on flow.user_position_hierarchy_vw.user_id = flow.user.id and flow.user_position_hierarchy_vw.org_id = flow.org.id and flow.user_position_hierarchy_vw.position_id = flow.position.id ");
          // TODO: Level = 5 for Region is BlueRaven specific, make generic at some point to support other companies
          query.append(" left join lateral jsonb_array_elements(user_position_hierarchy_vw.hierarchy) obj(val) ON obj.val->>'level' = '5' ");

          whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));
          whereClause.append(String.format(" flow.position.company_id = any(%s) and ", companySubquery));
          whereClause.append(String.format(" flow.user_status_type.company_id = any(%s) and ", companySubquery));

          if (smartlist.isPrimaryUserPosition()) {
            whereClause.append(" flow.user_position.primary_flag is true and ");
          }

        }

        break;
      }
    } else {
      //this is all required for the work queue stuff
      query.append(
        "from flow.project\n" +
        "         inner join flow.contact on flow.contact.id = flow.project.contact_id" +
        "         left join flow.user_position on flow.user_position.id = flow.contact.owner_user_position_id\n" +
        "         left join flow.user on flow.user.id = flow.user_position.user_id" +
        "         inner join flow.company_process cp on cp.id = flow.project.company_process_id\n" +
        "         inner join flow.project_process_step on flow.project_process_step.project_id = flow.project.id\n" +
        "         inner join flow.company_project_status_type cpst on cpst.id = flow.project.company_project_status_type_id\n" +
        "         inner join flow.process_step on flow.process_step.id = flow.project_process_step.process_step_id\n" +
        "         inner join flow.process_step_work_queue_type pswqt on pswqt.process_step_id = flow.process_step.id\n" +
        "         inner join flow.work_queue_type wqt on wqt.id = pswqt.work_queue_type_id\n" +
        "         inner join flow.company_process_step_status_type cpsst on cpsst.id = flow.project_process_step.company_process_step_status_type_id\n" +
        "         left join flow.company_state cs on cs.id = flow.project.company_state_id\n" +
        "         left join flow.state st on st.id = cs.state_id\n" +
        "         left join flow.user_position up on up.id = flow.project_process_step.user_position_id\n" +
        "         left join flow.user u on u.id = up.user_id\n" +
        "         inner join ps_wq_statuses pws on pws.process_step_id = flow.process_step.id and (pws.process_step_status_type_id = cpsst.process_step_status_type_id OR pws.company_process_step_status_type_id = cpsst.id)\n" +
        "         inner join pj_wq_statuses pjws on pjws.process_step_id = flow.process_step.id and (pjws.project_status_type_id = cpst.project_status_type_id OR pjws.company_project_status_type_id = flow.project.company_project_status_type_id)\n" +
        "         left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id \n" +
        "         left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id \n" +
        "         left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id \n" +
        "         left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id \n");
    }

    if (installationCrewIds != null && !installationCrewIds.isEmpty() && companyId == 3) {
      query.append("         inner join brs.project_details on brs.project_details.project_id = flow.project.id \n");
    }

    for (SmartlistFieldAssignment f : joinTables) {
      final String joinAlias = (f.getSystemListTypeId() != null || (f.getJoinTable() != null && f.getJoinColumn() != null) || Objects.equals(f.getAllowMultiple(), true)) ? f.getValueReferenceTable() : f.getReferenceTable();

      if (f.getSmartlistSystemListId() == null) {
        if (List.of(1, 2, 3, 5).contains(f.getObjectTypeId().intValue())) {

          String joinField = "";
          String joinedTable = "";

          if (f.getObjectTypeId() == 1 || f.getObjectTypeId() == 2) {
            joinField = (f.getObjectTypeId() == 1) ? "project_id" : "contact_id";
            joinedTable = (f.getObjectTypeId() == 1) ? "project" : "contact";
          } else if (f.getObjectTypeId() == 3) {
            joinField = "user_id";
            joinedTable = "user";
          } else if (f.getObjectTypeId() == 5) {
            joinField = "org_id";
            joinedTable = "org";
          }

          if ((f.getHasListValues() != null && f.getHasListValues()) || f.getCustomFieldSqlKey() != null) {

            if (f.getValueReferenceTable() == null) {
              f.setValueReferenceTable(UUID.randomUUID().toString());
            }
            final String valueTable = f.getValueReferenceTable();

            query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.%s.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), valueTable, valueTable, joinField, joinedTable, valueTable, f.getCustomFieldGroupAssignmentId()));

            if (f.getCustomFieldSqlKey() != null) {
              //custom value sql
              query.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", f.getCustomFieldSqlKey(), joinAlias, joinAlias, valueTable));
            } else if (!f.getAllowMultiple()) {
              query.append(String.format(" left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", joinAlias, joinAlias, valueTable));
            }
          } else if (!Objects.equals(f.getReferenceTable(), "flow.project_user") && !Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
            if (f.getJoinTable() != null && f.getJoinColumn() != null) {
              query.append(String.format(" left join %s \"%s\" on \"%s\".id = %s.%s", f.getReferenceTable(), joinAlias, joinAlias, f.getJoinTable(), f.getJoinColumn()));
            } else {
              query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.%s.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), joinAlias, joinAlias, joinField, joinedTable, joinAlias, f.getCustomFieldGroupAssignmentId()));
            }
          }
        } else if (f.getObjectTypeId() == 4) {

          // If this is a system field
          if (f.getCustomFieldGroupAssignmentId() == null && f.getProcessStepId() != null) {
            if (f.getJoinTable() != null && f.getJoinColumn() != null) {
              final String joinUuid = UUID.randomUUID().toString();
              query.append(String.format(" left join %s \"%s\" on \"%s\".process_step_id = %s and \"%s\".project_id = flow.project.id ", f.getJoinTable(), joinUuid, joinUuid, f.getProcessStepId(), joinUuid));
              if (smartlist.isMainProcessSteps()) {
                query.append(String.format("and \"%s\".main is true ", joinUuid));
              }

              if (f.getReferenceTable().equals("flow.user")) {
                // @TODO: This creates a duplicate join on project_process_step if the process step already being used in a previous field
                final String joinUserPosition = UUID.randomUUID().toString();
                query.append(String.format(" left join flow.user_position \"%s\" on \"%s\".id = \"%s\".%s ", joinUserPosition, joinUserPosition, joinUuid, f.getJoinColumn()));
                query.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".user_id ", f.getReferenceTable(), joinAlias, joinAlias, joinUserPosition));
                f.setUserPositionTable(joinUserPosition);
              } else {
                query.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s " , f.getReferenceTable(), joinAlias, joinAlias, joinUuid, f.getJoinColumn()));
              }
            } else {
              query.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", f.getPpsTable(), f.getPpsTable(), f.getPpsTable(), f.getProcessStepId()));
              if (smartlist.isMainProcessSteps()) {
                query.append(String.format("and \"%s\".main is true ", f.getPpsTable()));
              }
            }
          } else {
            query.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", f.getPpsTable(), f.getPpsTable(), f.getPpsTable(), f.getProcessStepId()));
            if (smartlist.isMainProcessSteps()) {
              query.append(String.format("and \"%s\".main is true ", f.getPpsTable()));
            }

            if (f.getHasListValues() != null && f.getHasListValues()) {
              if (f.getAllowMultiple()) {
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), joinAlias, joinAlias, f.getPpsTable(), joinAlias, f.getCustomFieldGroupAssignmentId()));
              } else {
                final String ppscfvUUID = UUID.randomUUID().toString();
                f.setValueReferenceTable(ppscfvUUID);
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), ppscfvUUID, ppscfvUUID, f.getPpsTable(), ppscfvUUID, f.getCustomFieldGroupAssignmentId()));
                query.append(String.format(" left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", joinAlias, joinAlias, ppscfvUUID));
              }
            } else {
              if (f.getCustomFieldSqlKey() != null) {
                final String ppscfvUUID = UUID.randomUUID().toString();
                f.setValueReferenceTable(ppscfvUUID);
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), ppscfvUUID, ppscfvUUID, f.getPpsTable(), ppscfvUUID, f.getCustomFieldGroupAssignmentId()));
                query.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", f.getCustomFieldSqlKey(), joinAlias, joinAlias, ppscfvUUID));
              } else {
                query.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), joinAlias, joinAlias, f.getPpsTable(), joinAlias, f.getCustomFieldGroupAssignmentId()));
              }
            }
          }
        }
      } else if (f.getSmartlistSystemListId() == 2) {
        String joinTable;
        try {
          joinTable = joinTables.stream()
            .filter(t -> t.getProcessStepId() != null && f.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))
            .map(t -> {
              if (t.getPpsTable() != null) {
                return t.getPpsTable();
              } else {
                return t.getValueReferenceTable();
              }
            })
            .findFirst()
            .orElse(null);

          if (joinTable == null) {
            joinTable = UUID.randomUUID().toString();
          }
        } catch (NullPointerException e) {
          joinTable = UUID.randomUUID().toString();
        }

        if (query.indexOf("left join flow.project_process_step \"" + joinTable) == -1) {
          query.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", joinTable, joinTable, joinTable, f.getProcessStepId()));
          if (smartlist.isMainProcessSteps()) {
            query.append(String.format("and \"%s\".main is true ", joinTable));
          }
        }
      }
    }

      for (SmartlistRequirement r : requirements) {

          String referenceLocation = "";

          if (r.getSmartlistSystemListId() != null) {
            String referenceTable = "";
            final String smartlistSystemListTable = String.format("smartlist.systemlist.%s", r.getSmartlistSystemListId());

            if (List.of(1, 3, 5, 6, 7, 8, 9).contains(r.getSmartlistSystemListId().intValue())) {
              if (additionalJoins.indexOf(String.format("left join (select * from flow.get_smartlist_system_list_options(%s::int, %s", r.getSmartlistSystemListId(), r.getCompanyId())) == -1) {
                referenceTable = UUID.randomUUID().toString();
                final String subquery = String.format("select * from flow.get_smartlist_system_list_options(%s::int, %s::int)", r.getSmartlistSystemListId(), r.getCompanyId());
                additionalJoins.append(String.format(" left join (%s) \"%s\" on \"%s\".id = %s.%s ", subquery, referenceTable, referenceTable, r.getJoinTable(), r.getJoinColumn()));
              }
            } else if (r.getSmartlistSystemListId() == 2 || r.getSmartlistSystemListId() == 4) {
              String joinTable;
              try {
                joinTable = joinTables.stream()
                  .filter(t -> t.getProcessStepId() != null && r.getProcessStepId() != null && t.getProcessStepId().equals(r.getProcessStepId()))
                  .map(t -> {
                    if (t.getPpsTable() != null) {
                      return t.getPpsTable();
                    } else {
                      return t.getValueReferenceTable();
                    }
                  })
                  .findFirst()
                  .orElse(null);

                if (joinTable == null) {
                  joinTable = UUID.randomUUID().toString();
                }
              } catch (NullPointerException e) {
                joinTable = UUID.randomUUID().toString();
              }

              if (additionalJoins.indexOf(joinTable) == -1 && query.indexOf(joinTable) == -1) {
                additionalJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", joinTable, joinTable, joinTable, r.getProcessStepId()));
                if (smartlist.isMainProcessSteps()) {
                  additionalJoins.append(String.format("and \"%s\".main is true ", joinTable));
                }
              }

              referenceTable = UUID.randomUUID().toString();
              additionalJoins.append(String.format(" left join flow.company_process_step_status_type \"%s\" on \"%s\".id = \"%s\".company_process_step_status_type_id ", referenceTable, referenceTable, joinTable));

              if (r.getSmartlistSystemListId() == 4) {
                final String newReferenceTable = UUID.randomUUID().toString();
                additionalJoins.append(String.format(" left join flow.process_step_status_type \"%s\" on \"%s\".id = \"%s\".process_step_status_type_id ", newReferenceTable, newReferenceTable, referenceTable));
                referenceTable = newReferenceTable;
              }
            }
            referenceLocation = (r.getSmartlistFieldId() == 1) ? String.format("\"%s\".id", referenceTable) : String.format("array[\"%s\".id]::int[]", referenceTable);
          } else if (r.getCustomFieldGroupAssignmentId() != null) {

//              SmartlistQuery smartlistQuery = addCustomFieldRequirement(r, joinTables, smartlist);
//
//              query.append(smartlistQ)

            String referenceColumn;
            if (r.getHasListValues() != null && r.getHasListValues() && !r.getAllowMultiple()) {
              referenceColumn = "int_value";
            } else if (r.getCustomFieldSqlKey() != null) {
              referenceColumn = "id";
            } else {
              referenceColumn = getReferenceColumn(r.getDataTypeId());
            }

              // see if table we need is already been joined, if so use it
              final String referenceTable = joinTables.stream()
                  .filter(t -> t.getCustomFieldGroupAssignmentId()!= null && t.getCustomFieldGroupAssignmentId().equals(r.getCustomFieldGroupAssignmentId()))
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
                  referenceLocation = "\"" + referenceTable + "\"." + referenceColumn;
              } else {
                  // Do a new join from custom field value table based on object type
                  if (r.getObjectTypeId() == 4) {

                      final String ppsUUID = UUID.randomUUID().toString();
                      final String ppscfvUUID = UUID.randomUUID().toString();

                      additionalJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, r.getProcessStepId()));
                      if (smartlist.isMainProcessSteps()) {
                        additionalJoins.append(String.format("and \"%s\".main is true ", ppsUUID));
                      }

                      if (r.getCustomFieldSqlKey() != null) {
                          final String  customSqlUuid = UUID.randomUUID().toString();

                          additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), customSqlUuid, customSqlUuid, ppsUUID, customSqlUuid, r.getCustomFieldGroupAssignmentId()));
                          additionalJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", r.getCustomFieldSqlKey(), ppscfvUUID, ppscfvUUID, customSqlUuid));
                      } else {
                          additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, r.getCustomFieldGroupAssignmentId()));
                      }

                      referenceLocation = "\"" + ppscfvUUID + "\"." + referenceColumn;
                  } else {
                      final String valueUuid = UUID.randomUUID().toString();

                      if (r.getCustomFieldSqlKey() != null) {

                          final String customSqlUuid = UUID.randomUUID().toString();

                          if (r.getObjectTypeId() == 1) {
                              additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
                          } else if (r.getObjectTypeId() == 2) {
                              additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
                          } else if (r.getObjectTypeId() == 3) {
                            additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".user_id = flow.user.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
                          } else if (r.getObjectTypeId() == 5) {
                            additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".org_id = flow.org.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId()));
                          }
                          additionalJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", r.getCustomFieldSqlKey(), customSqlUuid, customSqlUuid, valueUuid));

                          referenceLocation = "\"" + customSqlUuid + "\".id";
                      } else {

                        String joinField = "";
                        String joinedTable = "";

                        if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
                          joinField = (r.getObjectTypeId() == 1) ? "project_id" : "contact_id";
                          joinedTable = (r.getObjectTypeId() == 1) ? "project" : "contact";
                        } else if (r.getObjectTypeId() == 3) {
                          joinField = "user_id";
                          joinedTable = "user";
                        } else if (r.getObjectTypeId() == 5) {
                          joinField = "org_id";
                          joinedTable = "org";
                        }

                        query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.%s.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, joinField, joinedTable, valueUuid, r.getCustomFieldGroupAssignmentId()));
                        referenceLocation = "\"" + valueUuid + "\"." + referenceColumn;
                      }
                  }
              }
          } else {
              if (r.getJoinTable() != null && r.getJoinColumn() != null) {

                // see if table we need is already been joined, if so use it
                String referenceTable;
                try {
                  referenceTable = joinTables.stream()
                    .filter(t -> t.getProcessStepId() != null && t.getProcessStepId().equals(r.getProcessStepId()))
                    .map(t -> {
                      if (Objects.equals(t.getReferenceTable(), "flow.user")) {
                        return (t.getObjectTypeId() == 4) ? t.getUserPositionTable() : "flow.user_position";
                      } else {
                        return t.getValueReferenceTable();
                      }
                    })
                    .findFirst()
                    .orElse(null);
                } catch (NullPointerException e) {
                  referenceTable = null;
                }

                if (referenceTable != null) {
                  referenceLocation = "\"" + referenceTable + "\".id";
                } else {
                  if (r.getObjectTypeId() == 4 && r.getProcessStepId() != null) {
                    final String joinUuid = UUID.randomUUID().toString();
                    final String referenceUuid = UUID.randomUUID().toString();

                    additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".process_step_id = %s and \"%s\".project_id = flow.project.id ", r.getJoinTable(), joinUuid, joinUuid, r.getProcessStepId(), joinUuid));

                    if (Objects.equals(r.getReferenceTable(), "flow.user")) {
                      additionalJoins.append(String.format(" left join flow.user_position \"%s\" on \"%s\".id = \"%s\".%s ", referenceUuid, referenceUuid, joinUuid, r.getJoinColumn()));
                    } else {
                      additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".id = \"%s\".%s " , r.getReferenceTable(), referenceUuid, referenceUuid, joinUuid, r.getJoinColumn()));
                    }

                    referenceLocation = String.format("\"%s\".id", referenceUuid);
                  } else {
                    if (Objects.equals(r.getReferenceTable(), "flow.user")) {
                      referenceLocation = "flow.user_position.id";
                    } else if (Objects.equals(r.getReferenceTable(), "flow.project_user")) {
                      referenceLocation = "\"project_user_position\".id";
                    } else if (Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
                      referenceLocation = "\"contact_user_position\".id";
                    } else {
                      // see if table we need is already been joined, if so use it
                      final String table = joinTables.stream()
                        .filter(t -> (t.getJoinTable() != null && t.getJoinColumn() != null) && t.getJoinTable().equals(r.getJoinTable()) && t.getJoinColumn().equals(r.getJoinColumn()))
                        .map(SmartlistFieldAssignment::getValueReferenceTable)
                        .findFirst()
                        .orElse(null);

                      if (table != null) {
                        referenceLocation = "\"" + table + "\".id";
                      } else {
                        final String referenceUuid = UUID.randomUUID().toString();
                        additionalJoins.append(String.format(" left join %s \"%s\" on \"%s\".id = %s.%s", r.getReferenceTable(), referenceUuid, referenceUuid, r.getJoinTable(), r.getJoinColumn()));
                        referenceLocation = String.format("\"%s\".id", referenceUuid);
                      }
                    }
                  }
                }
              } else {
                if (List.of(1, 2, 3, 5).contains(r.getObjectTypeId().intValue())) {
                  referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
                } else if (r.getObjectTypeId() == 4) {
                  String joinTable = null;
                  try {
                    joinTable = joinTables.stream()
                      .filter(t -> t.getProcessStepId() != null && r.getProcessStepId() != null && t.getProcessStepId().equals(r.getProcessStepId()))
                      .map(t -> {
                        if (Objects.equals(r.getReferenceTable(), "flow.project_process_step")) {
                          return t.getPpsTable();
                        } else {
                          return t.getReferenceTable();
                        }
                      })
                      .findFirst()
                      .orElse(null);

                  } catch (NullPointerException e) {
                    // noop
                  }
                  if (joinTable == null) {
                    joinTable = UUID.randomUUID().toString();
                    additionalJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", joinTable, joinTable, joinTable, r.getProcessStepId()));
                    if (smartlist.isMainProcessSteps()) {
                      additionalJoins.append(String.format("and \"%s\".main is true ", joinTable));
                    }
                  }

                  referenceLocation = String.format("\"%s\".%s", joinTable, r.getReferenceColumn());
                }
              }
          }

          Object requirementValue = getRequirementValue(r);
          String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

          //Check for double negative with "nots" between operator and requirement
          if (r.getDataTypeRequirementId() != null) {
            if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
              operator = operator.replace("not", "");

              if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
                requirementValue = requirementValue.toString().replace("not", "");
              }
            }
          }

          if (r.getDataTypeId() == 7) {
            if (r.getDataTypeRequirementId() != null) {
              whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              whereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
            }
          } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
            //if this is a text requirement using null/not null requirement
            if (r.getDataTypeId() == 5 && r.getDataTypeRequirementId() != null) {
              //treat empty strings as null
              whereClause.append(String.format(" nullif(trim(%s), '') %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            }
          } else {
            if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
              whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
                whereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
              } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
                whereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
              } else {
                if (r.getSmartlistSystemListId() != null) {
                  whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
                } else {
                  // If this field is process step owner,
                  // OR if this field is project owner,
                  // OR if this field is contact owner,
                  // make sure we're getting past instances where this user had the same position and not just the current primary position
                  if ((r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) || (r.getObjectTypeId() == 1 && Objects.equals(r.getReferenceTable(), "flow.project_user")) || (r.getObjectTypeId() == 2 && Objects.equals(r.getReferenceTable(), "flow.contact_user")) ) {
                    final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                    whereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
                  } else {
                    whereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
                  }
                }
              }
            }
          }
      }

      if (smartlist.isMainProcessSteps() && smartlist.getObjectTypeId() == 4) {
        whereClause.append(" flow.project_process_step.main is true and ");
      }

     if (installationCrewIds != null && !installationCrewIds.isEmpty() && companyId == 3) {
        whereClause.append(String.format(" brs.project_details.installation_resource in (%s) and ", installationCrewIds.toString().replace("[", "").replace("]", "")));
      }

      if(null != smartlist.getWorkQueueTypeId()) {
        whereClause.append(" pswqt.work_queue_type_id = " + smartlist.getWorkQueueTypeId() + "\n" +
          "  and pswqt.archived is not true\n" +
          "  and flow.project_process_step.archived is not true\n" +
          "  and flow.project.archived is not true\n" +
          "  and flow.project_process_step.main is true\n" +
          "      and flow.process_step.company_id = any\n" +
          "                        (select id from flow.company_hierarchy_filter_down(" + companyId + ")) and ");
      }

    if (withClause.length() > 0) {
        // Remove comma and space from last with table
        withClause.deleteCharAt(withClause.length() - 1);
        withClause.deleteCharAt(withClause.length() - 1);

        query.insert(0, "with " + withClause.toString());
    }

    query.append(additionalJoins.toString());

    if (whereClause.length() > 0) {
        query.append("  where ").append(whereClause.toString());

        // remove the last "and "
        query = query.delete(query.length() - 5, query.length());
    }

    if(null != smartlist.getWorkQueueTypeId()) {
      query.append(" order by \"Days In Queue\" desc ");
    }

    query.append(";");

    return query.toString();
  }

  private String buildProcessStepSql(Smartlist smartlist, List<SmartlistFieldAssignment> fields) {

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    List<SmartlistRequirement> requirements = this.getRequirements(smartlist.getId(), false);

    StringBuilder query = new StringBuilder();

    List<Long> usedProcessStepIds = new ArrayList<>();

    StringBuilder customSqlQueries = new StringBuilder();

    //start of overall query
    query.append("with ");

    // Get smartlist system lists
    query.append(String.format("\"smartlistSystemList_1\" as (select * from flow.get_smartlist_system_list_options(1::int, %s::int)), ", companyId));
    query.append(String.format("\"smartlistSystemList_2\" as (select * from flow.get_smartlist_system_list_options(2::int, %s::int)), ", companyId));
    query.append(String.format("\"smartlistSystemList_3\" as (select * from flow.get_smartlist_system_list_options(3::int, %s::int)), ", companyId));
    query.append(String.format("\"smartlistSystemList_4\" as (select * from flow.get_smartlist_system_list_options(4::int, %s::int)), ", companyId));
    query.append(String.format("\"smartlistSystemList_5\" as (select * from flow.get_smartlist_system_list_options(5::int, %s::int)), ", companyId));

    // Get tables for system lists
    query.append("\"systemList_1\" as (select up.id, concat(u.first_name, ' ', u.last_name::text) as name from flow.user_position up inner join flow.user u on u.id = up.user_id), ");
    query.append("\"systemList_3\" as (select id, org_name::text as name from flow.org), ");
    query.append("\"systemList_4\" as (select id, concat(first_name, ' ', last_name::text) as name from flow.user), ");

    //build project IDs CTE
    StringBuilder projectsClause = new StringBuilder();
    StringBuilder projectsValueJoins = new StringBuilder();
    StringBuilder projectsWhereClause = new StringBuilder();

    projectsClause.append("select distinct flow.project.id ");
    projectsClause.append("from flow.project ");
    projectsClause.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id");
    projectsClause.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id");
    projectsClause.append(" inner join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true");
    projectsClause.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id");
    projectsClause.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id");

    requirements.forEach(r -> {

      String referenceLocation = null;

      //join value tables for custom fields
      if (r.getCustomFieldSqlKey() == null && r.getCustomFieldGroupAssignmentId() != null) {
        r.setValueReferenceTable(UUID.randomUUID().toString());

        //join the value table for the respective field object type
        if (r.getObjectTypeId() == 1) {
          projectsValueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getValueReferenceTable(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable()));
        } else if (r.getObjectTypeId() == 2) {
          projectsValueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getValueReferenceTable(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable()));
        } else if (r.getObjectTypeId() == 4) {
          r.setPpsTable(UUID.randomUUID().toString());
          projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
          if (smartlist.isMainProcessSteps()) {
            projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
          }
          projectsValueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getPpsTable(), r.getValueReferenceTable(), r.getCustomFieldGroupAssignmentId(), r.getValueReferenceTable()));
        }
      }

      if (r.getSmartlistSystemListId() != null) {
        //smartlist system list
        if (List.of(1L, 3L, 5L).contains(r.getSmartlistSystemListId())) {
            referenceLocation = String.format("array[%s.%s]::int[]", r.getJoinTable(), r.getJoinColumn());
        } else if (r.getSmartlistSystemListId() == 2 || r.getSmartlistSystemListId() == 4) {
          final String processStepStatusTable = UUID.randomUUID().toString();

          if (r.getPpsTable() == null) {
            r.setPpsTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
            if (smartlist.isMainProcessSteps()) {
              projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
            }
          }

          projectsValueJoins.append(String.format(" left join flow.company_process_step_status_type \"%s\" on \"%s\".id = \"%s\".company_process_step_status_type_id", processStepStatusTable, processStepStatusTable, r.getPpsTable()));
          final String column = (r.getSmartlistSystemListId() == 2) ? "id" : "process_step_status_type_id";
          referenceLocation = String.format("array[\"%s\".%s]::int[]", processStepStatusTable, column);
        }
      } else if (r.getSmartlistFieldId() != null) {
        //smartlist field
        if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
          referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
        } else if (r.getObjectTypeId() == 4) {

          r.setPpsTable(UUID.randomUUID().toString());
          String joinTable = r.getPpsTable();
          String joinColumn = r.getReferenceColumn();
          projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
          if (smartlist.isMainProcessSteps()) {
            projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
          }

          if (Objects.equals(r.getReferenceTable(), "flow.process_step")) {
            r.setValueReferenceTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.process_step \"%s\" on \"%s\".id = \"%s\".process_step_id", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getPpsTable()));
            joinTable = r.getValueReferenceTable();
          } else if (r.getReferenceTable().equals("flow.user")) {
            // Since this is a process step smartlist field, if it's looking at the user table, it's the process step owner field
            joinColumn = "user_position_id";
          }

          referenceLocation = String.format("\"%s\".%s", joinTable, joinColumn);
        }
      } else {
        //custom field
        if (r.getCustomFieldSqlKey() != null) {

          r.setValueReferenceTable(UUID.randomUUID().toString());
          final String referenceTable = UUID.randomUUID().toString();

          if (r.getObjectTypeId() == 1) {
            projectsValueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          } else if (r.getObjectTypeId() == 2) {
            projectsValueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          } else if (r.getObjectTypeId() == 4) {

            r.setPpsTable(UUID.randomUUID().toString());
            projectsValueJoins.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s and \"%s\".archived is not true", r.getPpsTable(), r.getPpsTable(), r.getPpsTable(), r.getProcessStepId(), r.getPpsTable()));
            if (smartlist.isMainProcessSteps()) {
              projectsValueJoins.append(String.format(" and \"%s\".main is true ", r.getPpsTable()));
            }
            projectsValueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s and \"%s\".archived is not true", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId(), referenceTable));
          }

          projectsValueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", r.getCustomFieldSqlKey(), r.getValueReferenceTable(), r.getValueReferenceTable(), referenceTable));

          referenceLocation = String.format("\"%s\".id", r.getValueReferenceTable());
        } else if (r.getCompanySystemListId() != null) {

          final long systemListNumber = (r.getSystemListId() == 1 || r.getSystemListId() == 2) ? 1 : r.getSystemListId();
          final String systemListTable = "systemList_" + systemListNumber;

          //Currently, we don't check if the system list is already joined on this cfgaId. We could do that to eliminate potential duplicates
          final String newValueTable = UUID.randomUUID().toString();
          projectsValueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListTable, newValueTable, newValueTable, r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId())));
          r.setValueReferenceTable(newValueTable);

          referenceLocation = String.format("\"%s\".id", newValueTable);
        } else {
          referenceLocation = String.format("\"%s\".%s", r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId()));
        }
      }

      Object requirementValue = getRequirementValue(r);
      String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

      //Check for double negative with "nots" between operator and requirement
      if (r.getDataTypeRequirementId() != null) {
        if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
          operator = operator.replace("not", "");

          if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
            requirementValue = requirementValue.toString().replace("not", "");
          }
        }
      }

      if (r.getDataTypeId() == 7) {
        if (r.getDataTypeRequirementId() != null) {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          projectsWhereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
        }
      } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
        //if this is a text requirement using null/not null requirement
        if (r.getDataTypeId() == 5 && r.getDataTypeRequirementId() != null) {
          //treat empty strings as null
          projectsWhereClause.append(String.format(" nullif(trim(%s), '') %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        }
      } else if(Objects.equals(r.getReferenceTable(), "flow.project_user")) {
        projectsWhereClause.append(String.format("\"project_user_position\".id = %s and ", requirementValue));
      } else if(Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
        projectsWhereClause.append(String.format("\"contact_user_position\".id = %s and ", requirementValue));
      } else {
        if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
          projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
        } else {
          if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
            projectsWhereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
            projectsWhereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
          } else {
            if (r.getSmartlistSystemListId() != null) {
              projectsWhereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              // If this field is process step owner, make sure we're getting past instances where this user had the same position and not just the current primary position
              if (r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) {
                final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                projectsWhereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
              } else {
                projectsWhereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
              }
            }
          }
        }
      }
    });

    projectsClause.append(projectsValueJoins.toString());
    projectsClause.append(" where" + projectsWhereClause.toString());

    projectsClause.append(" flow.project.archived is not true");

    query.append(String.format("\"projects\" as (%s), ", projectsClause.toString()));

    for(SmartlistFieldAssignment f : fields) {
      if (f.getProcessStepId() != null && !usedProcessStepIds.contains(f.getProcessStepId())) {
        usedProcessStepIds.add(f.getProcessStepId());
      }

      //prepend custom field sql queries
      if (f.getCustomFieldSqlKey() != null && customSqlQueries.indexOf(f.getCustomFieldSqlKey()) == -1) {
        customSqlQueries.append(String.format("\"%s\" as (%s), ", f.getCustomFieldSqlKey(), sqlCache.getByKey(f.getCustomFieldSqlKey() + ".smartlist")));
      }
    }

    if (customSqlQueries.length() > 0) {
      query.append(customSqlQueries.toString());
    }

    if (usedProcessStepIds.isEmpty()) {
      //at this point, the only fields are project/contact, so this is essentially a project/contact smartlist
      //set smartlist object type to "project" and build sql like usual
      smartlist.setObjectTypeId(1L);
      return buildSql(smartlist, fields);
    }

    for(Long processStepId : usedProcessStepIds) {

      SmartlistFieldAssignment psField = fields.stream()
        .filter(f -> Objects.equals(processStepId, f.getProcessStepId()))
        .findFirst()
        .orElse(null);

      //we know this case won't happen, but defensive programming
      if (psField == null) {
        break;
      }

      // grab all fields using this process step will use
      List<SmartlistFieldAssignment> psFields = fields.stream()
        .filter(f -> f.getProcessStepId() == null || f.getProcessStepId().equals(processStepId))
        .sorted(Comparator.comparing(SmartlistFieldAssignment::getDisplayOrder))
        .collect(Collectors.toList());

      StringBuilder withClause = new StringBuilder("\"" + psField.getProcessStepName() + processStepId + "\" as (");

      StringBuilder selectFields = new StringBuilder();
      psFields.forEach(f -> {
        f.setValueReferenceTable(UUID.randomUUID().toString());

        if (f.getSmartlistSystemListId() != null) {
          final String smartlistSystemListTable = "smartlistSystemList_" + f.getSmartlistSystemListId();

          if (List.of(1L, 3L, 5L).contains(f.getSmartlistSystemListId())) {
            selectFields.append(String.format("(select name from \"%s\" where \"%s\".id = %s.%s) as \"%s\", ", smartlistSystemListTable, smartlistSystemListTable, f.getJoinTable(), f.getJoinColumn(), f.getId()));
          } else if (f.getSmartlistSystemListId() == 2 || f.getSmartlistSystemListId() == 4) {
            if (f.getSmartlistSystemListId() == 2) {
              selectFields.append(String.format("(" +
                "select name " +
                "from \"%s\" " +
                "inner join flow.company_process_step_status_type cpsst on cpsst.id = flow.project_process_step.%s " +
                "where \"%s\".id = cpsst.id) as \"%s\", ", smartlistSystemListTable, f.getJoinColumn(), smartlistSystemListTable, f.getId()));
            } else {
              selectFields.append(String.format("(" +
                "select name " +
                "from \"%s\" " +
                "inner join flow.company_process_step_status_type cpsst on cpsst.id = flow.project_process_step.%s " +
                "where \"%s\".id = cpsst.process_step_status_type_id) as \"%s\", ", smartlistSystemListTable, f.getJoinColumn(), smartlistSystemListTable, f.getId()));
            }
          }

        } else if (f.getProcessStepId() != null) {
          if (f.getSystemListId() != null) {
            final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();
            selectFields.append(String.format("(select name from \"systemList_%s\" where \"systemList_%s\".id = \"%s\".int_value) as \"%s\", ", systemListNumber, systemListNumber, f.getValueReferenceTable(), f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.user")) {
            selectFields.append(String.format("concat(\"%s\".first_name, ' ', \"%s\".last_name) as \"%s\", ", f.getValueReferenceTable(), f.getValueReferenceTable(), f.getId()));
          } else if (Objects.equals(f.getReferenceTable(), "flow.project_process_step") || Objects.equals(f.getReferenceTable(), "flow.process_step")) {
            if (f.getDataTypeId() == 1) {
              selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if(f.getDataTypeId() == 2) {
              selectFields.append(String.format(" to_char(%s.%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 6 && Objects.equals(f.getHasListValues(), true)) {
              selectFields.append(String.format(" (select name from flow.list_of_value where id = %s.%s) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else if (f.getDataTypeId() == 7) {
              selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s.%s)), ',')) as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            } else {
              selectFields.append(String.format(" %s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
            }
          } else {
            if (f.getDataTypeId() == 1) {
              selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
            } else if(f.getDataTypeId() == 2) {
              selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
            } else if (f.getDataTypeId() == 6 && f.getHasListValues()) {
              selectFields.append(String.format(" (select name from flow.list_of_value where id = \"%s\".%s) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
            } else if (f.getDataTypeId() == 7) {
              selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(\"%s\".%s)), ',')) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
            } else if (f.getDataTypeId() == 8) {
              selectFields.append(String.format(" \"%s\".name as \"%s\", ", f.getValueReferenceTable(), f.getId()));
            } else {
              selectFields.append(String.format(" \"%s\".%s as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
            }
          }
        } else if (f.getSystemListId() != null) {
          final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

          selectFields.append(String.format("(select name from \"systemList_%s\" where \"systemList_%s\".id = \"%s\".int_value) as \"%s\", ", systemListNumber, systemListNumber, f.getValueReferenceTable(), f.getId()));
        } else {
          if (f.getCustomFieldSqlKey() != null) {
            selectFields.append(String.format("\"%s\".name as \"%s\", ", f.getValueReferenceTable(), f.getId()));
          } else {
            if (f.getCustomFieldGroupAssignmentId() != null) {
              if (f.getDataTypeId() == 1) {
                selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if(f.getDataTypeId() == 2) {
                selectFields.append(String.format(" to_char(\"%s\".%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 6 && f.getHasListValues()) {
                 selectFields.append(String.format(" (select name from flow.list_of_value where id = \"%s\".%s) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else if (f.getDataTypeId() == 7) {
                selectFields.append(String.format(" (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(\"%s\".%s)), ',')) as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              } else {
                selectFields.append(String.format(" \"%s\".%s as \"%s\", ", f.getValueReferenceTable(), getReferenceColumn(f.getDataTypeId()), f.getId()));
              }
            } else {
              if (Objects.equals(f.getReferenceTable(), "flow.project_user") || Objects.equals(f.getReferenceTable(), "flow.contact_user")) {
                selectFields.append(String.format("%s as \"%s\", ", f.getReferenceColumn(), f.getId()));
              } else {
                selectFields.append(String.format("%s.%s as \"%s\", ", f.getReferenceTable(), f.getReferenceColumn(), f.getId()));
              }
            }
          }
        }
      });

      // remove comma and space from last field
      selectFields.deleteCharAt(selectFields.length() - 2);

      withClause.append("select ").append(selectFields.toString());

      StringBuilder fromClause = new StringBuilder(" from ");

      fromClause.append(" flow.project_process_step ");
      fromClause.append(" inner join flow.company_process_step_status_type on flow.company_process_step_status_type.id = flow.project_process_step.company_process_step_status_type_id");
      fromClause.append(" inner join flow.process_step_status_type on flow.process_step_status_type.id = flow.company_process_step_status_type.process_step_status_type_id");
      fromClause.append(" inner join flow.process_step on process_step.id = project_process_step.process_step_id and process_step.id = " + processStepId);
      fromClause.append(" inner join flow.project on flow.project.id = project_process_step.project_id and flow.project.archived is not true");
      fromClause.append(" left join flow.user_position \"project_user_position\" on \"project_user_position\".id = flow.project.user_position_id");
      fromClause.append(" left join flow.user \"project_user\" on \"project_user\".id = \"project_user_position\".user_id");
      fromClause.append(" inner join flow.company_project_status_type on flow.company_project_status_type.id = flow.project.company_project_status_type_id");
      fromClause.append(" inner join flow.project_status_type on flow.project_status_type.id = flow.company_project_status_type.project_status_type_id");
      fromClause.append(" inner join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true");
      fromClause.append(" left join flow.user_position \"contact_user_position\" on \"contact_user_position\".id = flow.contact.owner_user_position_id");
      fromClause.append(" left join flow.user \"contact_user\" on \"contact_user\".id = \"contact_user_position\".user_id");
      fromClause.append(" inner join \"projects\" on \"projects\".id = flow.project_process_step.project_id");

      withClause.append(fromClause.toString());

      StringBuilder valueJoins = new StringBuilder();
      psFields.forEach(f -> {
        if (f.getSmartlistSystemListId() != null) {
          //smartlist system fields
        } else if (f.getSmartlistFieldId() != null) {
          if (f.getReferenceTable().equals("flow.user")) {
            final String joinUserPosition = UUID.randomUUID().toString();
            valueJoins.append(String.format(" inner join flow.user_position \"%s\" on \"%s\".id = flow.project_process_step.%s ", joinUserPosition, joinUserPosition, f.getJoinColumn()));
            valueJoins.append(String.format(" inner join %s \"%s\" on \"%s\".id = \"%s\".user_id ", f.getReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), joinUserPosition));
            f.setUserPositionTable(joinUserPosition);
          }
        } else {
          if (f.getCustomFieldSqlKey() != null) {

            final String referenceTable = UUID.randomUUID().toString();

            if (f.getObjectTypeId() == 1) {
              valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 2) {
              valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 4) {
              valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, f.getCustomFieldGroupAssignmentId()));
            }

            valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", f.getCustomFieldSqlKey(), f.getValueReferenceTable(), f.getValueReferenceTable(), referenceTable));

          } else {
            //join the value table for the respective field object type
            if (f.getObjectTypeId() == 1) {
              valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", f.getValueReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 2) {
              valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", f.getValueReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), f.getCustomFieldGroupAssignmentId()));
            } else if (f.getObjectTypeId() == 4) {
              valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", f.getValueReferenceTable(), f.getValueReferenceTable(), f.getValueReferenceTable(), f.getCustomFieldGroupAssignmentId()));
            }
          }
        }
      });

      StringBuilder whereClause = new StringBuilder();

      requirements.stream()
        .filter(r -> r.getProcessStepId() != null && r.getProcessStepId().equals(processStepId))
        .forEach(r -> {

        String referenceLocation = null;

        SmartlistFieldAssignment alreadyJoinedValueTable = psFields.stream()
          .filter(f -> r.getCustomFieldSqlKey() == null && r.getCustomFieldGroupAssignmentId() != null && r.getCustomFieldGroupAssignmentId().equals(f.getCustomFieldGroupAssignmentId()))
          .findFirst()
          .orElse(null);

        //join any value tables the requirements need which aren't already joined
        if (r.getCustomFieldSqlKey() == null) {
          if (alreadyJoinedValueTable == null) {
            if (r.getCustomFieldGroupAssignmentId() != null) {
              r.setValueReferenceTable(UUID.randomUUID().toString());

              //join the value table for the respective field object type
              if (r.getObjectTypeId() == 1) {
                valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getValueReferenceTable(), r.getCustomFieldGroupAssignmentId()));
              } else if (r.getObjectTypeId() == 2) {
                valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getValueReferenceTable(), r.getCustomFieldGroupAssignmentId()));
              } else if (r.getObjectTypeId() == 4) {
                valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", r.getValueReferenceTable(), r.getValueReferenceTable(), r.getValueReferenceTable(), r.getCustomFieldGroupAssignmentId()));
              }
            }
          } else if (r.getCustomFieldGroupAssignmentId() != null) {
            r.setValueReferenceTable(alreadyJoinedValueTable.getValueReferenceTable());
          }
        }

        if (r.getSmartlistSystemListId() != null) {
          //smartlist system list
          if (List.of(1L, 3L, 5L).contains(r.getSmartlistSystemListId())) {
            referenceLocation = String.format("%s.%s", r.getJoinTable(), r.getJoinColumn());
          } else if (r.getSmartlistSystemListId() == 2) {
            referenceLocation = "flow.company_process_step_status_type.id";
          } else if (r.getSmartlistSystemListId() == 4) {
            referenceLocation = "flow.company_process_step_status_type.process_step_status_type_id";
          }
          if (r.getSmartlistSystemListId() != 1) {
            referenceLocation = String.format("array[%s]::int[]", referenceLocation);
          }
        } else if (r.getSmartlistFieldId() != null) {
          //smartlist field
          if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
             if(Objects.equals(r.getReferenceTable(), "flow.project_user")) {
               referenceLocation = "\"project_user_position\".id";
            } else if(Objects.equals(r.getReferenceTable(), "flow.contact_user")) {
               referenceLocation = "\"contact_user_position\".id";
            } else {
               referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
             }
          } else if (r.getObjectTypeId() == 4) {
            String joinTable;
            try {
              joinTable = fields.stream()
                .filter(f -> Objects.equals(f.getCustomFieldGroupAssignmentId(), r.getCustomFieldGroupAssignmentId()))
                .map(SmartlistFieldAssignment::getValueReferenceTable)
                .findFirst()
                .orElse(null);

              if (joinTable == null) {
                joinTable = UUID.randomUUID().toString();
              }

            } catch (NullPointerException e) {
              joinTable = UUID.randomUUID().toString();
            }

            if (r.getReferenceTable() != null && r.getReferenceTable().equals("flow.user")) {
              // Since this is a process step smartlist field, if it's looking at the user table, it's the process step owner field
              referenceLocation = "flow.project_process_step.user_position_id";
            } else if (r.getReferenceTable().contains(".")) {
              referenceLocation = String.format("%s.%s", r.getReferenceTable(), r.getReferenceColumn());
            } else {
              referenceLocation = String.format("\"%s\".%s", joinTable, r.getReferenceColumn());
            }
          }
        } else {
          //custom field
          if (r.getCustomFieldSqlKey() != null) {

            if (valueJoins.indexOf(r.getCustomFieldSqlKey()) == -1) {
              r.setValueReferenceTable(UUID.randomUUID().toString());
              final String referenceTable = UUID.randomUUID().toString();

              if (r.getObjectTypeId() == 1) {
                valueJoins.append(String.format(" left join flow.project_custom_field_value \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
              } else if (r.getObjectTypeId() == 2) {
                valueJoins.append(String.format(" left join flow.contact_custom_field_value \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
              } else if (r.getObjectTypeId() == 4) {
                valueJoins.append(String.format(" left join flow.project_process_step_custom_field_value \"%s\" on \"%s\".project_process_step_id = flow.project_process_step.id and \"%s\".custom_field_group_assignment_id = %s", referenceTable, referenceTable, referenceTable, r.getCustomFieldGroupAssignmentId()));
              }

              valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value", r.getCustomFieldSqlKey(), r.getValueReferenceTable(), r.getValueReferenceTable(), referenceTable));
            } else {
              SmartlistFieldAssignment joinedField = fields.stream()
                .filter(f -> Objects.equals(r.getCustomFieldGroupAssignmentId(), f.getCustomFieldGroupAssignmentId()))
                .findFirst()
                .orElse(null);

              //joinedField **shouldn't** ever be null here. If it is, there are bigger issues
              if (joinedField != null) {
                r.setValueReferenceTable(joinedField.getValueReferenceTable());
              }
            }

            referenceLocation = String.format("\"%s\".id", r.getValueReferenceTable());
          } else if (r.getCompanySystemListId() != null) {

            final long systemListNumber = (r.getSystemListId() == 1 || r.getSystemListId() == 2) ? 1 : r.getSystemListId();
            final String systemListTable = "systemList_" + systemListNumber;

            //Currently, we don't check if the system list is already joined on this cfgaId. We could do that to eliminate potential duplicates
            final String newValueTable = UUID.randomUUID().toString();
            valueJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".%s", systemListTable, newValueTable, newValueTable, r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId())));
            r.setValueReferenceTable(newValueTable);

            referenceLocation = String.format("\"%s\".id", newValueTable);
          } else {
            referenceLocation = String.format("\"%s\".%s", r.getValueReferenceTable(), getReferenceColumn(r.getDataTypeId()));
          }
        }

        Object requirementValue = getRequirementValue(r);
        String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId(), r.getDataTypeRequirement());

        //Check for double negative with "nots" between operator and requirement
        if (r.getDataTypeRequirementId() != null) {
          if (requirementValue != null && requirementValue.toString().contains("not") && operator != null && operator.contains("not")) {
            operator = operator.replace("not", "");

            if (List.of(5L, 13L, 17L, 19L, 21L, 25L, 27L).contains(r.getDataTypeRequirementId())) {
              requirementValue = requirementValue.toString().replace("not", "");
            }
          }
        }

        if (r.getDataTypeId() == 7) {
          if (r.getDataTypeRequirementId() != null) {
            whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
          } else {
            whereClause.append(String.format(" sort(%s) %s sort(array%s::int[]) and ", referenceLocation, operator, requirementValue));
          }
        } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 1 && r.getDataTypeId() != 2)) {
          //if this is a text requirement using null/not null requirement
          if (r.getDataTypeId() == 5 && r.getDataTypeRequirementId() != null) {
            //treat empty strings as null
            whereClause.append(String.format(" nullif(trim(%s), '') %s %s and ", referenceLocation, operator, requirementValue));
          } else {
            whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
          }
        } else {
          if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
            whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
          } else {
            if (r.getDataTypeRequirementId() != null && List.of(1L, 2L, 3L, 6L, 7L, 8L).contains(r.getDataTypeRequirementId())) {
              whereClause.append(String.format(" date_trunc('day', %s) %s date_trunc('day', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
            } else if (r.getDataTypeRequirementId() != null && List.of(9L, 10L, 11L).contains(r.getDataTypeRequirementId())) {
              whereClause.append(String.format(" date_trunc('hour', %s) %s date_trunc('hour', '%s'::timestamp) and ", referenceLocation, operator, requirementValue));
            } else {
              if (r.getSmartlistSystemListId() != null) {
                whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
              } else {
                // If this field is process step owner, make sure we're getting past instances where this user had the same position and not just the current primary position
                if (r.getObjectTypeId() == 4 && Objects.equals(r.getReferenceTable(), "flow.user")) {
                  final String positionSubquery = String.format("select id from flow.user_position where user_id = (select user_id from flow.user_position where id = %s)", requirementValue);
                  whereClause.append(String.format(" %s = any(%s) and ", referenceLocation, positionSubquery));
                } else {
                  whereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
                }
              }
            }
          }
        }
      });

      withClause.append(valueJoins.toString());

      final String companySubquery = String.format("select id from flow.company where id = %s or parent_company_id = %s", companyId, companyId);

      if (whereClause.length() > 0) {
        whereClause.append(String.format("flow.process_step.company_id = any(%s)", companySubquery));
        whereClause.append(" and flow.project_process_step.project_id = any(array[\"projects\".id])");

        withClause.append(String.format(" where %s", whereClause.toString()));
      } else {
        withClause.append(" where flow.project_process_step.project_id = any(array[\"projects\".id])");
        withClause.append(String.format(" and flow.process_step.company_id = any(%s)", companySubquery));
      }

      if (smartlist.isMainProcessSteps()) {
        withClause.append(" and flow.project_process_step.main is true");
      }

      query.append(String.format("%s), ", withClause));
    }

    // remove comma and space from with clause
    query.delete(query.length() - 2, query.length());

    List<SmartlistFieldAssignment> sortedFields = fields.stream().sorted(Comparator.comparing(SmartlistFieldAssignment::getDisplayOrder)).collect(Collectors.toList());

    usedProcessStepIds.forEach(id -> {

      Optional<SmartlistFieldAssignment> psField = fields.stream().filter(f -> Objects.equals(f.getProcessStepId(), id)).findFirst();

      StringBuilder selectClause = new StringBuilder(" select ");

      sortedFields.forEach(f -> {
        if (f.getProcessStepId() != null) {
          if (f.getProcessStepId().equals(id)) {
            selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", f.getProcessStepName() + f.getProcessStepId(), f.getId(), f.getName()));
          } else {
            selectClause.append(String.format("null as \"%s\", ", f.getName()));
          }
        } else {
          //project and contact fields
          psField.ifPresent(field -> selectClause.append(String.format("\"%s\".\"%s\" as \"%s\", ", field.getProcessStepName() + field.getProcessStepId(), f.getId(), f.getName())));
        }
      });

      // remove comma and space from select clause
      selectClause.deleteCharAt(selectClause.length() - 2);

      query.append(selectClause.toString());

      StringBuilder fromClause = new StringBuilder(" from ");


      psField.ifPresent(f -> fromClause.append(String.format("\"%s%s\"", f.getProcessStepName(), f.getProcessStepId())));

      query.append(fromClause.toString()).append(" union ");
    });

    // remove comma and space from with clause
    query.delete(query.length() - 7, query.length());

    query.append(";");

    return query.toString();
  }

//  private SmartlistQuery addCustomFieldRequirement(SmartlistRequirement r, List<SmartlistFieldAssignment> joinTables, Smartlist s) {
//
//    SmartlistQuery query = new SmartlistQuery();
//
//    String referenceColumn;
//    if (r.getHasListValues() != null && r.getHasListValues() && !r.getAllowMultiple()) {
//      referenceColumn = "int_value";
//    } else if (r.getCustomFieldSqlKey() != null) {
//      referenceColumn = "id";
//    } else {
//      referenceColumn = getReferenceColumn(r.getDataTypeId());
//    }
//
//    // see if table we need is already been joined, if so use it
//    final String referenceTable = joinTables.stream()
//      .filter(t -> t.getCustomFieldGroupAssignmentId()!= null && t.getCustomFieldGroupAssignmentId().equals(r.getCustomFieldGroupAssignmentId()))
//      .map(t -> {
//        if (t.getValueReferenceTable() != null) {
//          return t.getValueReferenceTable();
//        } else {
//          return t.getReferenceTable();
//        }
//      })
//      .findFirst()
//      .orElse(null);
//
//    if (referenceTable != null) {
//      query.setReferenceLocation("\"" + referenceTable + "\"." + referenceColumn);
//    } else {
//      // Do a new join from custom field value table based on object type
//      if (r.getObjectTypeId() == 4) {
//
//        final String ppsUUID = UUID.randomUUID().toString();
//        final String ppscfvUUID = UUID.randomUUID().toString();
//
//        query.setAdditionalJoins(query.getAdditionalJoins().append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", ppsUUID, ppsUUID, ppsUUID, r.getProcessStepId())));
//        if (s.isMainProcessSteps()) {
//          query.setAdditionalJoins(query.getAdditionalJoins().append(String.format("and \"%s\".main is true ", ppsUUID)));
//        }
//
//        if (r.getCustomFieldSqlKey() != null) {
//          final String  customSqlUuid = UUID.randomUUID().toString();
//
//          query.setAdditionalJoins(query.getAdditionalJoins().append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), customSqlUuid, customSqlUuid, ppsUUID, customSqlUuid, r.getCustomFieldGroupAssignmentId())));
//          query.setAdditionalJoins(query.getAdditionalJoins().append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", r.getCustomFieldSqlKey(), ppscfvUUID, ppscfvUUID, customSqlUuid)));
//        } else {
//          query.setAdditionalJoins(query.getAdditionalJoins().append(String.format(" left join %s \"%s\" on \"%s\".project_process_step_id = \"%s\".id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), ppscfvUUID, ppscfvUUID, ppsUUID, ppscfvUUID, r.getCustomFieldGroupAssignmentId())));
//        }
//
//        query.setReferenceLocation("\"" + ppscfvUUID + "\"." + referenceColumn);
//      } else {
//        final String valueUuid = UUID.randomUUID().toString();
//
//        if (r.getCustomFieldSqlKey() != null) {
//
//          final String customSqlUuid = UUID.randomUUID().toString();
//
//          if (r.getObjectTypeId() == 1) {
//            query.setAdditionalJoins(query.getAdditionalJoins().append(String.format(" left join %s \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId())));
//          } else if (r.getObjectTypeId() == 2) {
//            query.setAdditionalJoins(query.getAdditionalJoins().append(String.format(" left join %s \"%s\" on \"%s\".contact_id = flow.contact.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, valueUuid, r.getCustomFieldGroupAssignmentId())));
//          }
//          query.setAdditionalJoins(query.getAdditionalJoins().append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", r.getCustomFieldSqlKey(), customSqlUuid, customSqlUuid, valueUuid)));
//
//          query.setReferenceLocation("\"" + customSqlUuid + "\".id");
//        } else {
//          final String joinField = (r.getObjectTypeId() == 1) ? "project_id" : "contact_id";
//          final String joinedTable = (r.getObjectTypeId() == 1) ? "project" : "contact";
//
//          query.setQuery(query.getQuery().append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.%s.id and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, joinField, joinedTable, valueUuid, r.getCustomFieldGroupAssignmentId())));
//          query.setReferenceLocation("\"" + valueUuid + "\"." + referenceColumn);
//        }
//      }
//    }
//
//    return query;
//  }

  private String writeCsv(List<Map<String, Object>> data, List<SmartlistFieldAssignment> headers) throws JsonProcessingException {
    return writeCsv(data, headers, false);
  }

  private String writeCsv(List<Map<String, Object>> data, List<SmartlistFieldAssignment> headers, Boolean workQueueSmartlist) throws JsonProcessingException {
    CsvSchema.Builder builder = CsvSchema.builder();

    if(workQueueSmartlist) {
      //add extra headers to the beginning if wq smartlist
      String[] wqHeaders = {
        "Active Process Steps",
        "Owner",
        "State Abbreviation",
        "Days In Queue",
        "Process Step Status Type",
        "Process Step Name",
        "Project Name",
      };
      for(String header : wqHeaders) {
        SmartlistFieldAssignment sfa = new SmartlistFieldAssignment();
        sfa.setName(header);
        headers.add(0, sfa);
      }

      //add most recent note header to the end after all the custom fields
//      SmartlistFieldAssignment sfa2 = new SmartlistFieldAssignment();
//      sfa2.setName("Note Created At");
//      headers.add(sfa2);

      SmartlistFieldAssignment sfa3 = new SmartlistFieldAssignment();
      sfa3.setName("Next Follow-up Date");
      headers.add(sfa3);

      SmartlistFieldAssignment sfa4 = new SmartlistFieldAssignment();
      sfa4.setName("Note Content");
      headers.add(sfa4);

      SmartlistFieldAssignment sfa5 = new SmartlistFieldAssignment();
      sfa5.setName("Note Created By");
      headers.add(sfa5);

    }

    // Dates have to be set as string, else when written to buffer, they display as epoch milli
    for (int i = 0; i < data.size(); i++) {
      Map<String, Object> r = data.get(i);

//      for (String field : dateFields) {
//        r.put(field, (r.get(field) == null) ? "N/A" : r.get(field).toString());
//      }
      r.remove("project_id");
      r.remove("contact_id");
      if(workQueueSmartlist) {
        r.remove("processStepId");
        r.remove("projectProcessStepId");
        r.remove("workQueueType");
        r.remove("workQueueTypeId");
        r.remove("processStepWorkQueueTypeId");
        r.remove("projectId");
        r.remove("projectStatusTypeId");
        r.remove("companyProjectStatusTypeId");
        r.remove("contactId");
        r.remove("lastUpdated");
        r.remove("Owning Positions");
//        r.remove("Active Process Steps");

        //handle notes
        PGobject notesArray = ((PGobject) r.get("Notes"));
        TypeReference<List<Note>> notesRef = new TypeReference<>() {};
        List<Note> notes = om.readValue(notesArray.getValue(), notesRef);
        if(notes.size() > 0) {
          Note firstNote = notes.get(0);
          r.put("Next Follow-up Date", firstNote.getFollowUpDate());
          r.put("Note Content", firstNote.getNote());
          r.put("Note Created By", firstNote.getCreatedBy());
        } else {
          r.put("Next Follow-up Date", null);
          r.put("Note Content", null);
          r.put("Note Created By", null);
        }
        r.remove("Notes");
      }

//      HashMap<String, Object> test = new HashMap<>();
//      test.put("processStepId", r.get("processStepId"));
//      data.set(i, test);
      data.set(i, r);
    }

//    headers.remove(1);
//    headers.get(0).setName("processStepId");

    for (SmartlistFieldAssignment f : headers) {
      String headerName = f.getName();
      //if it is a work queue smartlist the custom columns have the process step name in them so this part has to be different
      if(workQueueSmartlist && null != f.getProcessStepName()) {
        headerName = f.getProcessStepName() + " - " + f.getName();
        if (headerName.length() > 63) {
          headerName = headerName.substring(0, 63);
        }
      }
      builder.addColumn(headerName, CsvSchema.ColumnType.NUMBER_OR_STRING);
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

  private String writeEmptyCsv(List<SmartlistFieldAssignment> headers) {
    List<String> preppedHeaders = headers.stream().map(SmartlistFieldAssignment::getName).collect(Collectors.toList());
    CsvSchema.Builder builder = CsvSchema.builder();
    CsvSchema schema = builder.build();
    ObjectWriter w = new CsvMapper().writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
    try (SequenceWriter toBuffer = w.writeValues(buffer)) {
      toBuffer.writeAll(preppedHeaders);
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
        //case 8 (system, customSqlKey) and 9 (system list) are handled elsewhere
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
                if (r.getSmartlistSystemListId() != null) {
                  return String.format("sort(array[%s]::int[])", r.getListOfValueId());
                }
                if (r.getIsCustomValue()) {
                    return requirementValue;
                }
                return r.getDataTypeRequirement().getDataTypeValue();
            case 6:
                if (r.getIsCustomValue()) {
                    return (r.getHasListValues() != null && r.getHasListValues() && r.getListOfValueId() != null) ? r.getListOfValueId() : Long.parseLong(requirementValue);
                }
                return r.getDataTypeRequirement().getDataTypeValue();
            case 7:
                if (r.getIsCustomValue()) {
                    return r.getListOfValueIds();
                }
                return r.getDataTypeRequirement().getDataTypeValue();
            case 8:
            case 9:
              if (r.getIsCustomValue()) {
                return r.getListOfValueId();
              }

              return r.getDataTypeRequirement().getDataTypeValue();
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
        //If field is boolean, this is the only option
        if (dataTypeId == 3) {
          return "is";
        }

        // If field is a dataTypeRequirement
        if (r != null) {
          if (nullableIds.contains(r.getId())) {
            return "is";
          } else {
            return "=";
          }
        } else {
          return "=";
        }
      case 2:
        //If field is boolean, this is the only option
        if (dataTypeId == 3) {
          return "is not";
        }

        // If field is a dataTypeRequirement
        if (r != null) {
          if (nullableIds.contains(r.getId())) {
            return "is not";
          } else {
            return "!=";
          }
        } else {
          return "!=";
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

  public List<ListOfValue> getSmartlistSystemListById(Long smartlistSystemListId) {
    return sqlCache.query("smartlist.getSmartlistSystemList", Map.of("smartlistSystemListId", smartlistSystemListId, "companyId", securityService.getCurrentUser().getCompanyId()), ListOfValue.class);
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
