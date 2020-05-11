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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SmartlistService {

  private final SecurityService securityService;

  private final SqlCache sqlCache;

  private final ObjectMapper om;

  public List<Smartlist> getSmartlists() {
    return sqlCache.query("smartlist.get", null, Smartlist.class);
  }

  public Smartlist getSmartlist(Long id) {
    return sqlCache.get("smartlist.getById", Map.of("id", id), Smartlist.class).orElse(null);
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
    return sqlCache.query("smartlist.getAvailableFields", Map.of("companyId", securityService.getCurrentUser().getCompanyId(), "objectTypeId", objectTypeId), SmartlistFieldAssignment.class);
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
    Smartlist smartlist = sqlCache.get("smartlist.get", params, Smartlist.class).orElse(null);
    if (smartlist == null) {
      return null;
    }

    List<SmartlistFieldAssignment> fields = sqlCache.query("smartlist.getAssignedFields", params, SmartlistFieldAssignment.class);
    List<SmartlistRequirement> requirements = sqlCache.query("smartlist.getRequirements", params, new SmartlistRequirementMapper<>(SmartlistRequirement.class, om));

    ArrayList<String> dateFields = new ArrayList<>();
    ArrayList<Long> joinObjectTypeIds = new ArrayList<>();
    StringBuilder query = new StringBuilder("select");

    for (SmartlistFieldAssignment f : fields) {

      final String location = String.format("%s.%s", f.getReferenceTable(), f.getReferenceColumn());

      if (f.getDataTypeId() == 1) {
        query.append(String.format(" date(%s) as \"%s\",", location, f.getName()));
        dateFields.add(f.getName());
      } else {
        query.append(String.format(" %s as \"%s\",", location, f.getName()));
      }

      if (!f.getObjectTypeId().equals(smartlist.getObjectTypeId()) && !joinObjectTypeIds.contains(f.getObjectTypeId())) {
        joinObjectTypeIds.add(f.getObjectTypeId());
      }
    }

    // Remove comma from last select field
    query.deleteCharAt(query.length() - 1);

    switch (smartlist.getObjectTypeId().intValue()) {
      case 1:
        query.append(" from flow.project ");

        // join tables from object types which aren't the same as the report object type (used for `from` clause)
        for (Long objectTypeId : joinObjectTypeIds) {
          //@TODO humes, might make these joins more programatic by using foreign keys to join
          switch (objectTypeId.intValue()) {
            case 2:
              query.append("inner join flow.contact on flow.contact.id = flow.project.contact_id ");
              break;
            case 3:
              break;
            case 4:
              break;
            case 5:
              break;
          }
        }


        break;
      case 2:
        query.append(" from flow.user ");
    }

    query.append(" where");

    for (SmartlistRequirement r : requirements) {

      switch (r.getDataTypeId().intValue()) {
        case 1:
          String operator = getSqlOperator(r.getOperatorTypeId(), r.getDataTypeId());
          query.append(String.format(" %s.%s %s '%s'", r.getReferenceTable(), r.getReferenceColumn(), operator, getRequirementValue(r)));
          break;
        case 5:
          query.append(String.format(" %s.%s in(%s)", r.getReferenceTable(), r.getReferenceColumn(), r.getRequirementValue()));
          break;
      }
    }

    log.info(query.toString());

    List<Map<String, Object>> result = sqlCache.queryBySql(query.toString(), null, new ColumnMapRowMapper());

    CsvSchema.Builder builder = CsvSchema.builder();

    // Dates have to be set as string, else when written to buffer, they display as epoch milli
    for (int i = 0; i < result.size(); i++) {
      Map<String, Object> r = result.get(i);

      for (String field : dateFields) {
        r.put(field, r.get(field).toString());
      }
      result.set(i, r);
    }

    for (SmartlistFieldAssignment f : fields) {
      builder.addColumn(f.getName(), CsvSchema.ColumnType.NUMBER_OR_STRING);
    }

    CsvSchema schema = builder.build().withHeader();
    ObjectWriter w = new CsvMapper().writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    try (SequenceWriter toBuffer = w.writeValues(buffer)) {
      toBuffer.writeAll(result);
      toBuffer.flush();
      return buffer.toString(StandardCharsets.UTF_8);
    } catch (IOException e) {
      return null;
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
      default:
        return null;
    }
  }

  private String getSqlOperator(Long operatorTypeId, Long dataTypeId) {
    //@TODO will also need to take data type id into account
    switch (operatorTypeId.intValue()) {
      case 1:
        return "=";
      case 2:
        return "!=";
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
    }
  }
}
