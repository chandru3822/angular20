package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.controllers.CommunicationController;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.project.*;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStep;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.queries.ProjectProcessStepQuery;
import com.albatross.api.v1.flow.queries.ProjectQuery;
import com.albatross.api.v1.flow.queries.ProjectStatusQuery;
import com.albatross.api.v1.flow.services.mapbox.MapboxApiService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
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
  private final SqlCacheRO sqlCacheRO;
  private final SecurityService securityService;
  private final ProjectStatusService projectStatusService;
  private final AttachmentService attachmentService;
  private final ObjectMapper om;
  private final MapboxApiService mapboxApiService;
  private final SqlArrayService sqlArrayService;
  private final UserPositionService userPositionService;
  private final SystemListService systemListService;

  public List<Project> getProjectsForProcess(Long processId) {
    User user = securityService.getCurrentUser();
    return sqlCache.queryBySql(
      ProjectQuery.getAllForCompanyProcess,
      Map.of("companyId", user.getCompanyId(), "processId", processId),
      Project.class);
  }

  public Long getProjectIdByProjectProcessStepId(Long projectProcessStepId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    return sqlCache.queryForObjectBySql(
      ProjectQuery.getProjectIdByProjectProcessStepId, params, Long.class);
  }

  public List<Long> getDistinctProjectIdsByPpsIds(List<Long> ppsIds) {
    Map<String, Object> params = new HashMap<>();
    try {
      params.put("ppsIds", sqlArrayService.createSqlArrayOfType("int", ppsIds));
      return sqlCache.queryBySql(ProjectQuery.getProjectIdsByPpsIds, params, new SingleColumnRowMapper<>(Long.class));
    } catch (SQLException e) {
      log.error("PROJECT: error retrieving project ids for ppsIds: {}", e.getMessage());
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST, "Unknown Error Occurred", new Exception());
    }
  }

  public Long getProjectIdByProjectProcessStepEventId(Long projectProcessStepEventId) {
    Map<String, Object> params = new HashMap<>();
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
      Map<String, Object> params = new HashMap<>();
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
    Boolean includeCommissionDetails,
    Pageable pageable,
    String searchColumn) {
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

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("companyProjectStatusTypeId", companyProjectStatusTypeId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("sortColumn", sortColumn);
    params.put("sortDirection", sortDirection);
    params.put("includeCommissionDetails", includeCommissionDetails != null ? includeCommissionDetails : false);
    params.put("userId", user.getId());
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());
    params.put("searchColumn", searchColumn);
    params.put("partnerIds", user.getPartnerIds());

    String searchSql = ProjectQuery.searchByOwner;
    String searchCountSql = ProjectQuery.searchCountByOwner;
    if (viewCustom) {
      searchSql = ProjectQuery.searchDownline;
      searchCountSql = ProjectQuery.searchCountDownline;
    } else if (viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) {
      searchSql = ProjectQuery.search;
      searchCountSql = ProjectQuery.searchCount;
    }

    List<Project> projects;
    // move project searching to replica to help balance DB load
    if (searchSql.equals(ProjectQuery.search)) {
        projects = sqlCacheRO.queryBySql(searchSql, params, new ProjectMapper<>(Project.class, om));
    } else {
        projects = sqlCache.queryBySql(searchSql, params, new ProjectMapper<>(Project.class, om));
    }

    Long totalCount = 10000L;
    // Count query is executed only if filter is applied.
    if (StringUtils.hasText(query) && StringUtils.hasText(searchColumn)) {
      totalCount = sqlCacheRO.queryForObjectBySql(searchCountSql, params, Long.class);
    }
    return new PageImpl<>(projects, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), totalCount);
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

    Map<String, Object> params = new HashMap<>();
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

    return sqlCache.queryBySql(searchSql, params, new ProjectStatusCountMapper<>(ProjectStatusCount.class, om));
  }

  // i tried to genericize this but it is still pretty specific to only brs.
  public Boolean projectExistsInHierarchy(Long projectId, Long parentCompanyId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("parentCompanyId", parentCompanyId);
    Optional<Project> proj = sqlCache.getBySql(ProjectQuery.existsInHierarchy, params, Project.class);
    return proj.isPresent();
  }

  // i tried to genericize this but it is still pretty specific to only brs.
  public Boolean projectExists(Long projectId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    Optional<Project> proj = sqlCache.getBySql(ProjectQuery.exists, params, Project.class);
    return proj.isPresent();
  }

  public List<ProjectStatusField> getStatusFieldsByProject(Long projectId, Long companyProjectStatusTypeId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("projectId", projectId);
    params.put("companyProjectStatusTypeId", companyProjectStatusTypeId);

    return sqlCache.queryBySql(ProjectQuery.getStatusFieldsByProject, params, new ProjectStatusFieldMapper<>(ProjectStatusField.class, om));
  }

