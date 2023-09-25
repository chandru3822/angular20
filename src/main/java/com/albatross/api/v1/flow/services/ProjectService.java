package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.CommunicationController;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.project.*;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStep;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.queries.AttachmentQuery;
import com.albatross.api.v1.flow.queries.ProjectProcessStepQuery;
import com.albatross.api.v1.flow.queries.ProjectQuery;
import com.albatross.api.v1.flow.queries.ProjectStatusQuery;
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
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProjectService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final ProjectStatusService projectStatusService;

  private final AttachmentService attachmentService;

  private final AmazonS3 s3;

  private final ObjectMapper om;

  private final MapboxApiService mapboxApiService;

  private final SqlArrayService sqlArrayService;

  private final UserPositionService userPositionService;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public List<Project> getProjectsForProcess(Long processId) {
    User user = securityService.getCurrentUser();
    return sqlCache.queryBySql(
      ProjectQuery.getAllForCompanyProcess,
        ImmutableMap.of("companyId", user.getCompanyId(), "processId", processId),
        Project.class);
  }

  public Long getProjectIdByProjectProcessStepId(Long projectProcessStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    return sqlCache.queryForObjectBySql(
      ProjectQuery.getProjectIdByProjectProcessStepId, params, Long.class);
  }

  public List<Long> getDistinctProjectIdsByPpsIds(List<Long> ppsIds) {
    HashMap<String, Object> params = new HashMap<>();
    try {
      params.put("ppsIds", sqlArrayService.createSqlArrayOfType("int", ppsIds));
      List<Long> results = sqlCache.queryBySql(ProjectQuery.getProjectIdsByPpsIds, params, new SingleColumnRowMapper<>(Long.class));
      return results;
    } catch (SQLException e) {
      log.error("PROJECT: error retrieving project ids for ppsIds: {}", e.getMessage());
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST, "Unknown Error Occurred", new Exception());
    }
  }

  public Long getProjectIdByProjectProcessStepEventId(Long projectProcessStepEventId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepEventId", projectProcessStepEventId);
    return sqlCache.queryForObjectBySql(
      ProjectQuery.getProjectIdByProjectProcessStepEventId, params, Long.class);
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
        return sqlCache.queryBySql(
          ProjectQuery.getProjectsInGeoAreaDownline, params, ProjectDensityResult.class);
      } else {
        params.put("searchTypeId", null == search.getSearchTypeId() ? 1 : search.getSearchTypeId());
        return sqlCache.queryBySql(ProjectQuery.getProjectsInGeoArea, params, ProjectDensityResult.class);
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
    Boolean viewCustom = false;

    if ((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view")))
        || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewCustom =
          securityService.userHasFeatureAccessLevel(
              user.getId(),
              user.getCompanyId(),
              user.getHighestCompanyId(),
              "PROJECTS",
              List.of("VIEW_CUSTOM"));
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

    String searchSql = ProjectQuery.searchByOwner;
    if (viewCustom) {
      searchSql = ProjectQuery.searchDownline;
    } else if (viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) {
      searchSql = ProjectQuery.search;
    }

    List<Project> projects =
        sqlCache.queryBySql(searchSql, params, new ProjectMapper<>(Project.class, om));

    int total = 10000;
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
    Boolean viewCustom = false;

    if ((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view")))
        || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewCustom =
          securityService.userHasFeatureAccessLevel(
              user.getId(),
              user.getCompanyId(),
              user.getHighestCompanyId(),
              "PROJECTS",
              List.of("VIEW_CUSTOM"));
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());
    params.put("viewCustom", viewCustom);

    String searchSql = ProjectQuery.countsByStatusByUser;
    if (viewAll
        && (null == overrideType
            || (!overrideType.equalsIgnoreCase("view")
                && !overrideType.equalsIgnoreCase("downline")))) {
      searchSql = ProjectQuery.countsByStatus;
    }

    List<ProjectStatusCount> results =
        sqlCache.queryBySql(searchSql, params, ProjectStatusCount.class);

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
    Optional<Project> proj = sqlCache.getBySql(ProjectQuery.existsInHierarchy, params, Project.class);
    return proj.isPresent();
  }

  // i tried to genericize this but it is still pretty specific to only brs.
  public Boolean projectExists(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    Optional<Project> proj = sqlCache.getBySql(ProjectQuery.exists, params, Project.class);
    return proj.isPresent();
  }

  public List<ProjectStatusField> getStatusFieldsByProject(Long projectId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("projectId", projectId);

    List<ProjectStatusField> results = sqlCache.queryBySql(ProjectQuery.getStatusFieldsByProject, params, new ProjectStatusFieldMapper<>(ProjectStatusField.class, om));

    return results;
  }

  public Optional<Project> getProject(Long projectId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = ImmutableMap.of("projectId", projectId, "companyId", user.getCompanyId(), "isParent", user.isParentCompany(), "parentCompanyId", user.getHighestParentCompanyId());
      Optional<Project> result = sqlCache.getBySql(ProjectQuery.get, params, new ProjectMapper<>(Project.class, om));
      if (result.isPresent()) {

        if(result.get().getStatusReadOnly()) {
          boolean statusWhiteListed = false;
          boolean statusAllowFlag = result.get().getStatusReadOnlyAllow();

          //Checks if the user's position is in the whitelist
          for (int x = 0; x < result.get().getStatusReadOnlyWhiteListedPositions().size(); x++) {
            for(int z = 0; z < user.getUserPositions().size(); z++) {
              if (result.get().getStatusReadOnlyWhiteListedPositions().get(x).getPositionId().equals(user.getUserPositions().get(z).getPositionId())) {
                statusWhiteListed = true;
              }
            }
          }

          //If the flag is set to deny, flip the whitelist to be a deny list
          if (!statusAllowFlag) {
            statusWhiteListed = !statusWhiteListed;
          }
          result.get().getStatusReadOnlyWhiteListedPositions().clear();
          result.get().setStatusReadOnly(!statusWhiteListed);
        }
        if(result.get().getOwnerReadOnly()) {
          boolean ownerWhiteListed = false;
          boolean ownerAllowFlag = result.get().getOwnerReadOnlyAllow();

          //Checks if the user's position is in the whitelist
          for (int x = 0; x < result.get().getOwnerReadOnlyWhiteListedPositions().size(); x++) {
            for(int z = 0; z < user.getUserPositions().size(); z++) {
              if (result.get().getOwnerReadOnlyWhiteListedPositions().get(x).getPositionId().equals(user.getUserPositions().get(z).getPositionId())) {
                ownerWhiteListed = true;
              }
            }
          }

          //If the flag is set to deny, flip the whitelist to be a deny list
          if (!ownerAllowFlag) {
            ownerWhiteListed = !ownerWhiteListed;
          }
          result.get().getOwnerReadOnlyWhiteListedPositions().clear();
          result.get().setOwnerReadOnly(!ownerWhiteListed);
        }

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

    sqlCache.updateBySql(ProjectQuery.delete, params);
  }

  public List<Owner> getOwners() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    return sqlCache.queryBySql(
      ProjectQuery.getOwners,
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

      final var latLongAndTimezone = mapboxApiService.getLatLongAndTimezone(project.getStreet1(), project.getCity(), project.getState(), project.getPostalCode());
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

    sqlCache.updateBySql(ProjectQuery.update, params);
  }

  public void updateProjectOwner(Long projectId, Owner owner) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", projectId);
    params.put("modifiedById", currentUser.trueUserId());
    params.put("ownerUserPositionId", owner.getUserPositionId());

    sqlCache.updateBySql(ProjectQuery.updateOwner, params);
  }

  public Optional<Project> insertProject(Long contactId, Long processId, Contact contact, Boolean saveAddress) throws Exception {
    User user = securityService.getCurrentUser();

    if (null != contactId && null != processId) {
      // Get active company project status type so new projects can have an active status
      CompanyProjectStatusType companyStatusType =
          projectStatusService.getDefaultCompanyProjectStatusType(contact.getCompanyId());
      Long companyStatusTypeId = (companyStatusType != null) ? companyStatusType.getId() : null;

      HashMap<String, Object> params = new HashMap<>();
      params.put("contactId", contactId);
      params.put("createdById", user.trueUserId());
      params.put("projectName", CleanString.replaceApostrophe(contact.getFullName()));
      params.put("processId", processId);
      //only save address fields if contact is in an active state
      params.put("street1", saveAddress ? contact.getStreet1() : null);
      params.put("city", saveAddress ? contact.getCity() : null);
      params.put("companyStateId", saveAddress ? contact.getCompanyStateId() : null);
      params.put("companyCountryId", saveAddress ? contact.getCompanyCountryId() : null);
      params.put("postalCode", saveAddress ? contact.getPostalCode() : null);
      params.put("companyProjectStatusTypeId", companyStatusTypeId);

      // with my most recent changes the contact should already have a valid lat/long if the address was valid
      // we only insert the lat/long/timezone stuff if the contact is in an active State, otherwise they will have to update the project with a valid address
      if(saveAddress) {
        params.put("latitude", contact.getLatitude());
        params.put("longitude", contact.getLongitude());
        String timezone = null;
        if (null != contact.getLatitude() && null != contact.getLongitude()) {
          // if we have a lat/long then attempt to load the timezone
          try {
            timezone = mapboxApiService.getTimezone(contact.getLatitude(), contact.getLongitude());
          } catch (Exception e) {
            //do nothing because the getTimezone function already logged this error
          }
        }
        params.put("timezone", timezone);
      } else {
        params.put("latitude", null);
        params.put("longitude", null);
        params.put("timezone", null);
      }

      Long id = sqlCache.updateBySqlReturningId(ProjectQuery.insert, params, "id").longValue();
      return getProject(id);
    } else {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST,
          "Contact ID and Process ID are required to add a project.",
          new Exception());
    }
  }

  public List<Attachment> getAttachments(Long projectId, Boolean isMobile, Boolean linked) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("linked", linked);
    params.put("companyId", currentUser.getCompanyId());
    // Get project attachments
    List<Attachment> attachments =
        sqlCache.queryBySql(ProjectQuery.getAttachments, params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(
        attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  public List<Attachment> getCombinedAttachments(Long projectId, Long ppsId, Long ppsEventId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("ppsId", ppsId);
    params.put("ppsEventId", ppsEventId);
    params.put("companyId", currentUser.getCompanyId());
    // Get project attachments
    List<Attachment> attachments =
      sqlCache.queryBySql(ProjectQuery.getCombinedAttachments, params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(
      attachments, storageBucket, false);
  }

  public void linkAttachment(Long projectId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("attachmentId", attachmentId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sql = ProjectQuery.linkAttachment;
    if(!doLink) {
      sql = ProjectQuery.unlinkAttachment;
    }
    sqlCache.updateBySql(sql, params);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped
  // code right now and I hate it
  public Attachment addAttachment(MultipartFile file, @NonNull Long projectId, Long attachmentTypeId, String displayName)
      throws IOException {
    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }
    return addAttachment(projectId, attachmentTypeId, file.getSize(), file.getContentType(), file.getOriginalFilename(), new ByteArrayInputStream(file.getBytes()), displayName);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(@NonNull Long projectId, @NonNull Long attachmentTypeId, Long contentLength, String contentType, String filename, InputStream inputStream, String displayName){
    User currentUser = securityService.getCurrentUser();

    // had to change this so that a parent looking at a child project could still see project
    // statuses
    Long companyId = sqlCache.queryForObjectBySql(ProjectQuery.getCompanyId, Map.of("projectId", projectId), Long.class);

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
    params.put("displayName", displayName.length() > 100 ? displayName.substring(0, 100) : displayName);
    params.put("attachmentTypeId", attachmentTypeId);

    Long attachmentId = sqlCache.updateBySqlReturningId(AttachmentQuery.create, params, "id").longValue();

    params.clear();
    params.put("projectId", projectId);
    params.put("attachmentId", attachmentId);
    params.put("linked", false);
    params.put("createdById", currentUser.trueUserId());

    sqlCache.updateBySql(ProjectQuery.addAttachment, params);

    return attachmentService.findById(attachmentId);
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
    return sqlCache.queryBySql(
      ProjectQuery.getProcessStepsByProjectId,
        params,
        new ProjectProcessStepService.ProjectProcessStepMapper<>(ProjectProcessStep.class, om));
  }

  public List<ProjectWorkQueueHistory> getWorkQueueHistoryByProjectId(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("companyId", user.getCompanyId());

    return sqlCache.queryBySql(
      ProjectQuery.getWorkQueueHistoryByProjectId,
      params,
      ProjectWorkQueueHistory.class);
  }

  public List<ProjectProcessStepEvent> getEventsByProjectId(Long projectId, Long statusTypeId) {
    User user = securityService.getCurrentUser();
    Boolean systemAdmin = user.getHighestCompanyId() == 1L;
    List<Long> userPositionIds = userPositionService.getAllActiveUserPositionIds(user);
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("statusTypeId", statusTypeId);
    params.put("systemAdmin", systemAdmin);
    params.put("userPositions", userPositionIds);
    params.put("companyId", user.getCompanyId());
    List<ProjectProcessStepEvent> processStepEvents = sqlCache.queryBySql(ProjectQuery.getEventsByProjectId, params, new ProjectProcessStepEventService.PpsEventMapper<>(ProjectProcessStepEvent.class, om));

      for(ProjectProcessStepEvent event: processStepEvents){
          if(event.getCustomFieldDisplayValueGroupAssignmentId() != null) {
              HashMap<String, Object> moreParams = new HashMap<>();
              moreParams.put("objectTypeId", 6); //6 is the event object type
              moreParams.put("cfgaId", event.getCustomFieldDisplayValueGroupAssignmentId());
              moreParams.put("primaryId", event.getId());
              List<CustomFieldValueDisplay> cfvs = sqlCache.queryBySql(ProjectProcessStepQuery.getOneCustomFieldValue, moreParams, new CustomFieldValueDisplayMapper(CustomFieldValueDisplay.class, om));
              event.setCustomFieldDisplayValue(cfvs.get(0));
          }
      }
    if(!user.isSystemAdmin()){
      for(int x = 0; x < processStepEvents.size(); x++) {
        if(!processStepEvents.get(x).getEventHiddenAllow() && (processStepEvents.get(x).getEventHiddenWhiteListedPositions() == null || processStepEvents.get(x).getEventHiddenWhiteListedPositions().size() == 0)){
          processStepEvents.get(x).setEventHidden(false);
        }
        if(processStepEvents.get(x).getEventHidden()) {
          boolean whiteListed = false;
          boolean allowFlag = processStepEvents.get(x).getEventHiddenAllow();

          //Checks if the user's position is in the whitelist
          for (int y = 0; y < processStepEvents.get(x).getEventHiddenWhiteListedPositions().size(); y++) {
            for(int z = 0; z < user.getUserPositions().size(); z++) {
              if (processStepEvents.get(x).getEventHiddenWhiteListedPositions().get(y).getPositionId().equals(user.getUserPositions().get(z).getPositionId())) {
                whiteListed = true;
              }
            }
          }

          //If the flag is set to deny, flip the whitelist to be a deny list
          if (!allowFlag) {
            whiteListed = !whiteListed;
          }


          processStepEvents.get(x).getEventHiddenWhiteListedPositions().clear();
          processStepEvents.get(x).setEventHidden(!whiteListed);
          if(!whiteListed){
            processStepEvents.remove(x);
            x--;
          }

        }

      }
    }

    return processStepEvents;
  }

  public CommunicationController.ProjectDetails getProjectDetailTemplateFields(Long projectId) {
    return sqlCache
      .getBySql(ProjectQuery.getProjectDetailTemplateFields, Map.of("projectId", projectId), CommunicationController.ProjectDetails.class)
      .orElse(null);
  }

  public Optional<String> getInstallationScopeOfWork(Long projectId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("companyId", user.getCompanyId());
    return
      sqlCache.getBySql(
        ProjectQuery.getProjectInstallationScopeOfWork,
        params,
        new SingleColumnRowMapper<>(String.class));
  }

  public Optional<Project> updateStatus(Long projectId, Long companyProjectStatusTypeId) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.updateBySql(
      ProjectStatusQuery.updateStatus,
      Map.of("projectId", projectId,
        "companyProjectStatusTypeId", companyProjectStatusTypeId,
        "userId", currentUser.trueUserId()));
    return getStatus(projectId);
  }

  public Optional<Project> getStatus(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    return sqlCache.getBySql(ProjectStatusQuery.getStatusDetails, params, Project.class);
  }

  public String generateReport(String query) {
    User user = securityService.getCurrentUser();
    List<Map<String, Object>> projects =
        sqlCache.queryBySql(
          ProjectQuery.generateReport,
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

      TypeReference<List<ProjectTag>> projectTagsRef =
        new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "tags",
        new JsonCollectionDeserializer(projectTagsRef, objectMapper));

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


    private static class ProjectStatusFieldMapper<T> extends BeanPropertyRowMapper<T> {
      public final ObjectMapper objectMapper;

      public ProjectStatusFieldMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
        super(mappedClass);
        this.objectMapper = objectMapper;
      }

      @Override
      protected void initBeanWrapper(BeanWrapper bw) {
        TypeReference<List<ProjectStatusField.AssignedField>> assignedFieldsRef =
          new TypeReference<>() {};
        bw.registerCustomEditor(
          List.class,
          "assignedFields",
          new JsonCollectionDeserializer(assignedFieldsRef, objectMapper));

      }
    }

}
