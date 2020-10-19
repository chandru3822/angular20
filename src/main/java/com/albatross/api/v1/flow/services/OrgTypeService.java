package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.OrgLevel;
import com.albatross.api.v1.flow.model.OrgType;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OrgTypeService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<OrgType> getOrgTypesForCompany() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgType> results = sqlCache.query("orgType.getAllForCompany", params, OrgType.class);
    return results;
  }

  public List<OrgType> getSchedulableOrgTypesForCompany() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgType> results = sqlCache.query("orgType.getSchedulableForCompany", params, OrgType.class);
    return results;
  }

  public List<OrgLevel> getOrgLevels() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<OrgLevel> results = sqlCache.query("orgType.getLevels", params, OrgLevel.class);
    return results;
  }

  public OrgLevel getOrgLevel(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<OrgLevel> results = sqlCache.get("orgType.getOrgLevel", params, OrgLevel.class);

    return results.orElse(null);
  }

  public void deleteOrgLevel(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("orgType.deleteOrgLevel", params);
    //todo: randa i hate this. talk to keller about adding the 5 columns for tracking/archiving. don't actually delete
  }

  public OrgLevel saveOrgLevel(OrgLevel level) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("level", level.getLevel());
    params.put("levelName", level.getLevelName());

    Long id;
    if (null != level.getId()) {
      id = level.getId();
      params.put("id", id);
      sqlCache.update("orgType.updateOrgLevel", params);
    } else {
      id = sqlCache.updateReturningId("orgType.insertOrgLevel", params, "id").longValue();
    }

    return getOrgLevel(id);
  }

  public OrgType getOrgType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<OrgType> result = sqlCache.get("orgType.getOne", params, OrgType.class);
    return result.orElse(null);
  }

  public OrgType saveOrgType(OrgType orgType) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgType", orgType.getOrgType());
    params.put("orgParentTypeId", orgType.getOrgParentTypeId());
    params.put("orgLevelId", orgType.getOrgLevelId());
    params.put("archived", orgType.getArchived());
    params.put("availableToChildren", null != orgType.getAvailableToChildren() ? orgType.getAvailableToChildren() : false);

    Long id;

    if(orgType.getId() != null) {
      id = orgType.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());
      sqlCache.update("orgType.updateOrgType", params);
    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("orgType.insertOrgType", params, "id").longValue();
    }

    return getOrgType(id);
  }

}
