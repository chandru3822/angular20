package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyFunction;
import com.albatross.api.v1.flow.model.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.SystemValue;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class CompanyFunctionService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<CompanyFunction> getCompanyFunctions(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<CompanyFunction> results = sqlCache.query("companyFunction.getFunctions", params, CompanyFunction.class);
    return results;
  }

  public CompanyFunction getFunctionDetails(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CompanyFunction> results = sqlCache.get("companyFunction.getFunctionDetails", params, new CompanyFunctionMapper<>(CompanyFunction.class, om));
    return results.orElse(null);
  }

  public void saveFunctionParams(Long functionId, List<CompanyFunctionParam> params) {
    HashMap<String, Object> queryParams = new HashMap<>();
    queryParams.put("functionId", functionId);

//    todo: add values for date_updated and such when ready

    for(CompanyFunctionParam param : params) {
      queryParams.put("dbFunctionParamId", param.getDbFunctionParamId());
      queryParams.put("companyFunctionId", param.getCompanyFunctionId());
      queryParams.put("customFieldGroupId", param.getCustomFieldGroupId());
      queryParams.put("defaultValue", param.getDefaultValue());
      queryParams.put("systemValueId", param.getSystemValueId());

      if(null != param.getId()) {
        queryParams.put("id", param.getId());
        sqlCache.update("companyFunction.updateCompanyFunctionParam", queryParams);
      } else if (null != param.getCustomFieldGroupId() || null != param.getDefaultValue() || null != param.getSystemValueId()){
        // don't insert a new row if all the possible input values are null
        sqlCache.update("companyFunction.insertCompanyFunctionParam", queryParams);
      }
    }
  }

  public List<SystemValue> getSystemValues() {
//    todo: add archived check to query
    List<SystemValue> results = sqlCache.query("companyFunction.getSystemValues", Collections.emptyMap(), SystemValue.class);
    return results;
  }

  public static class CompanyFunctionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CompanyFunctionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CompanyFunctionParam>> companyFunctionParamRef = new TypeReference<List<CompanyFunctionParam>>() {};

      bw.registerCustomEditor(List.class, "companyFunctionParams",
          new JsonCollectionDeserializer(companyFunctionParamRef, objectMapper));

    }
  }

}
