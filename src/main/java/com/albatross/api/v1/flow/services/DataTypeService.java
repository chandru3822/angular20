package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyDataType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class DataTypeService {

  @Autowired
  SqlCache sqlCache;

  public List<CompanyDataType> getCompanyDataTypes(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<CompanyDataType> result = sqlCache.query("dataType.getCompanyDataTypes", params, CompanyDataType.class);
    return result;
  }

}
