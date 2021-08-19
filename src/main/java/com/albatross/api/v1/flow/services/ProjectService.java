package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.LocationUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.ImmutableMap;
import com.mapbox.geojson.Feature;
import com.mapbox.geojson.Point;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.function.ObjLongConsumer;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectService {

  private final SqlCache sqlCache;

  private final LocationUtils locationUtils;

  private final SecurityService securityService;

  private final AttachmentService attachmentService;

  private final AmazonS3 s3;

  private final ObjectMapper om;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public List<Project> getProjectsForProcess(Long processId) {
    User user = securityService.getCurrentUser();
    return sqlCache.query("project.getAllForCompanyProcess", ImmutableMap.of("companyId", user.getCompanyId() , "processId", processId), Project.class);
  }

  public Long getProjectIdByProjectProcessStepId(Long projectProcessStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    Long projectId = sqlCache.queryForObject("project.getProjectIdByProjectProcessStepId", params, Long.class);
    return projectId;
  }

  public List<Project> getProjectsInGeoArea(DensitySearch search) {
    if(null != search.getUpperBoundLatitude() && null != search.getUpperBoundLongitude() && null != search.getLowerBoundLatitude() && null != search.getLowerBoundLongitude()) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("upperBoundLatitude", search.getUpperBoundLatitude());
      params.put("upperBoundLongitude", search.getUpperBoundLongitude());
      params.put("lowerBoundLatitude", search.getLowerBoundLatitude());
      params.put("lowerBoundLongitude", search.getLowerBoundLongitude());
      params.put("companyProjectStatusTypeIds", search.getCompanyProjectStatusTypeIds());
      List<Project> results = sqlCache.query("project.getProjectsInGeoArea", params, new ProjectMapper<>(Project.class, om));
      return results;
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Bound Parameters", new Exception());
    }
  }

  public Page<Project> searchProjects(String query, Long companyProjectStatusTypeId, String overrideType, String sortColumn, String sortDirection, Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "PROJECTS", List.of("VIEW_ALL"));
    Boolean viewDownline = false;

    if((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewDownline = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "PROJECTS", List.of("VIEW_DOWNLINE"));
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
    if(viewDownline) {
      searchSqlKey = "project.searchDownline";
    } else if (viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) {
      searchSqlKey = "project.search";
    }
//    String countSqlKey = viewAll ? "project.searchCount" : viewDownline ? "project.searchDownlineCount" : "project.searchByOwnerCount";

    List<Project> projects = sqlCache.query(searchSqlKey, params, new ProjectMapper<>(Project.class, om));
//    Integer total = sqlCache.queryForObject(countSqlKey, params, Integer.class);
    Integer total = 10000;
    return new PageImpl<>(projects, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), total);
  }

  public List<ProjectStatusCount> projectCountsByStatus(String overrideType) {
    User user = securityService.getCurrentUser();
    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "PROJECTS", List.of("VIEW_ALL"));
    Boolean viewDownline = false;

    if((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewDownline = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "PROJECTS", List.of("VIEW_DOWNLINE"));
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());
    params.put("viewDownline", viewDownline);

    String searchSqlKey = "project.countsByStatusByUser";
    if(viewAll && (null == overrideType || (!overrideType.equalsIgnoreCase("view") && !overrideType.equalsIgnoreCase("downline")))) {
      searchSqlKey = "project.countsByStatus";
    }
