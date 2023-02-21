package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.smartlist.SmartlistAccessControl;
import com.albatross.api.v1.flow.model.smartlistv1.SmartlistFieldAssignment;
import com.albatross.api.v1.flow.model.smartlist.Smartlist;
import com.albatross.api.v1.flow.queries.SmartlistQueryv1;
import com.albatross.api.v1.flow.queries.SmartlistQuery;
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
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import javax.validation.constraints.NotNull;
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

  private final UserService userService;

  private final OrgService orgService;

  private final UserPositionService userPositionService;

  private final SmartlistServicev1 smartlistServicev1;

  private boolean isSmartlistAdmin() {
    User user = securityService.getCurrentUser();
    return securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("ADMIN"));
  }

  private boolean isOwnerOrAdmin(@NotNull Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    final var sameCompany = Objects.equals(user.getCompanyId(), smartlist.getCompanyId());
    final var isOwnerOrAdmin = Objects.equals(smartlist.getOwnerId(), user.getId()) || isSmartlistAdmin();
    return sameCompany && isOwnerOrAdmin;
  }

  public void updatePublicStatus(Long smartlistId, boolean isPublic) {
    var smartlist = getById(smartlistId);

    if (isOwnerOrAdmin(smartlist)) {
      User user = securityService.getCurrentUser();
      Map<String, Object> params = Map.of("smartlistId", smartlistId, "public", isPublic, "userId", user.getId());
      sqlCache.updateBySql(SmartlistQuery.updatePublic, params);
    } else {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }
  }

  @Transactional
  public void updateOwner(Long smartlistId, SmartlistAccessControl newOwner) {

    var smartlist = getById(smartlistId, true);

    if (!isOwnerOrAdmin(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access", new AccessDeniedException("You do not have access"));
    }

    //verify smartlist is currently shared with new owner
    var currentAccess = smartlist.getAccessControl().stream()
                                                       .filter(i -> i.getUserPositionId().equals(newOwner.getUserPositionId()))
                                                       .findFirst()
                                                       .orElse(null);

    if (currentAccess == null) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "New owner does not have access to smartlist", new AccessDeniedException("New owner does not have access to smartlist"));
    }

    var user = securityService.getCurrentUser();

    //verify the user position getting ownership is in the same company as the smartlist
    var newOwnerPosition = userPositionService.getOne(newOwner.getUserPositionId());

    if (newOwnerPosition == null ||  !Objects.equals(smartlist.getCompanyId(), newOwnerPosition.getCompanyId())) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "New owner not found", new NotFoundException("New owner not found"));
    }

    sqlCache.updateBySql(SmartlistQuery.updateOwner, Map.of(
                                                       "smartlistId", smartlistId,
                                                       "newOwnerId", newOwnerPosition.getUserId(),
                                                       "userId", user.getId()
    ));

    //remove previous access of new owner
    sqlCache.updateBySql(SmartlistQuery.deleteAccess, Map.of("id", currentAccess.getId(), "userId", user.getId()));

    //give old owner edit access
    var oldOwnerPosition = userPositionService.getUserPrimaryPosition(smartlist.getOwnerId(), smartlist.getCompanyId());
    if (oldOwnerPosition == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Original owner not found", new NotFoundException("Original owner not found"));
    }

    try {
      Map<String, Object> params = new HashMap<>();
      params.put("smartlistId", smartlistId);
      params.put("orgId", null);
      params.put("userPositionId", oldOwnerPosition.getId());
      params.put("accessControlId", 2);
      params.put("userId", user.getId());
      sqlCache.updateBySqlReturningId(SmartlistQuery.addAccess, params, "id")
              .longValue();
    } catch (Exception e) {
      e.printStackTrace();
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected error occurred", new RuntimeException("Unexpected error occurred"));
    }
  }

  public Smartlist getById(Long id) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("smartlistId", id, "companyId", user.getCompanyId(), "userId", user.getId());
    Smartlist smartlist = sqlCache.getBySql(SmartlistQuery.getById, params, new SmartlistService.SmartlistMapper<>(Smartlist.class, om))
                                  .orElse(null);

    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Smartlist not found", new NotFoundException("Smartlist not found"));
    }

    //grant access to smartlist if user is owner, admin, or smartlist is public
    if (!isOwnerOrAdmin(smartlist) && !smartlist.isPublic()) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    return smartlist;
  }

  public Smartlist getById(Long id, boolean includeAccessControl) {
    var smartlist = getById(id);

    if (includeAccessControl) {
      smartlist.setAccessControl(getAccessById(id));
    }

    return smartlist;
  }

  public List<SmartlistAccessControl> getAvailableAccess() {
    return sqlCache.queryBySql(SmartlistQuery.getAvailableAccess, null, SmartlistAccessControl.class);
  }

  public List<SmartlistAccessControl> getAccessById(Long smartlistId) {
    Smartlist smartlist = getById(smartlistId);

    if (!isOwnerOrAdmin(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access", new AccessDeniedException("You do not have access"));
    }

    User user = securityService.getCurrentUser();

    return sqlCache.queryBySql(
      SmartlistQuery.getAccessById,
      Map.of("smartlistId", smartlistId, "userId", user.getId()),
      SmartlistAccessControl.class
    );
  }

  public SmartlistAccessControl addAccess(Long smartlistId, SmartlistAccessControl access) {
    User user = securityService.getCurrentUser();
    Smartlist smartlist = getById(smartlistId);

    if (!isOwnerOrAdmin(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    try {
      HashMap<String, Object> params = om.convertValue(access, HashMap.class);
      params.put("userId", user.getId());
      Long newId = sqlCache.updateBySqlReturningId(SmartlistQuery.addAccess, params, "id").longValue();
      var newAccess = new SmartlistAccessControl();
      newAccess.setId(newId);
      return newAccess;
    } catch (Exception e) {
      e.printStackTrace();
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected error occurred", new RuntimeException("Unexpected error occurred"));
    }
  }

  public void updateAccess(Long smartlistId, List<SmartlistAccessControl> access) {
    User user = securityService.getCurrentUser();
    Smartlist smartlist = getById(smartlistId);

    if (!isOwnerOrAdmin(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    var params = access.stream().map(i -> Map.of(
                                            "smartlistId", smartlistId,
                                            "id", i.getId(),
                                            "accessControlId", i.getAccessControlId(),
                                            "userId", user.getId()
                                          )).toList();

    sqlCache.updateBatchBySql(SmartlistQuery.updateAccess, params);
  }

  public void delete(Long smartlistId) {
    User user = securityService.getCurrentUser();
    Smartlist smartlist = getById(smartlistId);

    // allow delete only if user is smartlist owner or admin
    if (!isOwnerOrAdmin(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have access", new AccessDeniedException("You do not have access"));
    }

    sqlCache.updateBySql(SmartlistQueryv1.delete, Map.of("id", smartlistId, "userId", user.getId()));
  }

  public List<Smartlist> getMine() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId(), "userId", user.getId());
    return sqlCache.queryBySql(SmartlistQuery.getMine, params, Smartlist.class);
  }

  public List<Smartlist> getPublic() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId(), "userId", user.getId());
    return sqlCache.queryBySql(SmartlistQuery.getPublic, params, Smartlist.class);
  }

  public List<Smartlist> getAll() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId());
    return sqlCache.queryBySql(SmartlistQuery.getAll, params, Smartlist.class);
  }

  public List<SmartlistAccessControl> getSharableEntities() {
    List<User> users = userService.getAllActiveUsers();
    List<Org> orgs = orgService.getAllActive();

    //combine lists
    List<SmartlistAccessControl> combinedList = new ArrayList<>();
    users.forEach(u -> {
      var share = new SmartlistAccessControl();
      share.setUserPositionId(u.getUserPositionId());
      share.setIsUser(true);
      share.setIsOrg(false);
      share.setName(u.getFullName());
      share.setPosition(u.getPosition());
      combinedList.add(share);
    });

    orgs.forEach(o -> {
      var share = new SmartlistAccessControl();
      share.setOrgId(o.getId());
      share.setIsOrg(true);
      share.setIsOrg(false);
      share.setName(o.getOrgName());
      combinedList.add(share);
    });

    combinedList.sort((s1, s2) -> s1.getName().compareToIgnoreCase(s2.getName()));

    return combinedList;
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

    long copyNumber = 0L;
    String newName;
    boolean unique;

    do {
      newName = String.format("%s (%s)", smartlist.getName(), ++copyNumber);
      unique = sqlCache.queryForObjectBySql(SmartlistQuery.isNameUnique, Map.of("name", newName, "companyId", user.getCompanyId()), Boolean.class);
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
    Long newSmartlistId = sqlCache.updateBySqlReturningId(SmartlistQuery.create, params, "id").longValue();

    sqlCache.updateBySql(SmartlistQuery.copyAssignedFields, Map.of("newId", newSmartlistId, "userId", user.trueUserId(), "oldId", smartlistId));
    sqlCache.updateBySql(SmartlistQuery.copyRequirements, Map.of("newId", newSmartlistId, "userId", user.trueUserId(), "oldId", smartlistId));

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

      TypeReference<List<SmartlistAccessControl>> accessControlRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "accessControl", new JsonCollectionDeserializer(accessControlRef, om));
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