//  @Data
//  public static class ChildField {
//    Long projectId, customFieldGroupAssignmentId;
//    String value;
//  }

  public void saveProjectChildrenDetails(Long parentProjectId, String fields) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("parentProjectId", parentProjectId);
    params.put("fields", fields);
    params.put("userId", user.trueUserId());

    sqlCache.queryBySql(ProjectQuery.saveProjectChildrenDetails, params, String.class);
  }

  public String getProjectChildren(Long parentProjectId, Boolean isSimple) {
    Map<String, Object> params = new HashMap<>();
    params.put("parentProjectId", parentProjectId);

    String sql = isSimple ? ProjectQuery.getChildrenSimple : ProjectQuery.getChildrenWithFields;

    String results = sqlCache.queryForObjectBySql(sql, params, String.class);

    return results;
  }

  public List<ChildProjectHeader> getProjectChildrenHeaders() {
    List<ChildProjectHeader> results = sqlCache.queryBySql(ProjectQuery.getChildrenHeaders, Collections.emptyMap(), new ChildProjectHeaderMapper<>(ChildProjectHeader.class, om));

    return results;
  }

  public void updateProjectContactId(Long projectId, Long contactId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("contactId", contactId);
    params.put("userId", user.trueUserId());

    sqlCache.updateBySql(ProjectQuery.updateProjectContactId, params);
  }


  public void resetProjectContactToParent(Long projectId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("userId", user.trueUserId());

    sqlCache.updateBySql(ProjectQuery.resetProjectContactToParent, params);
  }

  public Optional<Project> getProject(Long projectId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = Map.of(
      "projectId", projectId,
      "companyId", user.getCompanyId(),
      "isParent", user.isParentCompany(),
      "parentCompanyId", user.getHighestParentCompanyId(),
      "partnerIds", (user.getPartnerIds() == null) ? List.of() : user.getPartnerIds()
    );
    // for now I limit the # of child projects returned to 3. the frontend only shows 3 and if they want to see more they load via a different query
    // there can be hundreds of child projects
    Optional<Project> result = sqlCache.getBySql(ProjectQuery.get, params, new ProjectMapper<>(Project.class, om));
    if (result.isPresent()) {

      if (result.get().getStatusReadOnly()) {
        boolean statusWhiteListed = false;
        boolean statusAllowFlag = result.get().getStatusReadOnlyAllow();

        //Checks if the user's position is in the whitelist
        for (int x = 0; x < result.get().getStatusReadOnlyWhiteListedPositions().size(); x++) {
          for (int z = 0; z < user.getUserPositions().size(); z++) {
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
      if (result.get().getOwnerReadOnly()) {
        boolean ownerWhiteListed = false;
        boolean ownerAllowFlag = result.get().getOwnerReadOnlyAllow();

        //Checks if the user's position is in the whitelist
        for (int x = 0; x < result.get().getOwnerReadOnlyWhiteListedPositions().size(); x++) {
          for (int z = 0; z < user.getUserPositions().size(); z++) {
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

    Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("projectId", projectId);

    sqlCache.updateBySql(ProjectQuery.delete, params);
  }

  public List<Owner> getOwners() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    return sqlCache.queryBySql(
      ProjectQuery.getOwners,
      Map.of(
        "companyId", user.getCompanyId(),
        "isParent", isParent,
        "parentCompanyId", user.getHighestParentCompanyId()),
      Owner.class);
  }

  public void updateProject(Project project) throws Exception {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", project.getId());
    params.put("street1", CleanString.replaceApostrophesAndRemoveNBSP(project.getStreet1()));
    params.put("projectName", CleanString.replaceApostrophesAndRemoveNBSP(project.getProjectName()));
    params.put("city", CleanString.replaceApostrophesAndRemoveNBSP(project.getCity()));
    params.put("companyStateId", project.getCompanyStateId());
    params.put("postalCode", CleanString.replaceApostrophesAndRemoveNBSP(project.getPostalCode()));
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

  public void updateProjectFromContact(Contact contact, Boolean updateProjectName, Boolean updateProjectAddress) throws Exception {
    User currentUser = securityService.getCurrentUser();
    if (updateProjectName != null && updateProjectName && !contact.getProjects().isEmpty()
        && !contact
      .getProjects()
      .getFirst()
      .getProjectName()
      .equals(contact.getFirstName().trim() + " " + contact.getLastName().trim())) {
      sqlCache.updateBySql(ProjectQuery.updateNameByContactId,
        Map.of(
          "contactId",
          contact.getId(),
          "name",
          contact.getFirstName().trim() + " " + contact.getLastName().trim(),
          "userId",
          currentUser.trueUserId()));
    }
    if (null != updateProjectAddress && updateProjectAddress && !contact.getProjects().isEmpty()) {

      Map<String, Object> params = new HashMap<>();
      params.put("contactId", contact.getId());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("street1", contact.getStreet1());
      params.put("city", contact.getCity());
      params.put("companyStateId", contact.getCompanyStateId());
      params.put("postalCode", contact.getPostalCode());
      params.put("companyCountryId", contact.getCompanyCountryId());
      params.put("latitude", contact.getLatitude());//this should have already been updated when the contact was updated
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
      sqlCache.updateBySql(ProjectQuery.updateAddressByContactId, params);
    }
  }

  public void updateProjectOwner(Long projectId, Owner owner) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", projectId);
    params.put("modifiedById", currentUser.trueUserId());
    params.put("ownerUserPositionId", owner.getUserPositionId());

    sqlCache.updateBySql(ProjectQuery.updateOwner, params);
  }

  private Long getObjectCategoryFromProcessId(Long processId){
    Map<String, Object> params = new HashMap<>();
    params.put("processId", processId);

    Long objectCategoryId = sqlCache.queryForObjectBySql(ProjectQuery.getObjectTypeByProcess, params, Long.class);
    return objectCategoryId;
  }

  @Transactional
  public Optional<Project> insertProject(Long contactId, Long processId, Contact contact, Boolean saveAddress, Long ownerUserPositionId) throws Exception {
    User user = securityService.getCurrentUser();

    if (null != contactId && null != processId) {

      Long objectCategoryId = getObjectCategoryFromProcessId(processId);

      // Get active company project status type so new projects can have an active status
      CompanyProjectStatusType companyStatusType =
        projectStatusService.getDefaultCompanyProjectStatusType(contact.getCompanyId());
      Long companyStatusTypeId = (companyStatusType != null) ? companyStatusType.getId() : null;

      Map<String, Object> params = new HashMap<>();
      params.put("contactId", contactId);
      params.put("createdById", user.trueUserId());
      params.put("projectName", CleanString.replaceApostrophesAndRemoveNBSP(contact.getFullName()));
      params.put("processId", processId);
      //only save address fields if contact is in an active state
      params.put("street1", saveAddress ? contact.getStreet1() : null);
      params.put("city", saveAddress ? contact.getCity() : null);
      params.put("companyStateId", saveAddress ? contact.getCompanyStateId() : null);
      params.put("companyCountryId", saveAddress ? contact.getCompanyCountryId() : null);
      params.put("postalCode", saveAddress ? contact.getPostalCode() : null);
      params.put("companyProjectStatusTypeId", companyStatusTypeId);
      params.put("userPositionId", ownerUserPositionId);
      params.put("objectCategoryId", objectCategoryId);

      // with my most recent changes the contact should already have a valid lat/long if the address was valid
      // we only insert the lat/long/timezone stuff if the contact is in an active State, otherwise they will have to update the project with a valid address
      if (saveAddress) {
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
      addPartnerIds(id);

      return getProject(id);
    } else {
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "Contact ID and Process ID are required to add a project.",
        new Exception());
    }
  }


  // Adds project partner IDs belonging to orgs of the user's positions.
  // This is here instead of the cfvService due to circular dependencies.
  private void addPartnerIds(Long projectId) throws SQLException {
    var user = securityService.getCurrentUser();
    if (user.getPartnerIds() != null && !user.getPartnerIds().isEmpty()) {
      var params = new HashMap<String, Object>();
      //default values
      params.put("dateValue", null);
      params.put("textValue", null);
      params.put("timestampValue", null);
      params.put("booleanValue", null);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("richTextValue", null);
      params.put("jsonValue", null);

      params.put("intArrayValue", sqlArrayService.createSqlArrayOfType("int", user.getPartnerIds()));
      params.put("customFieldGroupAssignmentId", 27972L);
      params.put("userId", user.trueUserId());
      params.put("sourceId", projectId);
      sqlCache.updateBySql(ObjectType.PROJECT.upsertCustomFieldValueQuery, params);
    }
  }

  public List<Attachment> getAttachments(Long projectId, Boolean isMobile, Boolean linked) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("linked", linked);
    params.put("companyId", currentUser.getCompanyId());
    // Get project attachments
    List<Attachment> attachments =
      sqlCache.queryBySql(ProjectQuery.getAttachments, params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, null != isMobile ? isMobile : false);
  }

  public List<Attachment> getCombinedAttachments(Long projectId, Long ppsId, Long ppsEventId) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("ppsId", ppsId);
    params.put("ppsEventId", ppsEventId);
    params.put("companyId", currentUser.getCompanyId());
    // Get project attachments
    List<Attachment> attachments =
      sqlCache.queryBySql(ProjectQuery.getCombinedAttachments, params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, false);
  }

  public void linkAttachment(Long projectId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("attachmentId", attachmentId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sql = ProjectQuery.linkAttachment;
    if (!doLink) {
      sql = ProjectQuery.unlinkAttachment;
    }
    sqlCache.updateBySql(sql, params);
  }

  public List<Attachment> addAttachments(MultipartFile[] files, Long projectId, Long attachmentTypeId) throws IOException {
    List<Attachment> results = new ArrayList<>();
    Attachment a;
    for (MultipartFile file : files) {
      a = addAttachment(file, projectId, attachmentTypeId, file.getOriginalFilename());
      results.add(a);
    }

    return results;
  }

  public Attachment addAttachment(MultipartFile file, @NonNull Long projectId, Long attachmentTypeId, String displayName)
    throws IOException {
    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }
    return addAttachment(projectId, attachmentTypeId, file.getSize(), file.getContentType(), file.getOriginalFilename(), new ByteArrayInputStream(file.getBytes()), displayName);
  }

  public Attachment addAttachment(@NonNull Long projectId, @NonNull Long attachmentTypeId, Long contentLength, String contentType, String filename, InputStream inputStream, String displayName) {
    User currentUser = securityService.getCurrentUser();

    // had to change this so that a parent looking at a child project could still see project statuses
    Long companyId = sqlCache.queryForObjectBySql(ProjectQuery.getCompanyId, Map.of("projectId", projectId), Long.class);

    Attachment attachment = attachmentService.create(inputStream, null, attachmentTypeId, displayName, filename, contentType, contentLength, false, companyId);

    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("attachmentId", attachment.getId());
    params.put("linked", false);
    params.put("createdById", currentUser.trueUserId());

    sqlCache.updateBySql(ProjectQuery.addAttachment, params);

    return attachment;
  }

  public List<ProjectProcessStep> getProcessStepsByProjectId(Long projectId, Long statusTypeId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Map<String, Object> params = new HashMap<>();
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
    Map<String, Object> params = new HashMap<>();
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
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("statusTypeId", statusTypeId);
    params.put("systemAdmin", systemAdmin);
    params.put("userPositions", userPositionIds);
    params.put("companyId", user.getCompanyId());
    List<ProjectProcessStepEvent> processStepEvents = sqlCache.queryBySql(ProjectQuery.getEventsByProjectId, params, new ProjectProcessStepEventService.PpsEventMapper<>(ProjectProcessStepEvent.class, om));

    for (ProjectProcessStepEvent event : processStepEvents) {
      if (event.getCustomFieldDisplayValueGroupAssignmentId() != null) {
        Map<String, Object> moreParams = new HashMap<>();
        moreParams.put("objectTypeId", 6); //6 is the event object type
        moreParams.put("cfgaId", event.getCustomFieldDisplayValueGroupAssignmentId());
        moreParams.put("primaryId", event.getId());
        List<CustomFieldValueDisplay> cfvs = sqlCache.queryBySql(ProjectProcessStepQuery.getOneCustomFieldValue, moreParams, new CustomFieldValueDisplayMapper(CustomFieldValueDisplay.class, om));
        event.setCustomFieldDisplayValue(cfvs.getFirst());
      }
    }
    if (!user.isSystemAdmin()) {
      for (int x = 0; x < processStepEvents.size(); x++) {
        if (!processStepEvents.get(x).getEventHiddenAllow() && (processStepEvents.get(x).getEventHiddenWhiteListedPositions() == null || processStepEvents.get(x).getEventHiddenWhiteListedPositions().size() == 0)) {
          processStepEvents.get(x).setEventHidden(false);
        }
        if (processStepEvents.get(x).getEventHidden()) {
          boolean whiteListed = false;
          boolean allowFlag = processStepEvents.get(x).getEventHiddenAllow();

          //Checks if the user's position is in the whitelist
          for (int y = 0; y < processStepEvents.get(x).getEventHiddenWhiteListedPositions().size(); y++) {
            for (int z = 0; z < user.getUserPositions().size(); z++) {
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
          if (!whiteListed) {
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
    Map<String, Object> params = new HashMap<>();
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
    Map<String, Object> params = new HashMap<>();
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
      TypeReference<Contact> contactRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        Object.class, "contact", new JsonCollectionDeserializer(contactRef, objectMapper));

      TypeReference<Owner> ownerRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        Object.class, "owner", new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<Project> parentRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        Object.class, "parentProject", new JsonCollectionDeserializer(parentRef, objectMapper));

      TypeReference<List<Project>> childProjectsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "childProjects", new JsonCollectionDeserializer(childProjectsRef, objectMapper));

      TypeReference<List<ChildCompanyProcess>> childCompanyProcessesRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "childCompanyProcesses", new JsonCollectionDeserializer(childCompanyProcessesRef, objectMapper));

      TypeReference<List<ProjectTag>> projectTagsRef =
        new TypeReference<>() {
        };
      bw.registerCustomEditor(
        List.class,
        "tags",
        new JsonCollectionDeserializer(projectTagsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> statusReadOnlyWhiteListedPositionsRef =
        new TypeReference<>() {
        };
      bw.registerCustomEditor(
        List.class,
        "statusReadOnlyWhiteListedPositions",
        new JsonCollectionDeserializer(statusReadOnlyWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> ownerReadOnlyWhiteListedPositionsRef =
        new TypeReference<>() {
        };
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
        new TypeReference<>() {
        };
      bw.registerCustomEditor(
        List.class,
        "assignedFields",
        new JsonCollectionDeserializer(assignedFieldsRef, objectMapper));

    }
  }

  private static class ChildProjectHeaderMapper<T> extends BeanPropertyRowMapper<T> {
    public final ObjectMapper objectMapper;

    public ChildProjectHeaderMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "systemListOptionIds", new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));

      TypeReference<List<ListOfValue>> listOfValuesRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "listOfValues", new JsonCollectionDeserializer(listOfValuesRef, objectMapper));

    }
  }


  private static class ChildProjectMapper<T> extends BeanPropertyRowMapper<T> {
    public final ObjectMapper objectMapper;

    public ChildProjectMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldValue>> customFieldValuesRef = new TypeReference<>() {};

      bw.registerCustomEditor(
        List.class,
        "customFieldValues",
        new JsonCollectionDeserializer(customFieldValuesRef, objectMapper));

    }
  }

  private static class ProjectStatusCountMapper<T> extends BeanPropertyRowMapper<T> {
    public final ObjectMapper objectMapper;

    public ProjectStatusCountMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<ProjectCommissions> commissionsRef = new TypeReference<>() {
      };

      bw.registerCustomEditor(
        Object.class, "commissions", new JsonCollectionDeserializer(commissionsRef, objectMapper));

    }
  }

	/**
	 * @param projectId
	 * @param query
	 * @param pageable
	 * @return
	 */
	public Page<Project> getChildProjectDetails(Long projectId, String query, Pageable pageable) {
		Map<String, Object> params = Map.of("projectId", projectId, "query", query, "offset", pageable.getOffset(),
				"limit", pageable.getPageSize());
		List<Project> result = sqlCache.queryBySql(ProjectQuery.getChildProject, params,
				new ProjectMapper<>(Project.class, om));
		Long totalCount = 10000L;
		if (StringUtils.hasText(query) && StringUtils.hasText(query)) {
			totalCount = sqlCacheRO.queryForObjectBySql(ProjectQuery.getChildProjectCount, params, Long.class);
		}
		return new PageImpl<>(result.get(0).getChildProjects(), PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), totalCount);
	}
}
