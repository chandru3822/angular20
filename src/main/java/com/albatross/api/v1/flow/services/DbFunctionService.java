package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.DbFunctionController;
import com.albatross.api.v1.flow.model.*;
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
public class DbFunctionService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<DbFunction> getDbFunctions() {
    List<DbFunction> results = sqlCache.query("dbFunction.getAll", Collections.emptyMap(), DbFunction.class);
    return results;
  }

  public List<Company> getAvailableCompanies(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("dbFunctionId", id);
    List<Company> results = sqlCache.query("dbFunction.getAvailableCompanies", params, Company.class);
    return results;
  }

  public DbFunction getDbFunction(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<DbFunction> result = sqlCache.get("dbFunction.getOne", params, new DbFunctionMapper<>(DbFunction.class, om));
    return result.orElse(null);
  }

  public void archiveDbFunction(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("dbFunction.archive", params);
  }

  public List<DbFunctionType> getDbFunctionTypes() {
    List<DbFunctionType> results = sqlCache.query("dbFunction.getTypes", Collections.emptyMap(), DbFunctionType.class);
    return results;
  }

  public List<ParameterType> getParameterTypes() {
    List<ParameterType> results = sqlCache.query("dbFunction.getParameterTypes", Collections.emptyMap(), ParameterType.class);
    return results;
  }

  public DbFunction insertDbFunction(DbFunction dbFunction) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("functionName", dbFunction.getFunctionName());
    params.put("returnDataTypeId", dbFunction.getReturnDataTypeId());
    params.put("dbFunctionTypeId", dbFunction.getDbFunctionTypeId());
    params.put("displayName", dbFunction.getDisplayName());

    Long id = sqlCache.updateReturningId("dbFunction.insertFunction", params, "id").longValue();
    return getDbFunction(id);
  }
  public DbFunction insertDbFunctionParam(DbFunctionParam dbFunctionParam) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("parameterName", dbFunctionParam.getParameterName());
    params.put("dbFunctionId", dbFunctionParam.getDbFunctionId());
    params.put("dataTypeId", dbFunctionParam.getDataTypeId());
    params.put("parameterTypeId", dbFunctionParam.getParameterTypeId());
    params.put("systemValueId", dbFunctionParam.getSystemValueId());

    sqlCache.update("dbFunction.insertParam", params);
    return getDbFunction(dbFunctionParam.getDbFunctionId());
  }

  public DbFunction addToCompany(Long functionId, DbFunctionController.AddToCompanyRequest req) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("functionId", functionId);
    params.put("displayName", req.getDisplayName());

    for(Long companyId : req.getSelectedCompanyIds()) {
      params.put("companyId", companyId);
      sqlCache.update("dbFunction.addToCompany", params);
    }

    return getDbFunction(functionId);
  }

  public List<SystemValue> getSystemValues() {
    List<SystemValue> results = sqlCache.query("dbFunction.getSystemValues", Collections.emptyMap(), SystemValue.class);
    return results;
  }

  public static class DbFunctionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public DbFunctionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<DbFunctionParam>> dbFunctionParamRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "dbFunctionParams",
          new JsonCollectionDeserializer(dbFunctionParamRef, objectMapper));

      TypeReference<List<CompanyFunction>> companyFunctionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "companyFunctions",
          new JsonCollectionDeserializer(companyFunctionsRef, objectMapper));

    }
  }

}
