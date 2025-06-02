package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.OrgController;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserOrgAccess;
import com.albatross.api.v1.flow.model.org.Org;
import com.albatross.api.v1.flow.model.org.OrgExportTemplate;
import com.albatross.api.v1.flow.model.org.OrgFilter;
import com.albatross.api.v1.flow.queries.OrgQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections.CollectionUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrgService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldValueService customFieldValueService;
  private final AttachmentService attachmentService;
  private final ObjectMapper om;

  public void doOrgStructureRefresh() {
    sqlCache.updateBySql(OrgQuery.orgStructureRefresh, Collections.emptyMap());
  }

  public List<Org> getOrgsForCompany() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(OrgQuery.getAllForCompany, params, Org.class);
  }

  public List<Org> getAllActive() {
    var user = securityService.getCurrentUser();
    return sqlCache.queryBySql(OrgQuery.getAllActive, Map.of("companyId", user.getCompanyId()), Org.class);
  }

  public List<User> getUsersInOrg(Long orgId) {
    Map<String, Object> params = new HashMap<>();
    params.put("orgId", orgId);

    return sqlCache.queryBySql(OrgQuery.getUsersInOrg, params, User.class);
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

    return sqlCache.queryBySql(OrgQuery.getSchedulingOrgs, params, Org.class);
  }

  public List<Org> getOrgsByType(Long typeId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("typeId", typeId);
    return sqlCache.queryBySql(OrgQuery.getOrgsByType, params, Org.class);
  }

  public ResponseEntity exportOrgs(String query) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);

    List<Org> results = sqlCache.queryBySql(OrgQuery.exportOrgs, params, Org.class);

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
    Optional<Org> result = sqlCache.getBySql(OrgQuery.getOne, params, new OrgMapper<>(Org.class, om));
    if (result.isPresent()) {
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
      sqlCache.updateBySql(OrgQuery.updateOrg, params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateBySqlReturningId(OrgQuery.insertOrg, params, "id").longValue();
    }
    // Iterate over custom field groups and save custom field values
    Optional.ofNullable(org.getCustomFieldGroups())
      .orElse(Collections.emptyList()).stream()
      .filter(group -> CollectionUtils.isNotEmpty(group.getCustomFieldValues()))
      .forEach(group ->
        customFieldValueService.updateCustomFieldValues(
          group.getCustomFieldValues(),
          id,
          ObjectType.ORGANIZATION
        )
      );

    return getOrg(id);
  }

  public List<OrgFilter> getOrgFiltersForCompany() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgFilter> results =
      sqlCache.queryBySql(OrgQuery.getOrgFiltersForCompany, params, OrgFilter.class);

    for (OrgFilter f : results) {
      // build the list of options
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("orgLevelId", f.getOrgLevelId());
      p2.put("companyId", user.getCompanyId());
      List<Org> orgs = sqlCache.queryBySql(OrgQuery.getOrgsForLevel, p2, Org.class);
      f.setOrgs(orgs);
    }

    return results;
  }

  public OrgFilter getOneOrgFilter(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(OrgQuery.getOneOrgFilter, params, OrgFilter.class).orElse(null);
  }

  public void deleteOrgFilter(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.updateBySql(OrgQuery.deleteOrgFilter, params);
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
      sqlCache.updateBySql(OrgQuery.updateOrgFilter, params);
    } else {
      id = sqlCache.updateBySqlReturningId(OrgQuery.insertOrgFilter, params, "id").longValue();
    }

    return getOneOrgFilter(id);
  }

  public List<OrgFilter> getHierarchyFilteredOrgsForCompany(List<Integer> selectedOrgs) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgFilter> results =
      sqlCache.queryBySql(OrgQuery.getOrgFiltersForCompany, params, OrgFilter.class);

    Map<String, Object> p2 = new HashMap<>();
    p2.put("selectedOrgs", selectedOrgs);
    List<Org> orgs = sqlCache.queryBySql(OrgQuery.getOrgsByHierarchyFilter, p2, Org.class);

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


    if (userHasFullCalendarAccess(userId)) {
      //get all scheduling orgs for company if user has full access
      return getSchedulingOrgs(null, true);
    } else {
      return sqlCache.queryBySql(OrgQuery.getOrgCalendarsForUser, params, Org.class);
    }

  }

  public Boolean userHasFullCalendarAccess(Long userId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", user.getCompanyId());

    return sqlCache.queryForObjectBySql(OrgQuery.getOrgCalendarsAccessLevelForUser, params, Boolean.class);
  }


  public List<Org> saveOrgCalendarsAccess(OrgController.UserOrgAccessRequest request) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", request.getUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("currentUserId", currentUser.trueUserId());
    params.put("fullCalendarAccess", request.isFullCalendarAccess());

    //if an empty array is sent in then all existing will be deleted
    List<Long> orgIdsSentIn = request.getUserOrgAccess().stream().map(UserOrgAccess::getOrgId).toList();
    params.put("orgIdsSentIn", orgIdsSentIn);

    //save the full calendar access every time...for now cuz this is taking too long
    sqlCache.updateBySql(OrgQuery.saveUserFullCalendarAccess, params);

    if (!request.isFullCalendarAccess()) {
      if (!orgIdsSentIn.isEmpty()) {
        //delete any orgs that exist and werent sent in
        sqlCache.updateBySql(OrgQuery.deleteArchivedUserOrgAccess, params);
        //add any orgs that are new and not archived
        sqlCache.updateBySql(OrgQuery.saveOrgCalendarsToUser, params);
      }

    }

    if (request.isFullCalendarAccess() || orgIdsSentIn.isEmpty()) {
      sqlCache.updateBySql(OrgQuery.deleteAllUserOrgAccess, params);
    }

    return getOrgCalendarsForUser(request.getUserId());
  }

  public List<Attachment> getOrgAttachments(Long orgId, Boolean isMobile, Boolean linked) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("orgId", orgId);
    params.put("linked", linked);
    params.put("companyId", currentUser.getCompanyId());
    List<Attachment> attachments =
      sqlCache.queryBySql(OrgQuery.getOrgAttachments, params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, null != isMobile ? isMobile : false);
  }

  public void linkAttachment(Long orgId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("orgId", orgId);
    params.put("attachmentId", attachmentId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sql = OrgQuery.linkAttachment;
    if (!doLink) {
      sql = OrgQuery.unlinkAttachment;
    }
    sqlCache.updateBySql(sql, params);
  }

  public Attachment addAttachment(MultipartFile file, Long orgId, Long attachmentTypeId, String displayName)
    throws IOException {
    User user = securityService.getCurrentUser();

    Attachment attachment = attachmentService.create(file, null, attachmentTypeId, displayName, false);

    Map<String, Object> params = new HashMap<>();
    params.put("orgId", orgId);
    params.put("attachmentId", attachment.getId());
    params.put("createdById", user.trueUserId());

    sqlCache.updateBySql(OrgQuery.addAttachment, params);

    return attachment;
  }

  public static class OrgMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public OrgMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Org>> childOrgsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "childOrgs", new JsonCollectionDeserializer(childOrgsRef, objectMapper));
    }
  }
}
