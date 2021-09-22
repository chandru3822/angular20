package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyDefaultField;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class DefaultFieldService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<CompanyDefaultField> getCompanyDefaultFieldsByObjectType (Long objectTypeId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("objectTypeId", objectTypeId);

    List<CompanyDefaultField> results = sqlCache.query("defaultField.getCompanyDefaultFieldsByObjectType", params, CompanyDefaultField.class);
    return results;
  }

  public void saveCompanyDefaultField (CompanyDefaultField field) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.getId());
    params.put("id", field.getId());
    params.put("showOnUserProfile", null != field.getShowOnUserProfile() ? field.getShowOnUserProfile() : false);

    sqlCache.update("defaultField.saveCompanyDefaultField", params);
  }

}
