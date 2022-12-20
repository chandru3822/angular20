package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyDataType;
import com.albatross.api.v1.flow.model.DataType;
import com.albatross.api.v1.flow.model.DataTypeRequirement;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.DataTypeQuery;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Service
@RequiredArgsConstructor
public class DataTypeService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<DataType> getSystemDataTypes() {
    return sqlCache.queryBySql(DataTypeQuery.getSystemDataTypes, Collections.emptyMap(), DataType.class);
  }

  public List<CompanyDataType> getCompanyDataTypes() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(DataTypeQuery.getCompanyDataTypes, params, CompanyDataType.class);
  }

  public List<DataTypeRequirement> getDataTypeRequirements(Long dataTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("dataTypeId", dataTypeId);
    return sqlCache.queryBySql(DataTypeQuery.getDataTypeRequirements, params, DataTypeRequirement.class);
  }
}
