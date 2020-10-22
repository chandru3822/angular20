package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OrgService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final CustomFieldValueService customFieldValueService;

  public List<Org> getOrgsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Org> results = sqlCache.query("org.getAllForCompany", params, Org.class);
    return results;
  }

  public List<Org> getSchedulingOrgs(Long companyStateId, Boolean isSchedulingTool) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("companyStateId", companyStateId);
    params.put("isParent", isParent);
    params.put("isSchedulingTool", isSchedulingTool);

    List<Org> results = sqlCache.query("org.getSchedulingOrgs", params, Org.class);
    return results;
  }

  public List<Org> getOrgsByType(Long typeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("typeId", typeId);
    List<Org> results = sqlCache.query("org.getOrgsByType", params, Org.class);
    return results;
  }

  public ResponseEntity exportOrgs(String query) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
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
      Collection<OrgExportTemplate> details = Collections2.transform(
          results,
          OrgExportTemplate::from);

      // next, write them to a buffer so we can identify errors before writing across the network
      outToBuffer.writeAll(details);
      outToBuffer.flush();

      // finally, write to network because no errors were encountered
      return ResponseEntity.ok(buffer.toString(StandardCharsets.UTF_8));
    } catch (IOException e) {
      log.error("Encountered error while writing org export to CSV", e);
      return ResponseEntity.status(500)
          .body("Encountered error while writing org export to CSV");
    }
  }

  public Org getOrg(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", user.getCompanyId());
    Optional<Org> result = sqlCache.get("org.getOne", params, Org.class);
    return result.orElse(null);
  }

  public Org saveOrg(Org org) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("orgName", org.getOrgName());
    params.put("orgTypeId", org.getOrgTypeId());
    params.put("parentOrgId", org.getParentOrgId());
    params.put("companyId", user.getCompanyId());
    params.put("schedulable", null != org.getSchedulable() ? org.getSchedulable() : false);
    params.put("availableToChildren", null != org.getAvailableToChildren() ? org.getAvailableToChildren() : false);
    params.put("companyStateId", org.getCompanyStateId());
    params.put("active", org.getActiveFlag());
    params.put("companyTimezoneId", org.getCompanyTimezoneId());

    Long id;
    if(null != org.getId()) {
      id = org.getId();
      params.put("modifiedById", user.getId());
      params.put("id", id);
      sqlCache.update("org.updateOrg", params);
    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("org.insertOrg", params, "id").longValue();
    }

    if (null != org.getCustomFieldGroups()) {
      customFieldValueService.updateCustomFieldValues(org.getCustomFieldGroups().get(0).getCustomFieldValues(), id, ObjectType.ORGANIZATION.toString());
    }

    return getOrg(id);
  }

  public List<OrgFilter> getOrgFiltersForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgFilter> results = sqlCache.query("org.getOrgFiltersForCompany", params, OrgFilter.class);

    for(OrgFilter f : results){
      //build the list of options
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("orgLevelId", f.getOrgLevelId());
      p2.put("companyId", user.getCompanyId());
      List<Org> orgs = sqlCache.query("org.getOrgsForLevel", p2, Org.class);
      f.setOrgs(orgs);
    }

    return results;
  }

  public OrgFilter getOneOrgFilter(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<OrgFilter> results = sqlCache.get("org.getOneOrgFilter", params, OrgFilter.class);

    return results.orElse(null);
  }

  public void deleteOrgFilter(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("org.deleteOrgFilter", params);
    //todo: randa i hate this. talk to keller about adding the 5 columns for tracking/archiving. don't actually delete
  }

  public OrgFilter saveOrgFilter(OrgFilter filter) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
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
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgFilter> results = sqlCache.query("org.getOrgFiltersForCompany", params, OrgFilter.class);

    HashMap<String, Object> p2 = new HashMap<>();
    p2.put("selectedOrgs", selectedOrgs);
    List<Org> orgs = sqlCache.query("org.getOrgsByHierarchyFilter", p2, Org.class);

    for(OrgFilter f : results){
      //build the list of options
      f.setOrgs(orgs.stream().filter(o -> ( o.getOrgLevelId().equals(f.getOrgLevelId())  )).collect(Collectors.toList()) );
    }

    return results;
  }

  public List<Org> getOrgCalendarsForUser(Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("companyId", user.getCompanyId());
    List<Org> results = sqlCache.query("org.getOrgCalendarsForUser", params, Org.class);

    return results;
  }

  public UserOrgAccess saveOrgCalendarToUser(UserOrgAccess userOrgAccess) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userOrgAccess.getUserId());
    params.put("orgId", userOrgAccess.getOrgId());
    params.put("createdById", user.getId());

    Long id = sqlCache.updateReturningId("org.saveOrgCalendarToUser", params, "id").longValue();
    return getOneOrgCalendarAccess(id);
  }

  public void deleteOrgCalendarFromUser(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("org.deleteOrgCalendarFromUser", params);
  }

  public UserOrgAccess getOneOrgCalendarAccess(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<UserOrgAccess> result = sqlCache.get("org.getOneOrgCalendarAccess", params, UserOrgAccess.class);

    return result.orElse(null);
  }


}
