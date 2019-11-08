package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
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

  public List<Org> getOrgsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Org> results = sqlCache.query("org.getAllForCompany", params, Org.class);
    return results;
  }

  public List<Org> getSchedulingOrgs(Long stateId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("stateId", stateId);

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

  public Page<Org> searchOrgs(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<Org> results = sqlCache.query("org.searchOrgs", params, Org.class);
    Integer count = sqlCache.queryForObject("org.searchOrgCount", params, Integer.class);

    Page<Org> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
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
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Org> result = sqlCache.get("org.getOne", params, Org.class);
    return result.orElse(null);
  }

  public List<Org> getOwningOrgsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Org> results = sqlCache.query("org.getOwningOrgsForCompany", params, Org.class);
    return results;
  }

  public Org saveOrg(Org org) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("orgName", org.getOrgName());
    params.put("orgTypeId", org.getOrgTypeId());
    params.put("parentOrgId", org.getParentOrgId());
    params.put("companyId", user.getCompanyId());
    params.put("schedulable", org.getSchedulable());
    params.put("stateId", org.getStateId());
    params.put("active", org.getActiveFlag());

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

    handleSavingCustomFieldValues(org.getCustomFieldGroups(), id);

    return getOrg(id);
  }

  public Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
        || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
  }

  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long primaryId){
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldGroup group : groups) {
      for(CustomFieldValue cfv : group.getCustomFieldValues()){
        //todo: only save if something changed
        if(fieldHasValue(cfv)) {
          HashMap<String, Object> params = new HashMap<>();
          params.put("dateValue", cfv.getDateValue());
          params.put("timestampValue", cfv.getTimestampValue());
          params.put("booleanValue", cfv.getBooleanValue());
          params.put("textValue", cfv.getTextValue());
          params.put("numericValue", cfv.getNumericValue());
          params.put("intValue", cfv.getIntValue());
          params.put("intArrayValue", cfv.getIntArrayValue());
          params.put("orgId", primaryId);
          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

          if(null != cfv.getId()){
            params.put("id", cfv.getId());
            params.put("modifiedById", currentUser.getId());
            sqlCache.update("customFieldValues.updateOrgCustomFieldValue", params);
          } else {
            params.put("createdById", currentUser.getId());
            sqlCache.update("customFieldValues.insertOrgCustomFieldValue", params);
          }
        }
      }
    }
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

}
