package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserOrgAccess;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.org.OrgExportTemplate;
import com.albatross.api.v1.flow.model.org.OrgFilter;
import com.albatross.api.v1.flow.queries.AttachmentQuery;
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
import com.google.common.collect.Collections2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrgService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldValueService customFieldValueService;
  private final AmazonS3 s3;
  private final AttachmentService attachmentService;
  private final ObjectMapper om;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public List<Org> getOrgsForCompany() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.query("org.getAllForCompany", params, Org.class);
  }

  public List<User> getUsersInOrg(Long orgId) {
    Map<String, Object> params = new HashMap<>();
    params.put("orgId", orgId);

    return sqlCache.query("org.getUsersInOrg", params, User.class);
  }

  public List<Org> getSchedulingOrgs(Long companyStateId, Boolean isSchedulingTool) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("companyStateId", companyStateId);
    params.put("isParent", isParent);
    params.put("isSchedulingTool", isSchedulingTool);

    return sqlCache.query("org.getSchedulingOrgs", params, Org.class);
  }

  public List<Org> getOrgsByType(Long typeId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("typeId", typeId);
    return sqlCache.query("org.getOrgsByType", params, Org.class);
  }

  public ResponseEntity exportOrgs(String query) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);

    List<Org> results = sqlCache.query("org.exportOrgs", params, Org.class);

    // set up CSV writing
    CsvMapper mapper = new CsvMapper();
    CsvSchema schema = mapper.typedSchemaFor(OrgExportTemplate.class).withHeader();
    ObjectWriter writer = mapper.writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    // get org deets and write to CSV
    try (SequenceWriter outToBuffer = writer.writeValues(buffer)) {
      // first, get deets
      Collection<OrgExportTemplate> details =
          Collections2.transform(results, OrgExportTemplate::from);

      // next, write them to a buffer so we can identify errors before writing across the network
      outToBuffer.writeAll(details);
      outToBuffer.flush();

      // finally, write to network because no errors were encountered
      return ResponseEntity.ok(buffer.toString(StandardCharsets.UTF_8));
    } catch (IOException e) {
      log.error("ORG: Encountered error while writing org export to CSV", e);
      return ResponseEntity.status(500).body("Encountered error while writing org export to CSV");
    }
  }

  public Org getOrg(Long id) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", user.getCompanyId());
    Optional<Org> result = sqlCache.get("org.getOne", params, new OrgMapper<>(Org.class, om));
    if(result.isPresent()) {
      return result.get();
    } else {
      throw new NotFoundException("FAIL_TO_NOT_FOUND_SCREEN");
    }
  }

  public Org saveOrg(Org org) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("orgName", org.getOrgName());
    params.put("orgTypeId", org.getOrgTypeId());
    params.put("parentOrgId", org.getParentOrgId());
    params.put("companyId", user.getCompanyId());
    params.put("schedulable", null != org.getSchedulable() ? org.getSchedulable() : false);
    params.put(
        "availableToChildren",
        null != org.getAvailableToChildren() ? org.getAvailableToChildren() : false);
    params.put("companyStateId", org.getCompanyStateId());
    params.put("active", org.getActiveFlag());
    params.put("companyTimezoneId", org.getCompanyTimezoneId());

    Long id;
    if (null != org.getId()) {
      id = org.getId();
      params.put("modifiedById", user.trueUserId());
      params.put("id", id);
      sqlCache.update("org.updateOrg", params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateReturningId("org.insertOrg", params, "id").longValue();
    }

    if (null != org.getCustomFieldGroups() && !org.getCustomFieldGroups().isEmpty()) {
      customFieldValueService.updateCustomFieldValues(
          org.getCustomFieldGroups().get(0).getCustomFieldValues(),
          id,
          ObjectType.ORGANIZATION.toString());
    }

    return getOrg(id);
  }

  public List<OrgFilter> getOrgFiltersForCompany() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgFilter> results =
        sqlCache.query("org.getOrgFiltersForCompany", params, OrgFilter.class);

    for (OrgFilter f : results) {
      // build the list of options
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("orgLevelId", f.getOrgLevelId());
      p2.put("companyId", user.getCompanyId());
      List<Org> orgs = sqlCache.query("org.getOrgsForLevel", p2, Org.class);
      f.setOrgs(orgs);
    }

    return results;
  }

  public OrgFilter getOneOrgFilter(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("org.getOneOrgFilter", params, OrgFilter.class).orElse(null);
  }

  public void deleteOrgFilter(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("org.deleteOrgFilter", params);
    // todo: randa i hate this. talk to keller about adding the 5 columns for tracking/archiving.
    // don't actually delete
  }

  public OrgFilter saveOrgFilter(OrgFilter filter) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgLevelId", filter.getOrgLevelId());
    params.put("rank", filter.getRank());
    params.put("showType", null != filter.getShowType() ? filter.getShowType() : false);

    Long id;
    if (null != filter.getId()) {
      id = filter.getId();
      params.put("id", id);
      sqlCache.update("org.updateOrgFilter", params);
    } else {
      id = sqlCache.updateReturningId("org.insertOrgFilter", params, "id").longValue();
    }

    return getOneOrgFilter(id);
  }

  public List<OrgFilter> getHierarchyFilteredOrgsForCompany(List<Integer> selectedOrgs) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgFilter> results =
        sqlCache.query("org.getOrgFiltersForCompany", params, OrgFilter.class);

    Map<String, Object> p2 = new HashMap<>();
    p2.put("selectedOrgs", selectedOrgs);
    List<Org> orgs = sqlCache.query("org.getOrgsByHierarchyFilter", p2, Org.class);

    for (OrgFilter f : results) {
      // build the list of options
      f.setOrgs(
          orgs.stream()
              .filter(o -> (o.getOrgLevelId().equals(f.getOrgLevelId())))
              .collect(Collectors.toList()));
    }

    return results;
  }

  public List<Org> getOrgCalendarsForUser(Long userId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", user.getCompanyId());

    return sqlCache.query("org.getOrgCalendarsForUser", params, Org.class);
  }

  public UserOrgAccess saveOrgCalendarToUser(UserOrgAccess userOrgAccess) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", userOrgAccess.getUserId());
    params.put("orgId", userOrgAccess.getOrgId());
    params.put("createdById", user.trueUserId());

    Long id = sqlCache.updateReturningId("org.saveOrgCalendarToUser", params, "id").longValue();
    return getOneOrgCalendarAccess(id);
  }

  public void deleteOrgCalendarFromUser(Long id) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("org.deleteOrgCalendarFromUser", params);
  }

  public UserOrgAccess getOneOrgCalendarAccess(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("org.getOneOrgCalendarAccess", params, UserOrgAccess.class).orElse(null);
  }

  public List<Attachment> getOrgAttachments(Long orgId, Boolean isMobile, Boolean linked) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("orgId", orgId);
    params.put("linked", linked);
    params.put("companyId", currentUser.getCompanyId());
    List<Attachment> attachments =
        sqlCache.query("org.getOrgAttachments", params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(
        attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  public void linkAttachment(Long orgId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("orgId", orgId);
    params.put("attachmentId", attachmentId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sqlKey = "org.linkAttachment";
    if(!doLink) {
      sqlKey = "org.unlinkAttachment";
    }
    sqlCache.update(sqlKey, params);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped
  // code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long orgId, Long attachmentTypeId, String displayName)
      throws IOException {
    User user = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    // get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key =
        String.format(
            user.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());

    PutObjectRequest objectRequest =
        new PutObjectRequest(
            storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

    s3.putObject(objectRequest.withCannedAcl(CannedAccessControlList.PublicRead));

    Map<String, Object> params = new HashMap<>();
    params.put("filename", CleanString.cleanFilename(file.getOriginalFilename()));
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("displayName", displayName.length() > 100 ? displayName.substring(0, 100) : displayName);
    params.put("createdById", user.trueUserId());
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("companyId", user.getCompanyId());

    Long attachmentId = sqlCache.updateBySqlReturningId(AttachmentQuery.create, params, "id").longValue();

    params.clear();
    params.put("orgId", orgId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.trueUserId());

    sqlCache.update("org.addAttachment", params);

    return attachmentService.findById(attachmentId);
  }

  public static class OrgMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public OrgMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Org>> childOrgsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class, "childOrgs", new JsonCollectionDeserializer(childOrgsRef, objectMapper));
    }
  }
}
