package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.CommunicationController;
import com.albatross.api.v1.flow.controllers.ProjectController;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAction;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.model.project.ProjectDensityResult;
import com.albatross.api.v1.flow.model.project.ProjectStatusCount;
import com.albatross.api.v1.flow.model.project.ProjectStatusType;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStep;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueTypeProjectStatus;
import com.albatross.api.v1.flow.services.mapbox.MapboxApiService;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.ImmutableMap;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProjectService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final AttachmentService attachmentService;

  private final AmazonS3 s3;

  private final ObjectMapper om;

  private final MapboxApiService mapboxApiService;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public List<Project> getProjectsForProcess(Long processId) {
    User user = securityService.getCurrentUser();
    return sqlCache.query(
        "project.getAllForCompanyProcess",
        ImmutableMap.of("companyId", user.getCompanyId(), "processId", processId),
        Project.class);
  }

  public Long getProjectIdByProjectProcessStepId(Long projectProcessStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    return sqlCache.queryForObject(
        "project.getProjectIdByProjectProcessStepId", params, Long.class);
  }

  public Long getProjectIdByProjectProcessStepEventId(Long projectProcessStepEventId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    return sqlCache.queryForObject(
        "project.getProjectIdByProjectProcessStepEventId", params, Long.class);
  }

  public List<ProjectDensityResult> getProjectsInGeoArea(DensitySearch search) {
    User currentUser = securityService.getCurrentUser();

    if (null != search.getUpperBoundLatitude()
        && null != search.getUpperBoundLongitude()
        && null != search.getLowerBoundLatitude()
        && null != search.getLowerBoundLongitude()) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("upperBoundLatitude", search.getUpperBoundLatitude());
      params.put("upperBoundLongitude", search.getUpperBoundLongitude());
      params.put("lowerBoundLatitude", search.getLowerBoundLatitude());
      params.put("lowerBoundLongitude", search.getLowerBoundLongitude());
      params.put("currentUserId", currentUser.getId());
      params.put("companyProjectStatusTypeIds", search.getCompanyProjectStatusTypeIds());
      Boolean isParent = currentUser.getCompanyId().equals(currentUser.getHighestParentCompanyId());
      params.put("isParent", isParent);
      params.put("companyId", currentUser.getCompanyId());
      params.put("parentCompanyId", currentUser.getHighestParentCompanyId());

      // if no search type is sent in then return "all projects" //1 = all project, 2 = my projects,
      // 3 = downline projects
      if (null != search.getSearchTypeId() && search.getSearchTypeId() == 3L) {
        return sqlCache.query(
            "project.getProjectsInGeoAreaDownline", params, ProjectDensityResult.class);
      } else {
        params.put("searchTypeId", null == search.getSearchTypeId() ? 1 : search.getSearchTypeId());
        return sqlCache.query("project.getProjectsInGeoArea", params, ProjectDensityResult.class);
      }
    } else {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "Invalid Bound Parameters", new Exception());
    }
  }

  public Page<Project> searchProjects(
      String query,
      Long companyProjectStatusTypeId,
      String overrideType,
      String sortColumn,
      String sortDirection,
      Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Boolean viewAll =
        securityService.userHasFeatureAccessLevel(
            user.getId(),
            user.getCompanyId(),
            user.getHighestCompanyId(),
            "PROJECTS",
            List.of("VIEW_ALL"));
    Boolean viewDownline = false;

    if ((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view")))
        || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewDownline =
          securityService.userHasFeatureAccessLevel(
              user.getId(),
              user.getCompanyId(),
              user.getHighestCompanyId(),
              "PROJECTS",
              List.of("VIEW_DOWNLINE"));
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("companyProjectStatusTypeId", companyProjectStatusTypeId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("sortColumn", sortColumn);
    params.put("sortDirection", sortDirection);
    params.put("userId", user.getId());
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    String searchSqlKey = "project.searchByOwner";
    if (viewDownline) {
      searchSqlKey = "project.searchDownline";
    } else if (viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) {
      searchSqlKey = "project.search";
    }
    //    String countSqlKey = viewAll ? "project.searchCount" : viewDownline ?
    // "project.searchDownlineCount" : "project.searchByOwnerCount";

    List<Project> projects =
        sqlCache.query(searchSqlKey, params, new ProjectMapper<>(Project.class, om));
    //    Integer total = sqlCache.queryForObject(countSqlKey, params, Integer.class);
    Integer total = 10000;
    return new PageImpl<>(
        projects, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), total);
  }

  public List<ProjectStatusCount> projectCountsByStatus(String overrideType) {
    User user = securityService.getCurrentUser();
    Boolean viewAll =
        securityService.userHasFeatureAccessLevel(
            user.getId(),
            user.getCompanyId(),
            user.getHighestCompanyId(),
            "PROJECTS",
            List.of("VIEW_ALL"));
    Boolean viewDownline = false;

    if ((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view")))
        || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewDownline =
          securityService.userHasFeatureAccessLevel(
              user.getId(),
              user.getCompanyId(),
              user.getHighestCompanyId(),
              "PROJECTS",
              List.of("VIEW_DOWNLINE"));
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());
    params.put("viewDownline", viewDownline);

    String searchSqlKey = "project.countsByStatusByUser";
    if (viewAll
        && (null == overrideType
            || (!overrideType.equalsIgnoreCase("view")
                && !overrideType.equalsIgnoreCase("downline")))) {
      searchSqlKey = "project.countsByStatus";
    }
    //    String searchSqlKey = viewAll ? "project.countsByStatus" : "project.countsByStatusByUser";

    List<ProjectStatusCount> results =
        sqlCache.query(searchSqlKey, params, ProjectStatusCount.class);

    for (ProjectStatusCount c : results) {
      // set the icon for the status
      Attachment a =
          attachmentService.getOneBySourceIdAndType(c.getCompanyProjectStatusTypeId(), 463L);
      c.setIcon(null != a && null != a.getId() ? a : new Attachment());
    }

    return results;
  }

  // i tried to genericize this but it is still pretty specific to only brs.
  public Boolean projectExistsInHierarchy(Long projectId, Long parentCompanyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("parentCompanyId", parentCompanyId);
    Optional<Project> proj = sqlCache.get("project.existsInHierarchy", params, Project.class);
    return proj.isPresent();
  }

  // i tried to genericize this but it is still pretty specific to only brs.
  public Boolean projectExists(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    Optional<Project> proj = sqlCache.get("project.exists", params, Project.class);
    return proj.isPresent();
  }

  public Optional<Project> getProject(Long projectId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = ImmutableMap.of("projectId", projectId, "companyId", user.getCompanyId(), "isParent", user.isParentCompany(), "parentCompanyId", user.getHighestParentCompanyId());
      Optional<Project> result = sqlCache.get("project.get", params, new ProjectMapper<>(Project.class, om));
      if (result.isPresent()) {
          return result;
      } else {
          throw new NotFoundException("FAIL_TO_NOT_FOUND_SCREEN");
      }
  }

  public void deleteProject(Long projectId) {
    User user = securityService.getCurrentUser();
    // todo: security: this is still a problem if the user doesn't have access to the specific
    // company
    securityService.validateUserFeatureAccessLevel(
        user.getId(),
        user.getCompanyId(),
        user.getHighestCompanyId(),
        "PROCESS_STEPS",
        List.of("ADMIN"));

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("projectId", projectId);

    sqlCache.update("project.delete", params);
  }

  public List<Owner> getOwners() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    return sqlCache.query(
        "project.getOwners",
        ImmutableMap.of(
            "companyId", user.getCompanyId(),
            "isParent", isParent,
            "parentCompanyId", user.getHighestParentCompanyId()),
        Owner.class);
  }

  public void updateProject(Project project) throws Exception {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", project.getId());
    params.put("street1", project.getStreet1());
    params.put("projectName", CleanString.replaceApostrophe(project.getProjectName()));
    params.put("city", project.getCity());
    params.put("companyStateId", project.getCompanyStateId());
    params.put("postalCode", project.getPostalCode());
    params.put("companyCountryId", project.getCompanyCountryId());
    params.put("modifiedById", currentUser.trueUserId());

    // pre-populate lat/long/tz with the existing project values
    Double latitude = project.getLatitude();
    Double longitude = project.getLongitude();
    String timezone = project.getTimeZone();

    // if the project address changed, reload the coordinates
    if (null != project.getReloadCoordinates() && project.getReloadCoordinates()) {
      final String address =
          stringifyAddress(
              project.getStreet1(), project.getCity(), project.getState(), project.getPostalCode());

      final var latLongAndTimezone = mapboxApiService.getLatLongAndTimezone(address);
      if (latLongAndTimezone.isPresent()) {
        final var mapboxGeoResponse = latLongAndTimezone.get();
        latitude = mapboxGeoResponse.latitude();
        longitude = mapboxGeoResponse.longitude();
        timezone = mapboxGeoResponse.timezone();
      } else {
        // if the address changed but we didn't find valid coordinates for the new address then set
        // these values to null
        latitude = null;
        longitude = null;
        timezone = null;
      }
    }

    params.put("latitude", latitude);
    params.put("longitude", longitude);
    params.put("timezone", timezone);

    sqlCache.update("project.update", params);
  }

  public void updateProjectOwner(Long projectId, Owner owner) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", projectId);
    params.put("modifiedById", currentUser.trueUserId());
    params.put("ownerUserPositionId", owner.getUserPositionId());

    sqlCache.update("project.updateOwner", params);
  }

  public Optional<Project> insertProject(Long contactId, Long processId, Contact contact)
      throws Exception {
    User user = securityService.getCurrentUser();

    if (null != contactId && null != processId) {
      // Get active company project status type so new projects can have an active status
      CompanyProjectStatusType companyStatusType =
          this.getDefaultCompanyProjectStatusType(contact.getCompanyId());
      Long companyStatusTypeId = (companyStatusType != null) ? companyStatusType.getId() : null;

      HashMap<String, Object> params = new HashMap<>();
      params.put("contactId", contactId);
      params.put("createdById", user.trueUserId());
      params.put("projectName", CleanString.replaceApostrophe(contact.getFullName()));
      params.put("processId", processId);
      params.put("street1", contact.getStreet1());
      params.put("city", contact.getCity());
      params.put("companyStateId", contact.getCompanyStateId());
      params.put("companyCountryId", contact.getCompanyCountryId());
      params.put("postalCode", contact.getPostalCode());
      params.put("companyProjectStatusTypeId", companyStatusTypeId);

      // with my most recent changes the contact should already have a valid lat/long if the address
      // was valid
      params.put("latitude", contact.getLatitude());
      params.put("longitude", contact.getLongitude());
      String timezone = null;
      if (null != contact.getLatitude() && null != contact.getLongitude()) {
        // if we have a lat/long then attempt to load the timezone
        timezone = mapboxApiService.getTimezone(contact.getLatitude(), contact.getLongitude());
      }
      params.put("timezone", timezone);

      //      List<Double> coordinates =
      // mapboxApiService.getLatLong(stringifyAddress(contact.getStreet1(), contact.getCity(),
      // contact.getState(), contact.getPostalCode()));
      //      Double latitude = null, longitude = null;
      //      String timezone = null;
      //      if(!coordinates.isEmpty() && null != coordinates.get(0) && null != coordinates.get(1))
      // {
      //        //1 = lat, 0 = long
      //        latitude = coordinates.get(1);
      //        longitude = coordinates.get(0);
      //
      //        if(null != latitude && null != longitude) {
      //          //if we have a lat/long then attempt to load the timezone
      //          timezone = mapboxApiService.getTimezone(latitude, longitude);
      //        }
      //      }
      //      params.put("latitude", latitude);
      //      params.put("longitude", longitude);
      //      params.put("timezone", timezone);

      Long id = sqlCache.updateReturningId("project.insert", params, "id").longValue();
      // load coordinates when new project added
      //      project.ifPresent(value -> getProjectCoordinates(value, id));
      return getProject(id);
    } else {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Contact ID and Process ID are required to add a project.",
          new Exception());
    }
  }

  public void getProjectCoordinates(Project project, Long id) throws Exception {
    // when the contact is new or the address changes,
    // need to reload/save their lat/long from mapbox
    String projectAddress = getProjectAddress(project);
    mapboxApiService
        .getLatLongAndTimezone(projectAddress)
        .ifPresent(
            res -> {
              HashMap<String, Object> params = new HashMap<>();
              params.put("latitude", res.latitude());
              params.put("longitude", res.longitude());
              params.put("timeZone", res.timezone());
              params.put("id", id);

              sqlCache.update("project.updateGeoLocation", params);
            });
  }

  private String stringifyAddress(String street1, String city, String state, String postalCode) {
    StringJoiner sj = new StringJoiner(", ");
    sj.add(street1);
    sj.add(city);
    sj.add(state + " " + postalCode);

    return sj.toString();
  }

  private String getProjectAddress(Project project) {
    StringJoiner sj = new StringJoiner(", ");
    sj.add(project.getStreet1());
    sj.add(project.getCity());
    sj.add(
        project.getState()
            + (null == project.getPostalCode() ? "" : " " + project.getPostalCode()));

    return sj.toString();
  }

  public List<Attachment> getAttachments(Long projectId, Boolean isMobile) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    // Get project attachments
    List<Attachment> attachments =
        sqlCache.query("project.getAttachments", params, Attachment.class);
    // Get project process step attachments
    List<Attachment> ppsAttachments =
        sqlCache.query(
            "projectProcessStep.getProjectProcessStepAttachmentsForProjectId",
            params,
            Attachment.class);
    attachments.addAll(ppsAttachments);
    return attachmentService.getAttachmentPresignedUrls(
        attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  public Attachment addAttachment(MultipartFile file, @NonNull Long projectId, Long attachmentTypeId)
      throws IOException {
    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }
    return addAttachment(projectId, attachmentTypeId, file.getSize(), file.getContentType(), file.getOriginalFilename(), new ByteArrayInputStream(file.getBytes()));
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(@NonNull Long projectId, @NonNull Long attachmentTypeId, Long contentLength, String contentType, String filename, InputStream inputStream){
    User currentUser = securityService.getCurrentUser();

    // had to change this so that a parent looking at a child project could still see project
    // statuses
    Long companyId = sqlCache.queryForObject("project.getCompanyId", Map.of("projectId", projectId), Long.class);

    // get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key =
      String.format(
        currentUser.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(contentLength);
    metadata.setContentType(contentType);

    final PutObjectRequest putObjectRequest = new PutObjectRequest(storageBucket, key, inputStream, metadata);
    s3.putObject(putObjectRequest.withCannedAcl(CannedAccessControlList.PublicRead));

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", CleanString.cleanFilename(filename));
    params.put("contentType", contentType);
    params.put("key", key);
    params.put("size", contentLength);
    params.put("createdById", currentUser.trueUserId());
    params.put("companyId", companyId);
    params.put("attachmentTypeId", attachmentTypeId);

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectId", projectId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", currentUser.trueUserId());

    sqlCache.update("project.addAttachment", params);

    return attachmentService.findById(attachmentId);
  }

  public Optional<Project> updateStatus(Long projectId, Long companyProjectStatusTypeId) {
    sqlCache.update(
        "project.updateStatus",
        Map.of("projectId", projectId, "companyProjectStatusTypeId", companyProjectStatusTypeId));
    return getStatus(projectId);
  }

  public Optional<Project> getStatus(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    return sqlCache.get("project.getStatusDetails", params, Project.class);
  }

  private CompanyProjectStatusType getDefaultCompanyProjectStatusType(Long companyId) {
    return sqlCache
        .get(
            "project.getDefaultProjectStatusTypeByCompanyId",
            Map.of("companyId", companyId),
            CompanyProjectStatusType.class)
        .orElse(null);
  }

  public List<ProjectProcessStep> getProcessStepsByProjectId(Long projectId, Long statusTypeId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("companyId", user.getCompanyId());
    params.put("statusTypeId", statusTypeId);
    params.put("isParent", isParent);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    return sqlCache.query(
        "project.getProcessStepsByProjectId",
        params,
        new ProjectProcessStepService.ProjectProcessStepMapper<>(ProjectProcessStep.class, om));
  }

  public List<ProjectProcessStepEvent> getEventsByProjectId(Long projectId, Long statusTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("statusTypeId", statusTypeId);
    return sqlCache.query("project.getEventsByProjectId", params, ProjectProcessStepEvent.class);
  }

  public CommunicationController.ProjectDetails getProjectDetailTemplateFields(Long projectId) {
    return sqlCache
      .get("project.getProjectDetailTemplateFields", Map.of("projectId", projectId), CommunicationController.ProjectDetails.class)
      .orElse(null);
  }

  public List<WorkQueueTypeProjectStatus> getStatusesForWqt() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.query("project.getStatusesForWqt", params, WorkQueueTypeProjectStatus.class);
  }

  public List<ProjectStatusType> getCompanyProjectStatuses(Long projectId) {
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();

    if (null != projectId) {
      // had to change this so that a parent looking at a child project could still see project
      // statuses
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      companyId = sqlCache.queryForObject("project.getCompanyId", params, Long.class);
    }

    // NOTE: this returns COMPANY project statuses...as it should. but don't let it confuse you
    List<ProjectStatusType> results =
        sqlCache.query(
            "project.getCompanyStatuses",
            ImmutableMap.of("companyId", companyId),
            ProjectStatusType.class);

    for (ProjectStatusType c : results) {
      // set the icon for the status
      Attachment a = attachmentService.getOneBySourceIdAndType(c.getId(), 463L);
      c.setIcon(null != a && null != a.getId() ? a : new Attachment());
    }

    return results;
  }

  public Optional<ProjectStatusType> getOneCompanyProjectStatusType(Long id) {
    Optional<ProjectStatusType> result =
        sqlCache.get(
            "project.getOneCompanyStatus", ImmutableMap.of("id", id), ProjectStatusType.class);

    if (result.isPresent()) {
      Attachment a = attachmentService.getOneBySourceIdAndType(result.get().getId(), 463L);
      result.get().setIcon(null != a && null != a.getId() ? a : new Attachment());
    }

    return result;
  }

  public void saveInitialProjectStatusType(Long companyProjectStatusTypeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", companyProjectStatusTypeId);
    params.put("companyId", currentUser.getCompanyId());
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("project.saveInitialProjectStatusType", params);
  }

  public Optional<ProjectStatusType> saveCompanyProjectStatus(ProjectStatusType status) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("rootProjectStatusTypeId", status.getProjectStatusTypeId());
    params.put("projectStatusType", status.getProjectStatusType());
    params.put("color", status.getColor());
    params.put("companyId", currentUser.getCompanyId());
    Long id;

    if (null != status.getId()) {
      id = status.getId();
      params.put("id", id);
      params.put("displayOrder", status.getDisplayOrder());
      sqlCache.update("project.updateCompanyStatus", params);
    } else {
      id = sqlCache.updateReturningId("project.insertCompanyStatus", params, "id").longValue();
    }

    // handle attachment

    return getOneCompanyProjectStatusType(id);
  }

  public void saveCompanyProjectStatuses(List<ProjectStatusType> statuses) {
    for (ProjectStatusType s : statuses) {
      saveCompanyProjectStatus(s);
    }
  }

  public ResponseEntity<ProjectController.CannotDeleteProjectStatus> deleteCompanyProjectStatus(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.trueUserId());
    params.put("id", id);

    List<Project> projectsWithStatus = sqlCache.query("project.getProjectsWithStatusInUse", Map.of("companyProjectStatusTypeId", id), Project.class);
    List<ProcessStepAction> processStepActions = sqlCache.query("project.psaWithStatusInUse", Map.of("companyProjectStatusTypeId", id), ProcessStepAction.class);
    List<ProjectController.ProcessStepEventData> processStepEventRequirements = sqlCache.query("project.getPserWithStatusInUse", Map.of("companyProjectStatusTypeId", id), ProjectController.ProcessStepEventData.class);
    List<ProjectController.ProcessStepEventData> processStepRequirements = sqlCache.query("project.getPsrWithStatusInUse", Map.of("companyProjectStatusTypeId", id), ProjectController.ProcessStepEventData.class);

    if (projectsWithStatus.isEmpty() && processStepActions.isEmpty() && processStepRequirements.isEmpty()) {
      sqlCache.update("project.deleteCompanyStatus", params);
      return ResponseEntity.ok().build();
    }
    else {
      ProjectController.CannotDeleteProjectStatus cannotDelete = new ProjectController.CannotDeleteProjectStatus();
      cannotDelete.setProjectsWithStatus(projectsWithStatus);
      cannotDelete.setProcessStepActions(processStepActions);
      cannotDelete.setProcessStepEventRequirements(processStepEventRequirements);
      cannotDelete.setProcessStepRequirements(processStepRequirements);
      return ResponseEntity.badRequest().body(cannotDelete);
    }
  }

  public List<ProjectStatusType> getProjectStatuses() {
    return sqlCache.query("project.getStatuses", Collections.emptyMap(), ProjectStatusType.class);
  }

  public String generateReport(String query) {
    User user = securityService.getCurrentUser();
    List<Map<String, Object>> projects =
        sqlCache.query(
            "project.generateReport",
            Map.of("companyId", user.getCompanyId(), "query", query),
            new ColumnMapRowMapper());

    // write CSV
    CsvSchema.Builder builder = CsvSchema.builder();
    builder.addColumn("ID", CsvSchema.ColumnType.NUMBER_OR_STRING);
    builder.addColumn("Name", CsvSchema.ColumnType.NUMBER_OR_STRING);
    builder.addColumn("Process", CsvSchema.ColumnType.NUMBER_OR_STRING);
    builder.addColumn("Status", CsvSchema.ColumnType.NUMBER_OR_STRING);
    builder.addColumn("Date Created", CsvSchema.ColumnType.NUMBER_OR_STRING);

    CsvSchema schema = builder.build().withHeader();
    ObjectWriter w = new CsvMapper().writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    try (SequenceWriter toBuffer = w.writeValues(buffer)) {
      toBuffer.writeAll(projects);
      toBuffer.flush();
      return buffer.toString(StandardCharsets.UTF_8);
    } catch (IOException e) {
      return null;
    }
  }

  private static class ProjectMapper<T> extends BeanPropertyRowMapper<T> {
    public final ObjectMapper objectMapper;

    public ProjectMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Contact> contactRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          Object.class, "contact", new JsonCollectionDeserializer(contactRef, objectMapper));

      TypeReference<Owner> ownerRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          Object.class, "owner", new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> statusReadOnlyWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "statusReadOnlyWhiteListedPositions",
          new JsonCollectionDeserializer(statusReadOnlyWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> ownerReadOnlyWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "ownerReadOnlyWhiteListedPositions",
          new JsonCollectionDeserializer(ownerReadOnlyWhiteListedPositionsRef, objectMapper));
    }
  }
}
