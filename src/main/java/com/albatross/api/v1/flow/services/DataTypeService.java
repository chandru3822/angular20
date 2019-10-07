package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyDataType;
import com.albatross.api.v1.flow.model.DataTypeRequirement;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


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

  public List<DataTypeRequirement> getDataTypeRequirements(Long dataTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("dataTypeId", dataTypeId);
    List<DataTypeRequirement> result = sqlCache.query("dataType.getDataTypeRequirements", params, DataTypeRequirement.class);
    return result;
  }

}
