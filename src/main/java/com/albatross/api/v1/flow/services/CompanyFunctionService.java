package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyFunction;
import com.albatross.api.v1.flow.model.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.SystemValue;
import com.albatross.api.v1.flow.model.User;
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

  public void deleteCompanyFunction(Long id) {
//    todo: add updated by and date
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("companyFunction.deleteCompanyFunction", params);
  }

  public CompanyFunction getFunctionDetails(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CompanyFunction> results = sqlCache.get("companyFunction.getFunctionDetails", params, new CompanyFunctionMapper<>(CompanyFunction.class, om));
    return results.orElse(null);
  }

  public List<CompanyFunctionParam> getFunctionDefaultParams(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    List<CompanyFunctionParam> results = sqlCache.query("companyFunction.getFunctionDefaultParams", params, CompanyFunctionParam.class);
    return results;
  }

  public CompanyFunctionParam saveFunctionParams(Long functionId, CompanyFunctionParam param) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> queryParams = new HashMap<>();
    queryParams.put("functionId", functionId);

//    todo: add values for date_modified and such when ready

    queryParams.put("dbFunctionParamId", param.getDbFunctionParamId());
    queryParams.put("companyFunctionId", param.getCompanyFunctionId());
    queryParams.put("customFieldGroupId", param.getCustomFieldGroupId());
    queryParams.put("defaultValue", param.getDefaultValue());
    queryParams.put("systemValueId", param.getSystemValueId());
    queryParams.put("userId", currentUser.getId());

    Long id = null;
    if(null != param.getId()) {
      id = param.getId();
      queryParams.put("id", param.getId());

      sqlCache.update("companyFunction.updateCompanyFunctionParam", queryParams);
    } else if (null != param.getCustomFieldGroupId() || null != param.getDefaultValue() || null != param.getSystemValueId()){
      // don't insert a new row if all the possible input values are null

      id = sqlCache.updateReturningId("companyFunction.insertCompanyFunctionParam", queryParams, "id").longValue();
    }

    return getCompanyParam(id);
  }

  public CompanyFunctionParam getCompanyParam(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CompanyFunctionParam> result = sqlCache.get("companyFunction.getCompanyParam", params, CompanyFunctionParam.class);
    return result.orElse(null);
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
