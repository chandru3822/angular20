package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.smartlist.SmartlistFieldAssignment;
import com.albatross.api.v1.flow.model.smartlistv2.Smartlist;
import com.albatross.api.v1.flow.queries.SmartlistQueryv1;
import com.albatross.api.v1.flow.queries.SmartlistQueryv2;
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
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@Service
@PreAuthorize("hasFeatureAccess('SMARTLIST') || hasFeatureAccess('WORK_QUEUE')")
@RequiredArgsConstructor
@Slf4j
public class SmartlistService {

  private final SqlCache sqlCache;

  private final SqlCacheRO sqlCacheRO;

  private final SecurityService securityService;

  private final ObjectMapper om;

  private final SmartlistServicev1 smartlistServicev1;

  public Smartlist getById(Long id) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("smartlistId", id, "companyId", user.getCompanyId(), "userId", user.getId());
    Smartlist smartlist = sqlCache.getBySql(SmartlistQueryv2.getById, params, new SmartlistService.SmartlistMapper<>(Smartlist.class, om))
                                  .orElse(null);

    if (smartlist != null) {
      // grant access to smartlist if user is owner, admin, or smartlist is public
      final boolean isSmartlistAdmin = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("ADMIN"));
      if (Objects.equals(smartlist.getOwnerId(), user.getId()) || smartlist.isPublic() || isSmartlistAdmin) {
        return smartlist;
      } else {
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access", new AccessDeniedException("You do not have access"));
      }
    }

    return null;
  }

  public void delete(Long smartlistId) {
    User user = securityService.getCurrentUser();
    Smartlist smartlist = getById(smartlistId);
    final boolean isSmartlistAdmin = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("ADMIN"));

    // allow delete only if user is smartlist owner or admin
    if (smartlist == null || (!smartlist.getOwnerId().equals(user.getId()) && !isSmartlistAdmin)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access", new AccessDeniedException("You do not have access"));
    }

    sqlCache.updateBySql(SmartlistQueryv1.delete, Map.of("id", smartlistId, "userId", securityService.getCurrentUser().getId()));
  }

  public List<Smartlist> getMine() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId(), "userId", user.getId());
    return sqlCache.queryBySql(SmartlistQueryv2.getMine, params, Smartlist.class);
  }

  public List<Smartlist> getPublic() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId(), "userId", user.getId());
    return sqlCache.queryBySql(SmartlistQueryv2.getPublic, params, Smartlist.class);
  }

  public List<Smartlist> getAll() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId());
    return sqlCache.queryBySql(SmartlistQueryv2.getAll, params, Smartlist.class);
  }

  private void saveError(Smartlist smartlist, String query, List<SmartlistFieldAssignment> fields, Exception e) {
    Map<String, Object> params = new HashMap<>();
    params.put("smartlistId", smartlist.getId());
    params.put("createdById", securityService.getCurrentUser().getId());
    params.put("query", query);

    StringWriter sw = new StringWriter();
    PrintWriter pw = new PrintWriter(sw);
    e.printStackTrace(pw);
    params.put("stacktrace", sw.toString());

    try {
      params.put("smartlist", om.writeValueAsString(smartlist));
      params.put("fields", om.writeValueAsString(fields));
      params.put("requirements", om.writeValueAsString(smartlistServicev1.getRequirements(smartlist.getId(), false)));
    } catch (Exception err) {
      //noop
    }

    sqlCache.update("smartlist.addError", params);

    log.error(String.format("SMARTLIST: Error while running smartlist ID: %s, message: %s", smartlist.getId(), e.getMessage()));
  }

  public String export(Long smartlistId, String timezone) throws JsonProcessingException {
    Smartlist smartlist = this.getById(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

    List<SmartlistFieldAssignment> fields = (smartlist.isProjectDetails()) ? smartlistServicev1.getAssignedProjectDetailsFields(smartlistId) : smartlistServicev1.getAssignedFields(smartlistId);

    if (null == smartlist.getWorkQueueTypeId() && fields.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist must have at least 1 field", new Exception());
    }

    if (!smartlist.isProjectDetails()) {
      fields = smartlistServicev1.prettifyFieldNames(fields);
    }

    log.debug("SMARTLIST: Running smartlist ID: {}", smartlistId);
    String query;

    //dont run the processStepSql if it is for a work queue list. i only put the work queue code into the buildSql funtion
    if (smartlist.isProjectDetails()) {
      query = smartlistServicev1.buildProjectDetailsSql(smartlist.toOriginal());
    } else if (List.of(4L, 6L).contains(smartlist.getObjectTypeId()) && null == smartlist.getWorkQueueTypeId()) {
      if (smartlist.getObjectTypeId() == 4) {
        query = smartlistServicev1.buildProcessStepSql(smartlist.toOriginal(), fields);
      } else {
        query = smartlistServicev1.buildEventSql(smartlist.toOriginal(), fields, null, null);
      }
    } else {
      if (smartlist.getWorkQueueTypeId() != null && smartlist.getObjectTypeId() == 6) {
        query = smartlistServicev1.buildWorkQueueSql(smartlist.toOriginal(), fields, true, timezone);
      } else {
        query = smartlistServicev1.buildSql(smartlist.toOriginal(), fields, timezone, null, false);
      }
    }

    List<Map<String, Object>> results;

    try {
      results = sqlCacheRO.queryBySql(query, null, new ColumnMapRowMapper());
    } catch (Exception e) {
      saveError(smartlist, query, fields, e);
      throw e;
    }

    if (results.isEmpty()) {
      return writeEmptyCsv(fields);
    } else {
      return writeCsv(results, fields, null != smartlist.getWorkQueueTypeId(), smartlist.getWorkQueueTypeId() != null && smartlist.getObjectTypeId() == 6L);
    }
  }

  private String writeCsv(List<Map<String, Object>> data, List<SmartlistFieldAssignment> headers, Boolean workQueueSmartlist, Boolean useEventData) throws JsonProcessingException {
    CsvSchema.Builder builder = CsvSchema.builder();

    if (workQueueSmartlist) {
      if (useEventData) {
        //add default fields to fields list
        var defaultFields = getEventWorkqueueDefaultFields(true);
        defaultFields.addAll(headers);
        headers = defaultFields;
      } else {
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
        for (String header : wqHeaders) {
          SmartlistFieldAssignment sfa = new SmartlistFieldAssignment();
          sfa.setName(header);
          headers.add(0, sfa);
        }

        //add most recent note header to the end after all the custom fields

        SmartlistFieldAssignment sfa3 = new SmartlistFieldAssignment();
        sfa3.setName("Next Follow-up Date");
        headers.add(sfa3);

        SmartlistFieldAssignment sfa4 = new SmartlistFieldAssignment();
        sfa4.setName("Note Content");
        headers.add(sfa4);

        SmartlistFieldAssignment sfa5 = new SmartlistFieldAssignment();
        sfa5.setName("Note Created By");
        headers.add(sfa5);

        SmartlistFieldAssignment sfa6 = new SmartlistFieldAssignment();
        sfa6.setName("Note Created At");
        headers.add(sfa6);
      }
    }

    // Dates have to be set as string, else when written to buffer, they display as epoch milli
    for (int i = 0; i < data.size(); i++) {
      Map<String, Object> r = data.get(i);

      r.remove("project_id");
      r.remove("contact_id");
      if (workQueueSmartlist) {
        if (useEventData) {
          r.remove("projectProcessStepEventId");
          r.remove("projectProcessStepId");
          r.remove("projectId");
          r.remove("tags");
          r.remove("processStepEventWorkQueueTypeId");
        } else {
          r.remove("processStepId");
          r.remove("projectProcessStepId");
          r.remove("workQueueType");
          r.remove("workQueueTypeId");
          r.remove("processStepWorkQueueTypeId");
          r.remove("projectId");
          r.remove("tags");
          r.remove("projectStatusTypeId");
          r.remove("companyProjectStatusTypeId");
          r.remove("contactId");
          r.remove("lastUpdated");
          r.remove("Owning Positions");
        }

        //handle notes
        PGobject notesArray = ((PGobject) r.get("Notes"));
        TypeReference<List<Note>> notesRef = new TypeReference<>() {
        };
        List<Note> notes = om.readValue(notesArray.getValue(), notesRef);
        if (notes.size() > 0) {
          String pattern = "yyyy-MM-dd hh:mma";
          DateFormat df = new SimpleDateFormat(pattern);
          Note firstNote = notes.get(0);
          r.put("Next Follow-up Date", firstNote.getFollowUpDate());
          r.put("Note Content", firstNote.getNote());
          r.put("Note Created By", firstNote.getCreatedBy());
          r.put("Note Created At", df.format(firstNote.getDateCreated()));
        } else {
          r.put("Next Follow-up Date", null);
          r.put("Note Content", null);
          r.put("Note Created By", null);
          r.put("Note Created At", null);
        }
        r.remove("Notes");
      }

      data.set(i, r);
    }

    for (SmartlistFieldAssignment f : headers) {
      if (f.getName().length() > 63) {
        f.setName(f.getName().substring(0, 63));
      }
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

  public List<SmartlistFieldAssignment> getEventWorkqueueDefaultFields(boolean isCSV) {
    var defaultFields = new ArrayList<SmartlistFieldAssignment>();
    var projectName = new SmartlistFieldAssignment();
    projectName.setName("Project Name");
    defaultFields.add(projectName);
    var event = new SmartlistFieldAssignment();
    event.setName("Event Name");
    defaultFields.add(event);
    var eventStatus = new SmartlistFieldAssignment();
    eventStatus.setName("Event Status");
    defaultFields.add(eventStatus);
    var psName = new SmartlistFieldAssignment();
    psName.setName("Process Step Name");
    defaultFields.add(psName);
    var psStatus = new SmartlistFieldAssignment();
    psStatus.setName("Process Step Status");
    defaultFields.add(psStatus);
    var daysInQueue = new SmartlistFieldAssignment();
    daysInQueue.setName("Days In Queue");
    defaultFields.add(daysInQueue);
    var eventStartTime = new SmartlistFieldAssignment();
    eventStartTime.setName("Event Start Time");
    defaultFields.add(eventStartTime);
    if (isCSV) {
      var nextFollowUp = new SmartlistFieldAssignment();
      nextFollowUp.setName("Next Follow-up Date");
      defaultFields.add(nextFollowUp);
      var noteContent = new SmartlistFieldAssignment();
      noteContent.setName("Note Content");
      defaultFields.add(noteContent);
      var noteCreatedBy = new SmartlistFieldAssignment();
      noteCreatedBy.setName("Note Created By");
      defaultFields.add(noteCreatedBy);
      var noteCreatedAt = new SmartlistFieldAssignment();
      noteCreatedAt.setName("Note Created At");
      defaultFields.add(noteCreatedAt);
    }
    return defaultFields;
  }

  @Transactional
  public Smartlist copy(Long smartlistId) {

    User user = securityService.getCurrentUser();
    Smartlist smartlist = getById(smartlistId);

    if (smartlist.getId() == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No smartlist with given ID", new RuntimeException());
    }

    long copyNumber = 0L;
    String newName;
    boolean unique;

    do {
      newName = String.format("%s (%s)", smartlist.getName(), ++copyNumber);
      unique = sqlCache.queryForObjectBySql(SmartlistQueryv2.isNameUnique, Map.of("name", newName, "companyId", user.getCompanyId()), Boolean.class);
    } while (!unique);

    Smartlist newSmartlist = new Smartlist();
    newSmartlist.setName(newName);
    newSmartlist.setCompanyObjectTypeId(smartlist.getCompanyObjectTypeId());
    newSmartlist.setPublic(smartlist.isPublic());
    newSmartlist.setMainProcessSteps(smartlist.isMainProcessSteps());
    newSmartlist.setProjectDetails(smartlist.isProjectDetails());

    HashMap<String, Object> params = om.convertValue(newSmartlist, HashMap.class);
    params.put("ownerId", user.getId());
    params.put("createdById", user.getId());
    Long newSmartlistId = sqlCache.updateBySqlReturningId(SmartlistQueryv2.create, params, "id").longValue();

    sqlCache.updateBySql(SmartlistQueryv2.copyAssignedFields, Map.of("newId", newSmartlistId, "userId", user.trueUserId(), "oldId", smartlistId));
    sqlCache.updateBySql(SmartlistQueryv2.copyRequirements, Map.of("newId", newSmartlistId, "userId", user.trueUserId(), "oldId", smartlistId));

    return getById(newSmartlistId);
  }

  public static class SmartlistMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper om;

    public SmartlistMapper(Class<T> mappedClass, ObjectMapper objectMaper) {
      super(mappedClass);
      this.om = objectMaper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ProcessStepEventWorkQueueType>> processStepEventWqtRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "eventWorkQueueTypes", new JsonCollectionDeserializer(processStepEventWqtRef, om));
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
