package com.albatross.api.v1.flow.services.report;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEventWorkQueueType;
import com.albatross.api.v1.flow.model.smartlist.*;
import com.albatross.api.v1.flow.queries.SmartlistQueryv1;
import com.albatross.api.v1.flow.queries.SmartlistQuery;
import com.albatross.api.v1.flow.services.OrgService;
import com.albatross.api.v1.flow.services.SmartlistServicev1;
import com.albatross.api.v1.flow.services.UserPositionService;
import com.albatross.api.v1.flow.services.UserService;
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
import java.time.Duration;
import java.time.Instant;
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

  private final ReportEngine reportEngine;

  private final SmartlistServicev1 smartlistServicev1;

  private boolean isSmartlistAdmin() {
    User user = securityService.getCurrentUser();
    return securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMARTLIST", List.of("ADMIN"));
  }

  /**
   * Determine if current user has access to given smartlist by either being it's owner, smartlist admin, or system admin
   *
   * @param smartlist
   * @return boolean
   */
  private boolean isOwnerOrAdmin(@NotNull Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    final var sameCompany = Objects.equals(user.getCompanyId(), smartlist.getCompanyId());
    final var isOwnerOrAdmin = Objects.equals(smartlist.getOwnerId(), user.getId()) || isSmartlistAdmin();
    return (sameCompany && isOwnerOrAdmin) || user.isSystemAdmin();
  }

  /**
   * Determine if current user has access to given smartlist by the smartlist being shared with user's current primary user position or shared with an org
   * in which the user's current primary position belongs
   *
   * @param smartlist
   * @return
   */
  private boolean isSharedWithCurrentUser(@NotNull Smartlist smartlist, @NotNull boolean checkEditAccess) {
    if (smartlist.getAccessControl().isEmpty()) {
      return false;
    }

    User user = securityService.getCurrentUser();

    //check access by user position first since it takes priority over org
    List<Long> userPositionIds = user.getUserPositions().stream().map(UserPosition::getId).toList();
    var hasAccess = smartlist.getAccessControl().stream().anyMatch(a -> {
      if (a.getUserPositionId() != null) {
        var isMatch = userPositionIds.contains(a.getUserPositionId());

        if (checkEditAccess) {
          return isMatch && a.getAccessControlId() == 2;
        } else {
          return isMatch;
        }
      }

      return false;
    });

    if (!hasAccess) {
      List<Long> orgIds = user.getUserPositions().stream().map(UserPosition::getOrgId).toList();
      hasAccess = smartlist.getAccessControl().stream().anyMatch(a -> {
        if (a.getOrgId() != null) {
          var isMatch = orgIds.contains(a.getOrgId());

          if (checkEditAccess) {
            return isMatch && a.getAccessControlId() == 2;
          } else {
            return isMatch;
          }
        }

        return false;
      });
    }

    return hasAccess;
  }

  public boolean userHasReadAccess(@NotNull Smartlist smartlist) {
    return isOwnerOrAdmin(smartlist) || isSharedWithCurrentUser(smartlist, false);
  }

  public boolean userHasWriteAccess(@NotNull Smartlist smartlist) {
    return isOwnerOrAdmin(smartlist) || isSharedWithCurrentUser(smartlist, true);
  }

  /**
   *
   * @param id
   * @return Smartlist or ResponseStatusException
   */
  public Smartlist getById(Long id) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of(
      "smartlistId", id,
      "companyId", user.getCompanyId(),
      "userId", user.getId()
    );
    Smartlist smartlist = sqlCache.getBySql(SmartlistQuery.getById, params, new SmartlistService.SmartlistMapper<>(Smartlist.class, om))
                                  .orElse(null);

    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Smartlist not found", new NotFoundException("Smartlist not found"));
    }

    //grant access to smartlist if user is owner, admin, or smartlist is public (public covers workqueue smartlists)
    if (!userHasReadAccess(smartlist) && !smartlist.isPublic()) {
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
  public Smartlist updateObjectType(Smartlist smartlist) {
    var existingSmartlist = getById(smartlist.getId());

    if (!userHasWriteAccess(existingSmartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    smartlist.setProjectDetails(false);

    if (!List.of(3, 5).contains(smartlist.getObjectTypeId().intValue())) {
      smartlist.setPrimaryUserPosition(false);
    }

    if (!List.of(1, 2, 4).contains(smartlist.getObjectTypeId().intValue())) {
      smartlist.setPrimaryUserPosition(true);
      smartlist.setMainProcessSteps(true);
    }

    updateSmartlist(smartlist, Collections.emptyList(), Collections.emptyList());
    sqlCache.updateBySql(SmartlistQueryv1.clearFieldsAndRequirements, Map.of("smartlistId", smartlist.getId(), "userId", securityService.getCurrentUser().getId()));
    return getById(smartlist.getId());
  }

  @Transactional
  public void updateProjectDetails(Long smartlistId) {
    var smartlist = getById(smartlistId);

    if (!userHasWriteAccess(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    smartlist.setProjectDetails(!smartlist.isProjectDetails());
    this.updateSmartlist(smartlist, Collections.emptyList(), Collections.emptyList());

    sqlCache.updateBySql(SmartlistQueryv1.clearFieldsAndRequirements, Map.of("smartlistId", smartlistId, "userId", securityService.getCurrentUser().getId()));
  }

  public Smartlist addSmartlist(Smartlist smartlist) {
    User user = securityService.getCurrentUser();

    boolean isNameUnique = sqlCache.queryForObjectBySql(SmartlistQuery.isNameUnique, Map.of("name", smartlist.getName(), "companyId", user.getCompanyId()), Boolean.class);
    if (!isNameUnique) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Smartlist name already taken", new Exception());
    }

    HashMap<String, Object> params = om.convertValue(smartlist, HashMap.class);
    params.put("ownerId", user.getId());
    params.put("createdById", user.trueUserId());
    Long smartlistId = sqlCache.updateBySqlReturningId(SmartlistQuery.add, params, "id").longValue();
    return getById(smartlistId);
  }

  @Transactional
  public void updateSmartlist(Smartlist smartlist, List<SmartlistFieldAssignment> fields, List<SmartlistRequirement> requirements) {

    var existingSmartlist = getById(smartlist.getId(), true);

    // @TODO: #smartlistsv2 - verify user has edit access to smartlist

    if (!userHasWriteAccess(existingSmartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    final boolean updatingName = !existingSmartlist.getName().trim().equals(smartlist.getName().trim());

    User user = securityService.getCurrentUser();
    boolean isNameUnique = sqlCache.queryForObjectBySql(SmartlistQuery.isNameUnique, Map.of("name", smartlist.getName(), "companyId", user.getCompanyId()), Boolean.class);

    if (updatingName && !isNameUnique) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, "Smartlist name already taken", new Exception());
    }

    HashMap<String, Object> params = om.convertValue(smartlist, HashMap.class);
    params.put("userId", user.trueUserId());

    sqlCache.updateBySql(SmartlistQuery.update, params);

    //update fields
    if (!fields.isEmpty()) {
      var deletedFields = fields.stream()
                                .filter(f -> Objects.equals(f.getUpdateType(), FieldUpdateType.DELETE))
                                .map(f -> Map.of("id", f.getId(), "userId", user.trueUserId()))
                                .toList();

      if (!deletedFields.isEmpty()) {
        sqlCache.updateBatchBySql(SmartlistQuery.deleteField, deletedFields);
      }

      var addedFields = fields.stream()
                              .filter(f -> Objects.equals(f.getUpdateType(), FieldUpdateType.ADD))
                              .toList();

      addedFields.forEach(f -> {
        f.setCreatedById(user.getId());
        f.setSmartlistId(smartlist.getId());
      });

      if (!addedFields.isEmpty()) {
        sqlCache.updateBatchBySql(SmartlistQuery.addField, addedFields);
      }

      var displayReorderFields = fields.stream()
                                       .filter(f -> f.getUpdateType() == null)
                                       .map(f -> Map.of(
                                         "id", f.getId(),
                                         "displayOrder", f.getDisplayOrder(),
                                         "userId", user.trueUserId()
                                       ))
                                       .toList();

      if (!displayReorderFields.isEmpty()) {
        sqlCache.updateBatchBySql(SmartlistQuery.updateDisplayOrder, displayReorderFields);
      }
    }

    //update reqs
    if (!requirements.isEmpty()) {
      var addedRequirements = requirements.stream()
                                             .filter(r -> (Objects.equals(r.getUpdateType(), FieldUpdateType.ADD)))
                                             .toList();
      addedRequirements.forEach(r -> {
        r.setCreatedById(user.trueUserId());
        r.setSmartlistId(smartlist.getId());
      });
      sqlCache.updateBatchBySql(SmartlistQuery.addRequirement, addedRequirements);

      var updatedRequirements = requirements.stream()
                                          .filter(r -> (Objects.equals(r.getUpdateType(), FieldUpdateType.UPDATE)))
                                          .toList();
      addedRequirements.forEach(r -> {
        r.setModifiedById(user.trueUserId());
        r.setSmartlistId(smartlist.getId());
      });
      sqlCache.updateBatchBySql(SmartlistQuery.updateRequirement, updatedRequirements);

      var deletedRequirements = requirements.stream()
                                            .filter(r -> Objects.equals(r.getUpdateType(), FieldUpdateType.DELETE))
                                            .map(r -> Map.of("id", r.getId(), "userId", user.trueUserId()))
                                            .toList();
      sqlCache.updateBatchBySql(SmartlistQuery.deleteRequirement, deletedRequirements);
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
                                                       .filter(i -> Objects.equals(i.getUserPositionId(), newOwner.getUserPositionId()))
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
    Map<String, Object> deleteParams = Map.of("id", currentAccess.getId(), "userId", user.getId(), "smartlistId", smartlistId);
    sqlCache.updateBySql(SmartlistQuery.deleteAccess, deleteParams);

    //give old owner edit access if not system or smartlist admin
    var oldOwnerPosition = userPositionService.getUserPrimaryPosition(smartlist.getOwnerId(), smartlist.getCompanyId());

    if (oldOwnerPosition != null) {
      try {
        Map<String, Object> params = new HashMap<>();
        params.put("smartlistId", smartlistId);
        params.put("orgId", null);
        params.put("userPositionId", oldOwnerPosition.getId());
        params.put("accessControlId", 2);
        params.put("userId", oldOwnerPosition.getUserId());
        sqlCache.updateBySqlReturningId(SmartlistQuery.addAccess, params, "id")
                .longValue();
      } catch (Exception e) {
        e.printStackTrace();
        throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected error occurred", new RuntimeException("Unexpected error occurred"));
      }
    }
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

  public void deleteAccess(Long smartlistId, List<SmartlistAccessControl> access) {
    User user = securityService.getCurrentUser();
    Smartlist smartlist = getById(smartlistId);

    if (!isOwnerOrAdmin(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    var params = access.stream().map(i -> Map.of(
      "id", i.getId(),
      "smartlistId", smartlistId,
      "userId", user.getId()
    )).toList();

    try {
      sqlCache.updateBatchBySql(SmartlistQuery.deleteAccess, params);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage(), new RuntimeException("Error when removing access"));
    }
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
    Map<String, Object> params = Map.of("companyId", user.getCompanyId(), "userId", user.getId(), "isSystemAdmin", user.isSystemAdmin());
    return sqlCache.queryBySql(SmartlistQuery.getMine, params, Smartlist.class);
  }

  public List<Smartlist> getShared() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId(), "userId", user.getId());
    return sqlCache.queryBySql(SmartlistQuery.getShared, params, Smartlist.class);
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
    List<UserPosition> userPositions = userPositionService.getPrimaryUserPositions();
    List<Org> orgs = orgService.getAllActive();

    //combine lists
    List<SmartlistAccessControl> combinedList = new ArrayList<>();
    userPositions.forEach(up -> {
      var share = new SmartlistAccessControl();
      share.setUserPositionId(up.getId());
      share.setIsUser(true);
      share.setIsOrg(false);
      share.setName(up.getFullName());
      share.setPosition(up.getPosition());
      share.setUserId(up.getUserId());
      combinedList.add(share);
    });

    orgs.forEach(o -> {
      var share = new SmartlistAccessControl();
      share.setOrgId(o.getId());
      share.setIsOrg(true);
      share.setIsUser(false);
      share.setName(o.getOrgName());
      combinedList.add(share);
    });

    combinedList.sort((s1, s2) -> s1.getName().compareToIgnoreCase(s2.getName()));

    return combinedList;
  }

  private void saveError(Smartlist smartlist, String query, List<SmartlistFieldAssignment> fields, List<SmartlistRequirement> requirements, Exception e) {
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
      params.put("requirements", om.writeValueAsString(requirements));
    } catch (Exception err) {
      //noop
    }

    sqlCache.updateBySql(SmartlistQuery.addError, params);

    log.error(String.format("SMARTLIST: Error while running smartlist ID: %s, message: %s", smartlist.getId(), e.getMessage()));
  }

  private void saveMetric(
    Smartlist smartlist,
    String query,
    List<SmartlistFieldAssignment> fields,
    List<SmartlistRequirement> requirements,
    long duration
  ) {
    try {
      Map<String, Object> params = new HashMap<>();
      params.put("smartlistId", smartlist.getId());
      params.put("createdById", securityService.getCurrentUser().getId());
      params.put("query", query);
      params.put("smartlist", om.writeValueAsString(smartlist));
      params.put("fields", om.writeValueAsString(fields));
      params.put("requirements", om.writeValueAsString(requirements));
      params.put("duration", duration);

      sqlCache.updateBySql(SmartlistQuery.addMetric, params);
    } catch (Exception e) {
      //noop
      log.debug("SMARTLIST: Error saving export metrics: {}", e.getMessage());
    }
  }

  public List<SmartlistMetric> getMetrics(@NotNull Long smartlistId) {
    try {
      var user = securityService.getCurrentUser();
      Map<String, Object> params = Map.of("smartlistId", smartlistId, "companyId", user.getCompanyId());
      return sqlCache.queryBySql(SmartlistQuery.getMetrics, params, SmartlistMetric.class);
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error while fetching smartlist metrics", new RuntimeException());
    }
  }

  public String export(Long smartlistId, String timezone) throws JsonProcessingException {
    Smartlist smartlist = this.getById(smartlistId);

    List<SmartlistFieldAssignment> fields = (smartlist.isProjectDetails()) ? getAssignedProjectDetailsFields(smartlistId) : getAssignedFields(smartlistId);
    List<SmartlistRequirement> requirements = getRequirements(smartlist.getId(), false);

    if (null == smartlist.getWorkQueueTypeId() && fields.isEmpty()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist must have at least 1 field", new Exception());
    }

    if (!smartlist.isProjectDetails()) {
      fields = prettifyFieldNames(fields);
    }

    log.debug("SMARTLIST: Running smartlist ID: {}", smartlistId);
    String query;

    //dont run the processStepSql if it is for a work queue list. i only put the work queue code into the buildSql funtion
    if (smartlist.isProjectDetails()) {
      query = reportEngine.buildProjectDetailsSql(smartlist, fields, requirements, null);
    } else if (List.of(4L, 6L).contains(smartlist.getObjectTypeId()) && null == smartlist.getWorkQueueTypeId()) {
      if (smartlist.getObjectTypeId() == 4) {
        query = reportEngine.buildProcessStepSql(smartlist, fields, requirements, null);
      } else {
        query = reportEngine.buildEventSql(smartlist, fields, requirements, null, null);
      }
    } else {
      if (smartlist.getWorkQueueTypeId() != null && smartlist.getObjectTypeId() == 6) {
        query = reportEngine.buildWorkQueueSql(smartlist, fields, true, timezone);
      } else {
        query = reportEngine.buildSql(smartlist, fields, requirements, timezone, null, false, null);
      }
    }

    List<Map<String, Object>> results;

    try {
      Instant start = Instant.now();
      results = sqlCacheRO.queryBySql(query, null, new ColumnMapRowMapper());
      Instant finish = Instant.now();
      long duration = Duration.between(start, finish).toMillis();
      saveMetric(smartlist, query, fields, requirements, duration);
    } catch (Exception e) {
      saveError(smartlist, query, fields, requirements, e);
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

  public List<Map<String, Object>> getAdhocReportData(
    Smartlist report,
    List<SmartlistFieldAssignment> fields,
    List<SmartlistRequirement> requirements,
    Integer limit,
    String timezone
  ) {
    return getAdhocReportData(report, fields, requirements, limit, timezone, false);
  }

  public List<Map<String, Object>> getAdhocReportData(
    Smartlist report,
    List<SmartlistFieldAssignment> fields,
    List<SmartlistRequirement> requirements,
    Integer limit,
    String timezone,
    Boolean queryOnly
  ) {

    //if we are working with an existing smartlist, verify read access
    if (report.getId() != null) {
      getById(report.getId());
    }

    if (!List.of(1L,2L,3L,4L,5L,6L).contains(report.getObjectTypeId())) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist must have a data type");
    }

    User user = securityService.getCurrentUser();

    //get tables for any fields/reqs using smartlist fields
    List<Long> usedSmartlistFieldIds = new ArrayList<>(fields.stream()
                                                             .map(SmartlistFieldAssignment::getSmartlistFieldId)
                                                             .filter(Objects::nonNull)
                                                             .toList());

    usedSmartlistFieldIds.addAll(requirements.stream()
                                             .map(SmartlistRequirement::getSmartlistFieldId)
                                             .filter(Objects::nonNull)
                                             .toList()
    );

    if (!usedSmartlistFieldIds.isEmpty()) {
      var params = Map.of("companyId", user.getCompanyId(), "ids", usedSmartlistFieldIds);
      List<SmartlistFieldAssignment> smartlistFields = sqlCacheRO.queryBySql(SmartlistQuery.getSmartlistFieldsByIds, params, new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));

      fields.forEach(field -> {
        if (field.getSmartlistFieldId() != null) {
          var fieldFromDb = smartlistFields.stream()
                                           .filter(f -> Objects.equals(f.getSmartlistFieldId(), field.getSmartlistFieldId()))
                                           .findFirst();

          fieldFromDb.ifPresent(f -> {
            field.setReferenceTable(f.getReferenceTable());
            field.setReferenceColumn(f.getReferenceColumn());
            field.setJoinTable(f.getJoinTable());
            field.setJoinColumn(f.getJoinColumn());
          });
        }
      });

      requirements.forEach(requirement -> {
        if (requirement.getSmartlistFieldId() != null) {
          var fieldFromDb = smartlistFields.stream()
                                           .filter(f -> Objects.equals(f.getSmartlistFieldId(), requirement.getSmartlistFieldId()))
                                           .findFirst();

          fieldFromDb.ifPresent(f -> {
            requirement.setReferenceTable(f.getReferenceTable());
            requirement.setReferenceColumn(f.getReferenceColumn());
            requirement.setJoinTable(f.getJoinTable());
            requirement.setJoinColumn(f.getJoinColumn());
          });
        }
      });
    }

    //@TODO: #smartlistsv2 - ID is used in some cases for fields in report engine. Setting a random ID for now. This has potential to cause conflicts and needs a long term solution
    fields.forEach(f -> {
      if (f.getId() == null) {
        f.setId((long) ((Math.random() * (40000 - 20000)) + 20000));
      }
    });

    String query;

    if (List.of(4L, 6L).contains(report.getObjectTypeId())) {
      query = reportEngine.buildProcessStepSql(report, fields, requirements, limit);
    } else {
      query = (report.isProjectDetails()) ?
        reportEngine.buildProjectDetailsSql(report, fields, requirements, limit) :
        reportEngine.buildSql(report, fields, requirements, timezone, null, false, limit);
    }

    if (Objects.equals(queryOnly, true)) {
      return List.of(Map.of("query", query));
    }

    try {
      return sqlCacheRO.queryBySql(query, null, new ColumnMapRowMapper());
    } catch (Exception e) {
      saveError(report, query, fields, requirements, e);
      throw e;
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

    Smartlist smartlist = getById(smartlistId);
    User user = securityService.getCurrentUser();

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

  // @TODO: #smartlistsv2 - this was pulled from v1, for sure revamp
  public List<SmartlistRequirement> getRequirements(Long smartlistId, boolean includeListValues) {
    var smartlist = getById(smartlistId);

    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Map<String, Object> params = Map.of("smartlistId", smartlistId, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany, "parentCompanyId", user.getHighestParentCompanyId());

    List<SmartlistRequirement> requirements;

    if (smartlist.isProjectDetails()) {
      requirements = sqlCache.queryBySql(SmartlistQueryv1.getProjectDetailsRequirements, params, new SmartlistRequirementMapper<>(SmartlistRequirement.class, om));
    } else {
      requirements = sqlCache.queryBySql(SmartlistQueryv1.getRequirements, params, new SmartlistRequirementMapper<>(SmartlistRequirement.class, om));

      if (includeListValues) {
        for (SmartlistRequirement r : requirements) {
          if (r.getCustomFieldSql() != null) {
            final String sql = r.getCustomFieldSql();
            if (sql != null) {
              r.setAvailableListOfValues(sqlCache.queryBySql(sql, null, ListOfValue.class));
            }
          }
        }
      }
    }

    return requirements;
  }

  public SmartlistRequirement addRequirement(Long smartlistId, SmartlistRequirement requirement) {

    if (!Objects.equals(smartlistId, requirement.getSmartlistId())) {
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Given smartlist ID must match requirement smartlist ID",
        new RuntimeException("Given smartlist ID must match requirement smartlist ID")
      );
    }

    var smartlist = getById(smartlistId);

    if (!userHasWriteAccess(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = om.convertValue(requirement, HashMap.class);
    params.put("userId", user.trueUserId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    Long requirementId = sqlCache.updateBySqlReturningId(SmartlistQueryv1.addRequirement, params, "id").longValue();

    if (smartlist.isProjectDetails()) {
      return getProjectDetailsRequirementById(requirementId);
    } else {
      return getRequirementById(requirementId);
    }
  }

  public SmartlistRequirement updateRequirement(SmartlistRequirement requirement) {
    var smartlist = getById(requirement.getSmartlistId());

    if (!userHasWriteAccess(smartlist)) {
      throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access Denied", new AccessDeniedException("Access Denied"));
    }

    HashMap<String, Object> params = om.convertValue(requirement, HashMap.class);
    params.put("userId", securityService.getCurrentUser().trueUserId());
    params.put("listOfValueIds", (requirement.getListOfValueIds() == null) ? List.of() : requirement.getListOfValueIds());
    sqlCache.updateBySql(SmartlistQueryv1.updateRequirement, params);

    if (smartlist.isProjectDetails()) {
      return getProjectDetailsRequirementById(requirement.getId());
    } else {
      return getRequirementById(requirement.getId());
    }
  }

  public List<SmartlistFieldAssignment> getAssignedFields(Long smartlistId) {
    return sqlCache.queryBySql(SmartlistQueryv1.getAssignedFields, Map.of("smartlistId", smartlistId), new SmartlistService.SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
  }

  public List<SmartlistFieldAssignment> getAssignedProjectDetailsFields(Long smartlistId) {
    return sqlCache.queryBySql(SmartlistQueryv1.getAssignedProjectDetailsFields, Map.of("smartlistId", smartlistId), new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
  }

  // @TODO: #smartlistsv2 - this was pulled from v1, for sure revamp
  public List<SmartlistFieldAssignment> getFields(@NotNull Long smartlistId) {
    var smartlist = getById(smartlistId);

    if (smartlist.isProjectDetails()) {
      return getAssignedProjectDetailsFields(smartlistId);
    } else {
      return getAssignedFields(smartlistId);
    }
  }

  public List<SmartlistFieldAssignment> getAvailableFields(@NotNull List<Long> objectTypeIds) {
    Map<String, Object> params = Map.of("companyId", securityService.getCurrentUser().getCompanyId(), "objectTypeIds", objectTypeIds);
    return sqlCache.queryBySql(SmartlistQuery.getAvailableFields, params, new SmartlistFieldAssignmentMapper<>(SmartlistFieldAssignment.class, om));
  }

  // @TODO: #smartlistsv2 - this was pulled from v1, for sure revamp
  public SmartlistRequirement getRequirementById(Long requirementId) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Map<String, Object> params = Map.of("requirementId", requirementId, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany);
    SmartlistRequirement requirement = sqlCache.getBySql(SmartlistQueryv1.getRequirementById, params, new SmartlistRequirementMapper<>(SmartlistRequirement.class, om))
                                               .orElse(null);

    if (requirement != null && requirement.getCustomFieldSql() != null) {
      final String sql = requirement.getCustomFieldSql();
      if (sql != null) {
        requirement.setAvailableListOfValues(sqlCache.queryBySql(sql, null, ListOfValue.class));
      }
    }

    return requirement;
  }

  // @TODO: #smartlistsv2 - this was pulled from v1, for sure revamp
  public SmartlistRequirement getProjectDetailsRequirementById(Long requirementId) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Map<String, Object> params = Map.of("id", requirementId, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany);
    return sqlCache.getBySql(SmartlistQueryv1.getProjectRequirementById, params, new SmartlistRequirementMapper<>(SmartlistRequirement.class, om))
                   .orElse(null);
  }

  /**
   * Changes event/PS field names into `fieldName (event/PSName)` and truncates to 63 chars
   */
  public List<SmartlistFieldAssignment> prettifyFieldNames(List<SmartlistFieldAssignment> fields) {
    for (SmartlistFieldAssignment f : fields) {
      if (f.getObjectTypeId() == 4 || f.getObjectTypeId() == 6) {
        f.setName(String.format("%s (%s)", f.getName(), (f.getObjectTypeId() == 6) ? f.getEventName() : f.getProcessStepName()));

        if (f.getName().length() > 63) {
          f.setName(f.getName().substring(0, 60) + "...");
        }
      }
    }
    return fields;
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
