package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CompanyObjectType;
import com.albatross.api.v1.flow.model.CombinedStepAndType;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

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
public class BlueravenObjectTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<CompanyObjectType> getCompanyObjectTypes() {
    User user = securityService.getCurrentUser();
    if(user.getCompanyId() != 3) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not have access to this company data.", new Exception());
    } else {
      HashMap<String, Object> params = new HashMap<>();
      params.put("companyId", user.getCompanyId());
      List<CompanyObjectType> result = sqlCache.query("blueravenObjectType.getCompanyObjectTypes", params, CompanyObjectType.class);
      return result;
    }
  }

  public Optional<CompanyObjectType> getCompanyObjectTypeDetail(Long objectTypeId) {
    User user = securityService.getCurrentUser();
    if(user.getCompanyId() != 3) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not have access to this company data.", new Exception());
    } else {
      HashMap<String, Object> params = new HashMap<>();
      params.put("companyId", user.getCompanyId());
      params.put("objectTypeId", objectTypeId);
      Optional<CompanyObjectType> result = sqlCache.get("blueravenObjectType.getCompanyObjectTypeDetail", params, CompanyObjectType.class);
      return result;
    }
  }

  public List<CombinedStepAndType> getParentObjectsWithTypes(Long objectTypeId) {
    User user = securityService.getCurrentUser();
    if(user.getCompanyId() != 3) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not have access to this company data.", new Exception());
    } else {
      HashMap<String, Object> params = new HashMap<>();
      params.put("companyId", user.getCompanyId());
      params.put("objectTypeId", objectTypeId);
      List<CombinedStepAndType> result = sqlCache.query("blueravenObjectType.getParentObjectsIncludingTypes", params, CombinedStepAndType.class);
      return result;
    }
  }
}
