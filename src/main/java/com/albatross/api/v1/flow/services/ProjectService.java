package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
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
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectService {

  private final SqlCache sqlCache;

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

  public Page<Project> searchProjects(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());
    List<Project> projects = sqlCache.query("project.search", params, Project.class);
    Integer total = sqlCache.queryForObject("project.searchCount", params, Integer.class);
    return new PageImpl<>(projects, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), total);
  }

  public Optional<Project> getProject(Long projectId) {
    return sqlCache.get("project.get", ImmutableMap.of("projectId", projectId), new ProjectMapper<>(Project.class, om));
  }

  public void updateProject(Project project) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", project.getId());
    params.put("street1", project.getStreet1());
    params.put("city", project.getCity());
    params.put("stateId", project.getStateId());
    params.put("postalCode", project.getPostalCode());
    params.put("countryId", project.getCountryId());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("project.update", params);
  }

  public Optional<Project> insertProject(Long contactId, Long processId, Contact contact) {
    User user = securityService.getCurrentUser();

    // Get active company project status type so new projects can have an active status
    CompanyProjectStatusType companyStatusType = this.getActiveCompanyProjectStatusType(user.getCompanyId());
    Long companyStatusTypeId = (companyStatusType != null) ? companyStatusType.getId() : null;

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId );
    params.put("createdById", user.getId() );
    params.put("projectName", contact.getFullName() );
    params.put("processId", processId );
    params.put("street1", contact.getStreet1() );
    params.put("city", contact.getCity() );
    params.put("stateId", contact.getStateId() );
    params.put("countryId", contact.getCountryId() );
    params.put("postalCode", contact.getPostalCode() );
    params.put("companyProjectStatusTypeId", companyStatusTypeId );

    Long id = sqlCache.updateReturningId("project.insert", params, "id").longValue();

    return getProject(id);
  }

  public List<Attachment> getAttachments(Long projectId, Boolean isMobile) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    List<Attachment> attachments = sqlCache.query("project.getAttachments", params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long projectId, Long attachmentTypeId) throws IOException {
    User currentUser = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

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
    params.put("filename", file.getOriginalFilename());
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("createdById", currentUser.getId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("attachmentTypeId", attachmentTypeId);

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectId", projectId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", currentUser.getId());

    sqlCache.update("project.addAttachment", params);

    return attachmentService.findById(storageBucket, attachmentId);
  }

  public List<Project> getProjectsForContact(Long contactId) {
    User user = securityService.getCurrentUser();
    return sqlCache.query("project.getAllForContact", ImmutableMap.of("companyId", user.getCompanyId(), "contactId", contactId), Project.class);
  }

  public void updateOwner(Long projectId, Owner owner) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userPositionId", (owner == null) ? null : owner.getUserPositionId());
    params.put("projectId", projectId);
    params.put("userId", securityService.getCurrentUser().getId());
    sqlCache.update("project.updateOwner", params);
  }

  public void updateStatus(Long projectId, Long companyProjectStatusTypeId) {
      sqlCache.update("project.updateStatus", Map.of("projectId", projectId, "companyProjectStatusTypeId", companyProjectStatusTypeId));
  }

  private CompanyProjectStatusType getActiveCompanyProjectStatusType(Long companyId) {
    return sqlCache.get("project.getActiveProjectStatusTypeByCompanyId", Map.of("companyId", companyId), CompanyProjectStatusType.class).orElse(null);
  }

  public List<ProjectProcessStep> getProcessStepsByProjectId(Long projectId) {
    return sqlCache.query("project.getProcessStepsByProjectId", ImmutableMap.of("projectId", projectId), new ProjectProcessStepService.ProjectProcessStepMapper<>(ProjectProcessStep.class, om));
  }

  public List<Owner> getOwners() {
    return sqlCache.query("project.getOwners", Map.of("companyId", securityService.getCurrentUser().getCompanyId()), Owner.class);
  }

  public List<ProjectStatus> getStatuses() {
      return sqlCache.query("project.getStatuses", Map.of("companyId", securityService.getCurrentUser().getCompanyId()), ProjectStatus.class);
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
      TypeReference<Owner> ownerRef = new TypeReference<>() {};
      bw.registerCustomEditor(Object.class, "owner", new JsonCollectionDeserializer(ownerRef, objectMapper));
    }
  }
}
