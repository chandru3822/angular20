package com.albatross.api.v1.flow.services;

import java.util.HashMap;
import java.util.List;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyDataType;
import com.albatross.api.v1.flow.model.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class DataTypeService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<CompanyDataType> getCompanyDataTypes() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyDataType> result = sqlCache.query("dataType.getCompanyDataTypes", params, CompanyDataType.class);
    return result;
  }

}