//    String searchSqlKey = viewAll ? "project.countsByStatus" : "project.countsByStatusByUser";

    List<ProjectStatusCount> results = sqlCache.query(searchSqlKey, params, ProjectStatusCount.class);

    for(ProjectStatusCount c : results) {
      // set the icon for the status
      Attachment a = attachmentService.getOneBySourceIdAndType(c.getCompanyProjectStatusTypeId(), 463L);
      c.setIcon(null != a && null != a.getId() ? a : new Attachment());
    }

    return results;
  }

  //i tried to genericize this but it is still pretty specific to only brs.
  public Boolean projectExistsInHierarchy(Long projectId, Long parentCompanyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("parentCompanyId", parentCompanyId);
    Optional<Project> proj = sqlCache.get("project.existsInHierarchy", params, Project.class);
    return proj.isPresent();
  }

  //i tried to genericize this but it is still pretty specific to only brs.
  public Boolean projectExists(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    Optional<Project> proj = sqlCache.get("project.exists", params, Project.class);
    return proj.isPresent();
  }

  public Optional<Project> getProject(Long projectId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    return sqlCache.get("project.get",
      ImmutableMap.of("projectId", projectId,
                      "companyId", user.getCompanyId(),
                      "isParent", isParent,
                      "parentCompanyId", user.getHighestParentCompanyId()),
      new ProjectMapper<>(Project.class, om));
  }

  public void deleteProject(Long projectId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.getId());
    params.put("projectId", projectId);

    sqlCache.update("project.delete", params);
  }

  public List<Owner> getOwners() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    return sqlCache.query("project.getOwners",
      ImmutableMap.of(
                      "companyId", user.getCompanyId(),
                      "isParent", isParent,
                      "parentCompanyId", user.getHighestParentCompanyId()),
      Owner.class);
  }

  public void updateProject(Project project) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", project.getId());
    params.put("street1", project.getStreet1());
    params.put("projectName", CleanString.replaceApostrophe(project.getProjectName()));
    params.put("city", project.getCity());
    params.put("companyStateId", project.getCompanyStateId());
    params.put("postalCode", project.getPostalCode());
    params.put("companyCountryId", project.getCompanyCountryId());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("project.update", params);

    //load coordinates when new project added
    if(null != project.getReloadCoordinates() && project.getReloadCoordinates()) {
      getProjectCoordinates(project, project.getId());
    }
  }

  public void updateProjectOwner(Long projectId, Owner owner) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", projectId);
    params.put("modifiedById", currentUser.getId());
    params.put("ownerUserPositionId", owner.getUserPositionId());

    sqlCache.update("project.updateOwner", params);
  }

  public Optional<Project> insertProject(Long contactId, Long processId, Contact contact) {
    User user = securityService.getCurrentUser();

    if(null != contactId && null != processId) {
      // Get active company project status type so new projects can have an active status
      CompanyProjectStatusType companyStatusType = this.getDefaultCompanyProjectStatusType(contact.getCompanyId());
      Long companyStatusTypeId = (companyStatusType != null) ? companyStatusType.getId() : null;

      HashMap<String, Object> params = new HashMap<>();
      params.put("contactId", contactId);
      params.put("createdById", user.getId());
      params.put("projectName", CleanString.replaceApostrophe(contact.getFullName()));
      params.put("processId", processId);
      params.put("street1", contact.getStreet1());
      params.put("city", contact.getCity());
      params.put("companyStateId", contact.getCompanyStateId());
      params.put("companyCountryId", contact.getCompanyCountryId());
      params.put("postalCode", contact.getPostalCode());
      params.put("companyProjectStatusTypeId", companyStatusTypeId);

      Long id = sqlCache.updateReturningId("project.insert", params, "id").longValue();
      Optional<Project> project = getProject(id);
      //load coordinates when new project added
      project.ifPresent(value -> getProjectCoordinates(value, id));
      return project;
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Contact ID and Process ID are required to add a project.", new Exception());
    }
  }

  public void getProjectCoordinates(Project project, Long id) {
    //when the contact is new or the address changes, need to reload/save their lat/long from mapbox
    String projectAddress = getProjectAddress(project);
    locationUtils.getGeocode(projectAddress, id, new CustomGeoFunction());
  }

  public String getProjectAddress(Project project) {
    StringJoiner sj = new StringJoiner(", ");
    sj.add(project.getStreet1());
    sj.add(project.getCity());
    sj.add(project.getState() + ( null == project.getPostalCode() ? "" : " " + project.getPostalCode() ));

    return sj.toString();
  }

  public List<Attachment> getAttachments(Long projectId, Boolean isMobile) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    // Get project attachments
    List<Attachment> attachments = sqlCache.query("project.getAttachments", params, Attachment.class);
    // Get project process step attachments
    List<Attachment> ppsAttachments = sqlCache.query("projectProcessStep.getProjectProcessStepAttachmentsForProjectId", params, Attachment.class);
    attachments.addAll(ppsAttachments);
    return attachmentService.getAttachmentPresignedUrls(attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long projectId, Long attachmentTypeId) throws IOException {
    User currentUser = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    //had to change this so that a parent looking at a child project could still see project statuses
    HashMap<String, Object> p2 = new HashMap<>();
    p2.put("projectId", projectId);
    Long companyId = sqlCache.queryForObject("project.getCompanyId", p2, Long.class);

    //get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key = String.format( currentUser.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());
    metadata.setCacheControl("public, max-age=31536000");

    PutObjectRequest objectRequest = new PutObjectRequest(storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

    PutObjectResult result = s3.putObject(objectRequest
      .withCannedAcl(CannedAccessControlList.PublicRead));

    String url = s3.getUrl(currentUser.getAwsBucket(), key).toExternalForm();

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", CleanString.cleanFilename(file.getOriginalFilename()));
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("createdById", currentUser.getId());
    params.put("companyId", companyId);
    params.put("attachmentTypeId", attachmentTypeId);

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectId", projectId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", currentUser.getId());

    sqlCache.update("project.addAttachment", params);

    return attachmentService.findById(attachmentId);
  }

  public void updateStatus(Long projectId, Long companyProjectStatusTypeId) {
      sqlCache.update("project.updateStatus", Map.of("projectId", projectId, "companyProjectStatusTypeId", companyProjectStatusTypeId));
  }

  private CompanyProjectStatusType getDefaultCompanyProjectStatusType(Long companyId) {
    return sqlCache.get("project.getDefaultProjectStatusTypeByCompanyId", Map.of("companyId", companyId), CompanyProjectStatusType.class).orElse(null);
  }

  public List<ProjectProcessStep> getProcessStepsByProjectId(Long projectId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    return sqlCache.query("project.getProcessStepsByProjectId",
      ImmutableMap.of("projectId", projectId,
        "companyId", user.getCompanyId(),
        "isParent", isParent,
        "parentCompanyId", user.getHighestParentCompanyId()),
      new ProjectProcessStepService.ProjectProcessStepMapper<>(ProjectProcessStep.class, om));
  }

  public List<ProjectStatusType> getCompanyProjectStatuses(Long projectId) {
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();

    if(null != projectId) {
      //had to change this so that a parent looking at a child project could still see project statuses
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      companyId = sqlCache.queryForObject("project.getCompanyId", params, Long.class);
    }

    // NOTE: this returns COMPANY project statuses...as it should. but don't let it confuse you
    List<ProjectStatusType> results = sqlCache.query("project.getCompanyStatuses",
      ImmutableMap.of("companyId", companyId), ProjectStatusType.class);

    for(ProjectStatusType c : results) {
      // set the icon for the status
      Attachment a = attachmentService.getOneBySourceIdAndType(c.getId(), 463L);
      c.setIcon(null != a && null != a.getId() ? a : new Attachment());
    }

    return results;
  }

  public Optional<ProjectStatusType> getOneCompanyProjectStatusType(Long id) {
    Optional<ProjectStatusType> result = sqlCache.get("project.getOneCompanyStatus",
      ImmutableMap.of("id", id), ProjectStatusType.class);

    if(result.isPresent()) {
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
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("project.saveInitialProjectStatusType", params);
  }

  public Optional<ProjectStatusType> saveCompanyProjectStatus(ProjectStatusType status) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.getId());
    params.put("rootProjectStatusTypeId", status.getProjectStatusTypeId());
    params.put("projectStatusType", status.getProjectStatusType());
    params.put("color", status.getColor());
    params.put("companyId", currentUser.getCompanyId());
    Long id;

    if(null != status.getId()) {
      id = status.getId();
      params.put("id", id);
      params.put("displayOrder", status.getDisplayOrder());
      sqlCache.update("project.updateCompanyStatus", params);
    } else {
      id = sqlCache.updateReturningId("project.insertCompanyStatus", params, "id").longValue();
    }

    //handle attachment

    return getOneCompanyProjectStatusType(id);
  }

  public void saveCompanyProjectStatuses(List<ProjectStatusType> statuses) {
    for(ProjectStatusType s : statuses) {
      saveCompanyProjectStatus(s);
    }
  }

  public void deleteCompanyProjectStatus(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUserId", currentUser.getId());
    params.put("id", id);

    sqlCache.update("project.deleteCompanyStatus", params);
  }

  public List<ProjectStatusType> getProjectStatuses() {
    List<ProjectStatusType> results = sqlCache.query("project.getStatuses", Collections.emptyMap(), ProjectStatusType.class);

    return results;
  }

  public String generateReport(String query) {
    User user = securityService.getCurrentUser();
    List<Map<String, Object>> projects = sqlCache.query("project.generateReport", Map.of("companyId", user.getCompanyId(), "query", query), new ColumnMapRowMapper());

    //write CSV
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
        bw.registerCustomEditor(Object.class, "contact", new JsonCollectionDeserializer(contactRef, objectMapper));

        TypeReference<Owner> ownerRef = new TypeReference<>() {};
        bw.registerCustomEditor(Object.class, "owner",
          new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> statusReadOnlyWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "statusReadOnlyWhiteListedPositions",
        new JsonCollectionDeserializer(statusReadOnlyWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> ownerReadOnlyWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "ownerReadOnlyWhiteListedPositions",
        new JsonCollectionDeserializer(ownerReadOnlyWhiteListedPositionsRef, objectMapper));
    }
  }

  private class CustomGeoFunction implements ObjLongConsumer {

    @Override
    public void accept(Object geoResult, long id) {
      // note: the coordinates in the returned object are reversed: Long, Lat

      //get the lat and long from point
      Point point = (Point)geoResult;
      Double latitude, longitude;
      List<Double> coordinates = point.coordinates();
      latitude = coordinates.get(1);
      longitude = coordinates.get(0);

      if(null != latitude && null != longitude) {
        //if lat and long then update contact's location
        // todo: need to save the contact's timezone here.  not seeing a way to use mapbox and i don't want to import the entire google maps suite
        HashMap<String, Object> params = new HashMap<>();
        params.put("latitude", latitude);
        params.put("longitude", longitude);
        params.put("id", id);

        sqlCache.update("project.updateGeoLocation", params);
        locationUtils.getTimezoneByLatLong(id, longitude, latitude, new CustomTimeZoneFunction());

      }
    }
  }

  private class CustomTimeZoneFunction implements ObjLongConsumer {

    @Override
    public void accept(Object tileQueryFeature, long id) {
      // note: the coordinates in the returned object are reversed: Long, Lat

      //get the lat and long from point
      Feature feature = (Feature)tileQueryFeature;


      if(null != feature && null != feature.getProperty("TZID")) {
        //if there is a timezone save it to the project also
        HashMap<String, Object> params = new HashMap<>();
        params.put("timeZone", feature.getProperty("TZID").getAsString());
        params.put("id", id);

        sqlCache.update("project.updateTimeZone", params);
      }

    }
  }
}
