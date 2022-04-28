package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.org.OrgLevel;
import com.albatross.api.v1.flow.model.org.OrgType;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrgTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<OrgType> getOrgTypesForCompany() {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.query("orgType.getAllForCompany", params, OrgType.class);
  }

  public List<OrgType> getSchedulableOrgTypesForCompany() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);

    return sqlCache.query("orgType.getSchedulableForCompany", params, OrgType.class);
  }

  public List<OrgLevel> getOrgLevels() {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.query("orgType.getLevels", params, OrgLevel.class);
  }

  public OrgLevel getOrgLevel(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("orgType.getOrgLevel", params, OrgLevel.class).orElse(null);
  }

  public void deleteOrgLevel(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("orgType.deleteOrgLevel", params);
    // todo: randa i hate this. talk to keller about adding the 5 columns for tracking/archiving.
    // don't actually delete
  }

  public OrgLevel saveOrgLevel(OrgLevel level) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
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
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("orgType.getOne", params, OrgType.class).orElse(null);
  }

  public OrgType saveOrgType(OrgType orgType) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgType", orgType.getOrgType());
    params.put("orgParentTypeId", orgType.getOrgParentTypeId());
    params.put("orgLevelId", orgType.getOrgLevelId());
    params.put("archived", orgType.getArchived());
    params.put(
        "availableToChildren",
        null != orgType.getAvailableToChildren() ? orgType.getAvailableToChildren() : false);

    Long id;

    if (orgType.getId() != null) {
      id = orgType.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.update("orgType.updateOrgType", params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateReturningId("orgType.insertOrgType", params, "id").longValue();
    }

    return getOrgType(id);
  }
}
