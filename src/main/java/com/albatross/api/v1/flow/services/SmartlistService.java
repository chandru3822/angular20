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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SmartlistService {

  private final SecurityService securityService;

  private final SqlCache sqlCache;

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
    params.put("createdById", user.getId());
    Long smartlistId = sqlCache.updateReturningId("smartlist.add", params, "id").longValue();
    return getSmartlist(smartlistId);
  }

  public void updateSmartlist(Smartlist smartlist) {

    Smartlist existingSmartlist = this.getSmartlist(smartlist.getId());

    if (existingSmartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to find given smartlist", new RuntimeException());
    }

    final boolean updatingName = !existingSmartlist.getName().trim().toLowerCase().equals(smartlist.getName().trim().toLowerCase());

    if (updatingName && !this.isNameUnique(smartlist.getName())) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Smartlist name already taken", new Exception());
    }

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = om.convertValue(smartlist, HashMap.class);
    params.put("userId", user.getId());
    sqlCache.update("smartlist.update", params);
  }

  public void deleteSmartlist(Long smartlistId) {
    sqlCache.update("smartlist.delete", Map.of("id", smartlistId, "userId", securityService.getCurrentUser().getId()));
  }

  @Transactional
  public void toggleType(Long smartlistId) {
    Smartlist smartlist = this.getSmartlist(smartlistId);

    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to find given smartlist", new RuntimeException());
    }

    smartlist.setProjectDetails(!smartlist.isProjectDetails());
    this.updateSmartlist(smartlist);

    sqlCache.update("smartlist.clearFieldsAndRequirements", Map.of("smartlistId", smartlistId, "userId", securityService.getCurrentUser().getId()));
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
    params.put("projectDetailsColumn", assignment.getProjectDetailsColumn());
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

  public List<SmartlistRequirement> getRequirements(Long smartlistId, boolean includeListValues) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Map<String, Object> params = Map.of("smartlistId", smartlistId, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany);
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

  public SmartlistResult getSmartlistResults(Long smartlistId) {
    Smartlist smartlist = this.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

      final String query = (smartlist.isProjectDetails()) ? this.buildProjectDetailsSql(smartlist) : buildSql(smartlist);
      List<SmartlistFieldAssignment> fields = this.getAssignedFields(smartlistId);
      log.info("SMARTLIST: Running smartlist ID: " + smartlistId);
      List<Map<String, Object>> results = sqlCache.queryBySql(query, null, new ColumnMapRowMapper());

      return new SmartlistResult(fields, results);
  }

  public String getCsv(Long smartlistId) {
    Smartlist smartlist = this.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

    final List<SmartlistFieldAssignment> fields = (smartlist.isProjectDetails()) ? this.getAssignedProjectDetailsFields(smartlistId) : this.getAssignedFields(smartlistId);

      if (fields.isEmpty()) {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist must have at least 1 field", new Exception());
      }

      if (!smartlist.isProjectDetails()) {
        fields.forEach(f -> f.setName((f.getObjectTypeId() == 4) ? String.format("%s (%s)", f.getName(), f.getProcessStepId()) : f.getName()));
      }

      final String query = (smartlist.isProjectDetails()) ? this.buildProjectDetailsSql(smartlist) : buildSql(smartlist);
      log.info("SMARTLIST: Running smartlist ID: " + smartlistId);
      final List<Map<String, Object>> results = sqlCache.queryBySql(query, null, new ColumnMapRowMapper());

      return writeCsv(results, fields);
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

  public String buildSql(Smartlist smartlist) {

    //@TODO humes: there is a lot of duplication in this function which could/should be abstracted out

    final Long companyId = securityService.getCurrentUser().getCompanyId();

    List<SmartlistFieldAssignment> fields = this.getAssignedFields(smartlist.getId());
    List<SmartlistRequirement> requirements = this.getRequirements(smartlist.getId(), false);

    List<SmartlistFieldAssignment> joinTables = new ArrayList<>();

    List<Long> usedProcessStepIds = new ArrayList<>();

    StringBuilder withClause = new StringBuilder();
    StringBuilder additionalJoins = new StringBuilder();
    StringBuilder whereClause = new StringBuilder();

    // Get smartlist system lists
    withClause.append(" \"smartlistSystemList_1\" as (select * from flow.get_smartlist_system_list_options(1::int, 3::int)), ");
    withClause.append(" \"smartlistSystemList_2\" as (select * from flow.get_smartlist_system_list_options(2::int, 3::int)), ");
    withClause.append(" \"smartlistSystemList_3\" as (select * from flow.get_smartlist_system_list_options(3::int, 3::int)), ");

    // Get tables for system lists
    withClause.append(" \"systemList_1\" as (select up.id, concat(u.first_name, ' ', u.last_name::text) as name from flow.user_position up inner join flow.user u on u.id = up.user_id), ");
    withClause.append(" \"systemList_3\" as (select id, org_name::text as name from flow.org), ");
    withClause.append(" \"systemList_4\" as (select id, concat(first_name, ' ', last_name::text) as name from flow.user), ");

    StringBuilder query = new StringBuilder(" select");

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
            } else {
              f.setReferenceTable(UUID.randomUUID().toString());
            }
            f.setPpsTable(UUID.randomUUID().toString());
            joinTables.add(f);
          } else {
            final String uuid = joinTables.stream()
              .filter(t -> t.getProcessStepId() != null && t.getProcessStepId().equals(f.getProcessStepId()))
              .map(t -> {
                if (Objects.equals(t.getReferenceTable(), "flow.user") || Objects.equals(t.getReferenceTable(), "flow.process_step")) {
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
          joinTables.add(f);
        }
      } else {
        f.setValueReferenceTable(UUID.randomUUID().toString());
        joinTables.add(f);
      }

      String location = "";

      final String referenceTable = joinTables.stream()
        .filter(t -> t.getCustomFieldGroupAssignmentId() != null && t.getCustomFieldGroupAssignmentId().equals(f.getCustomFieldGroupAssignmentId()))
        .map(t -> {
          if (t.getAllowMultiple()) {
            return t.getValueReferenceTable();
          } else {
            return t.getReferenceTable();
          }
        })
        .findFirst()
        .orElse(null);

      if (f.getSmartlistSystemListId() != null) {
        final String tempAlias = UUID.randomUUID().toString();

        final String smartlistSystemListTable = "smartlistSystemList_" + f.getSmartlistSystemListId();

        if (f.getSmartlistSystemListId() == 1 || f.getSmartlistSystemListId() == 3) {
          location = String.format("(select name from \"%s\" where \"%s\".id = %s.%s)", smartlistSystemListTable, smartlistSystemListTable, f.getJoinTable(), f.getJoinColumn());
        } else if (f.getSmartlistSystemListId() == 2) {

          if (smartlist.getObjectTypeId() == 4) {
            location = String.format("(select name from \"%s\" where \"%s\".id = flow.project_process_step.%s)", smartlistSystemListTable, smartlistSystemListTable, f.getJoinColumn());
          } else {
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

            location = String.format("(select name from \"%s\" where \"%s\".id = \"%s\".%s)", smartlistSystemListTable, smartlistSystemListTable, ppsTable, f.getJoinColumn());
          }
        }
      }
      // If field is custom, else it's system
      else if (f.getCustomFieldGroupAssignmentId() != null && referenceTable != null) {
        final String column = ((f.getHasListValues() != null && f.getHasListValues() && !f.getAllowMultiple()) || f.getCustomFieldSqlKey() != null) ? "name" : getReferenceColumn(f.getDataTypeId());
        location = String.format("\"%s\".%s", referenceTable, column);
      } else if (Objects.equals(f.getReferenceTable(), "flow.user")) {
        location = (f.getObjectTypeId() != 4) ? f.getReferenceColumn() : String.format("concat(\"%s\".first_name, ' ', \"%s\".last_name)", f.getValueReferenceTable(), f.getValueReferenceTable());
      } else {
        if (smartlist.getObjectTypeId() == 4) {
          location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
        } else {
          if (f.getCustomFieldGroupAssignmentId() != null || f.getProcessStepId() != null || (f.getJoinTable() != null && f.getJoinColumn() != null)) {
            final String table = (f.getJoinTable() != null && f.getJoinColumn() != null) ? f.getValueReferenceTable() : f.getReferenceTable();
            location = String.format("\"%s\".%s", table, f.getReferenceColumn());
          } else {
            location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());
          }
        }
      }

      final String fieldAlias = (f.getObjectTypeId() == 4) ? String.format("%s (%s)", f.getName(), f.getProcessStepId()) : f.getName();

      if (f.getReferenceTable().equals("flow.process_step")) {
        query.append(String.format("  (select %s from %s where %s.id = \"%s\".process_step_id) as \"%s\", ", f.getReferenceColumn(), f.getReferenceTable(), f.getReferenceTable(), f.getValueReferenceTable(), fieldAlias));
      } else if (f.getDataTypeId() == 1) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD') as \"%s\", ", location, fieldAlias));
      } else if(f.getDataTypeId() == 2) {
        query.append(String.format("  to_char(%s, 'YYYY-MM-DD HH:MI am') as \"%s\", ", location, fieldAlias));
      } else if (f.getDataTypeId() == 7) {
          query.append(String.format("  (select array_to_string(array(select \"name\" from flow.list_of_value where id = any(%s)), ',')) as \"%s\", ", location, fieldAlias));
      } else if (f.getDataTypeId() == 9) {
          final long systemListNumber = (f.getSystemListId() == 1 || f.getSystemListId() == 2) ? 1 : f.getSystemListId();

          final String sql = String.format("  (select name from \"%s\" where \"%s\".id = \"%s\".int_value) as \"%s\", ", "systemList_" + systemListNumber, "systemList_" + systemListNumber, f.getValueReferenceTable(), fieldAlias);
          query.append(sql);
      } else {
        query.append(String.format("  %s as \"%s\", ", location, fieldAlias));
      }

      if (f.getCustomFieldSqlKey() != null && withClause.indexOf(f.getCustomFieldSqlKey()) == -1) {
          withClause.append(String.format("  \"%s\" as  (%s), ", f.getCustomFieldSqlKey(), sqlCache.getByKey(f.getCustomFieldSqlKey())));
      }
    }

    for (SmartlistRequirement r: requirements) {

        if (r.getProcessStepId() != null) {
          usedProcessStepIds.add(r.getProcessStepId());
        }

        // If this custom sql is not already in the "with" clause, add it
        if (r.getCustomFieldSqlKey() != null && withClause.indexOf(r.getCustomFieldSqlKey()) == -1) {
            withClause.append(String.format("  \"%s\" as  (%s), ", r.getCustomFieldSqlKey(), sqlCache.getByKey(r.getCustomFieldSqlKey())));
        }
    }

    // Remove comma from last select field
    query.deleteCharAt(query.length() - 1);

    query.append(" flow.project.id as project_id,");
    query.append(" flow.project.contact_id as contact_id");

    final String companySubquery = String.format("select id from flow.company where id = %s or parent_company_id = %s", companyId, companyId);

    switch (smartlist.getObjectTypeId().intValue()) {
      case 1:
        query.append(" from flow.project ");
        query.append(" inner join flow.company_process on flow.company_process.id = flow.project.company_process_id and " + String.format("flow.company_process.company_id = any(%s)", companySubquery));
        query.append(" left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
        query.append(" left join flow.user_position on flow.user_position.id = flow.contact.owner_user_position_id ");
        query.append(" left join flow.user on flow.user.id = flow.user_position.user_id ");

        whereClause.append(String.format(" flow.company_process.company_id = any(%s) and ", companySubquery));
        break;
      case 2:
        query.append("  from flow.contact ");
        query.append(" left join flow.project on flow.project.contact_id = flow.contact.id ");
        query.append(" left join flow.user_position on flow.user_position.id = flow.contact.owner_user_position_id ");
        query.append(" left join flow.user on flow.user.id = flow.user_position.user_id ");

        whereClause.append(String.format(" flow.contact.company_id = any(%s) and ", companySubquery));
        break;
      case 4:
        query.append("  from flow.project_process_step ");
        query.append(" inner join flow.process_step on flow.process_step.id = flow.project_process_step.process_step_id ");

        if (!usedProcessStepIds.isEmpty()) {
          query.append(String.format("and flow.project_process_step.process_step_id = any('{%s}')", usedProcessStepIds.stream().map(String::valueOf).collect(Collectors.joining(","))));
        }

        query.append(" left join flow.project on flow.project.id = flow.project_process_step.project_id  ");
        query.append(" left join flow.contact on flow.contact.id = flow.project.contact_id and flow.contact.archived is not true ");
        query.append(" left join flow.user_position on flow.user_position.id = flow.contact.owner_user_position_id ");
        query.append(" left join flow.user on flow.user.id = flow.user_position.user_id ");

        whereClause.append(String.format(" flow.process_step.company_id = any(%s) and ", companySubquery));
        break;
    }

    for (SmartlistFieldAssignment f : joinTables) {
      final String joinAlias = (f.getSystemListTypeId() != null || (f.getJoinTable() != null && f.getJoinColumn() != null) || Objects.equals(f.getAllowMultiple(), true)) ? f.getValueReferenceTable() : f.getReferenceTable();

      if (f.getSmartlistSystemListId() == null) {
        if (f.getObjectTypeId() == 1 || f.getObjectTypeId() == 2) {

          final String joinField = (f.getObjectTypeId() == 1) ? "project_id" : "contact_id";
          final String joinedField = (f.getObjectTypeId() == 1) ? "id" : "contact_id";

          if ((f.getHasListValues() != null && f.getHasListValues()) || f.getCustomFieldSqlKey() != null) {

            if (f.getValueReferenceTable() == null) {
              f.setValueReferenceTable(UUID.randomUUID().toString());
            }
            final String valueTable = f.getValueReferenceTable();

            query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.project.%s and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), valueTable, valueTable, joinField, joinedField, valueTable, f.getCustomFieldGroupAssignmentId()));

            if (f.getCustomFieldSqlKey() != null) {
              //custom value sql
              query.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", f.getCustomFieldSqlKey(), joinAlias, joinAlias, valueTable));
            } else if (!f.getAllowMultiple()) {
              query.append(String.format(" left join flow.list_of_value \"%s\" on \"%s\".id = \"%s\".int_value ", joinAlias, joinAlias, valueTable));
            }
          } else {
            if (f.getJoinTable() != null && f.getJoinColumn() != null) {
              query.append(String.format(" left join %s \"%s\" on \"%s\".id = %s.%s", f.getReferenceTable(), joinAlias, joinAlias, f.getJoinTable(), f.getJoinColumn()));
            } else {
              query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.project.%s and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(f.getObjectTypeId()), joinAlias, joinAlias, joinField, joinedField, joinAlias, f.getCustomFieldGroupAssignmentId()));
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
              query.append(String.format(" left join flow.project_process_step \"%s\" on \"%s\".project_id = flow.project.id and \"%s\".process_step_id = %s ", joinAlias, joinAlias, joinAlias, f.getProcessStepId()));
              if (smartlist.isMainProcessSteps()) {
                query.append(String.format("and \"%s\".main is true ", joinAlias));
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

            if (r.getSmartlistSystemListId() == 1 || r.getSmartlistSystemListId() == 3) {
              if (additionalJoins.indexOf(String.format("left join (select * from flow.get_smartlist_system_list_options(%s::int, %s", r.getSmartlistSystemListId(), r.getCompanyId())) == -1) {
                referenceTable = UUID.randomUUID().toString();
                final String subquery = String.format("select * from flow.get_smartlist_system_list_options(%s::int, %s::int)", r.getSmartlistSystemListId(), r.getCompanyId());
                additionalJoins.append(String.format(" left join (%s) \"%s\" on \"%s\".id = %s.%s ", subquery, referenceTable, referenceTable, r.getJoinTable(), r.getJoinColumn()));
              }
            } else if (r.getSmartlistSystemListId() == 2) {
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
              final String subquery = String.format("select * from flow.get_smartlist_system_list_options(%s::int, %s::int)", 2, r.getCompanyId());
              additionalJoins.append(String.format(" left join (%s) \"%s\" on \"%s\".id = \"%s\".%s ", subquery, referenceTable, referenceTable, joinTable, r.getJoinColumn()));
            }
            referenceLocation = String.format("\"%s\".id", referenceTable);
          } else if (r.getCustomFieldGroupAssignmentId() != null) {

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
                          }
                          additionalJoins.append(String.format(" left join \"%s\" \"%s\" on \"%s\".id = \"%s\".int_value ", r.getCustomFieldSqlKey(), customSqlUuid, customSqlUuid, valueUuid));

                          referenceLocation = "\"" + customSqlUuid + "\".id";
                      } else {
                        final String joinField = (r.getObjectTypeId() == 1) ? "project_id" : "contact_id";
                        final String joinedField = (r.getObjectTypeId() == 1) ? "id" : "contact_id";

                        query.append(String.format(" left join %s \"%s\" on \"%s\".%s = flow.project.%s and \"%s\".custom_field_group_assignment_id = %s ", getReferenceTable(r.getObjectTypeId()), valueUuid, valueUuid, joinField, joinedField, valueUuid, r.getCustomFieldGroupAssignmentId()));
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
                if (r.getObjectTypeId() == 1 || r.getObjectTypeId() == 2) {
                  referenceLocation = r.getReferenceTable() + "." + r.getReferenceColumn();
                } else if (r.getObjectTypeId() == 4) {
                  String joinTable = null;
                  try {
                    joinTable = joinTables.stream()
                      .filter(t -> t.getProcessStepId() != null && r.getProcessStepId() != null && t.getProcessStepId().equals(r.getProcessStepId()))
                      .map(SmartlistFieldAssignment::getReferenceTable)
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
          } else if (r.getDataTypeId() == 3 || r.getDataTypeId() == 4 || (r.getDataTypeRequirementId() != null && r.getSecondaryRequirementValue() == null && r.getDataTypeId() != 2)) {
            whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
          } else {
            if (requirementValue instanceof String && requirementValue.toString().contains("null")) {
              whereClause.append(String.format(" %s %s %s and ", referenceLocation, operator, requirementValue));
            } else {
              whereClause.append(String.format(" %s %s '%s' and ", referenceLocation, operator, requirementValue));
            }
          }
      }

      if (smartlist.isMainProcessSteps() && smartlist.getObjectTypeId() == 4) {
        whereClause.append(" flow.project_process_step.main is true and ");
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

    query.append(";");

    return query.toString();
  }

  private String writeCsv(List<Map<String, Object>> data, List<SmartlistFieldAssignment> headers) {
    CsvSchema.Builder builder = CsvSchema.builder();

    // Dates have to be set as string, else when written to buffer, they display as epoch milli
    for (int i = 0; i < data.size(); i++) {
      Map<String, Object> r = data.get(i);

//      for (String field : dateFields) {
//        r.put(field, (r.get(field) == null) ? "N/A" : r.get(field).toString());
//      }
      r.remove("project_id");
      r.remove("contact_id");
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
                  return r.getListOfValueId();
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
