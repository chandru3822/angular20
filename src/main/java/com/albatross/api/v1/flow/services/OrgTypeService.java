package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
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
    params.put("level", orgType.getLevel());
    params.put("active", orgType.getActive());

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
