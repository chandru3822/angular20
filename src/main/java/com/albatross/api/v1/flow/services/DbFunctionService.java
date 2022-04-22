package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.DbFunctionController;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.function.CompanyFunction;
import com.albatross.api.v1.flow.model.function.DbFunction;
import com.albatross.api.v1.flow.model.function.DbFunctionParam;
import com.albatross.api.v1.flow.model.function.DbFunctionType;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class DbFunctionService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;

  public List<DbFunction> getDbFunctions() {
    return sqlCache.query("dbFunction.getAll", Collections.emptyMap(), DbFunction.class);
  }

  public List<Company> getAvailableCompanies(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("dbFunctionId", id);
    return sqlCache.query("dbFunction.getAvailableCompanies", params, Company.class);
  }

  public DbFunction getDbFunction(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache
        .get("dbFunction.getOne", params, new DbFunctionMapper<>(DbFunction.class, om))
        .orElse(null);
  }

  public void archiveDbFunction(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("dbFunction.archive", params);
  }

  public List<DbFunctionType> getDbFunctionTypes() {
    return sqlCache.query("dbFunction.getTypes", Collections.emptyMap(), DbFunctionType.class);
  }

  public List<ParameterType> getParameterTypes() {
    return sqlCache.query(
        "dbFunction.getParameterTypes", Collections.emptyMap(), ParameterType.class);
  }

  public DbFunction insertDbFunction(DbFunction dbFunction) {
    Map<String, Object> params = new HashMap<>();
    params.put("functionName", dbFunction.getFunctionName());
    params.put("returnDataTypeId", dbFunction.getReturnDataTypeId());
    params.put("dbFunctionTypeId", dbFunction.getDbFunctionTypeId());
    params.put("displayName", dbFunction.getDisplayName());

    // Allow running java functions with only action type functions
    if (!Objects.equals(dbFunction.getDbFunctionTypeId(), 2L)) {
      dbFunction.setRunInBackend(false);
    }
    params.put("runInBackend", dbFunction.getRunInBackend() != null && dbFunction.getRunInBackend());
    params.put("processStepActionable", dbFunction.getProcessStepActionable() != null && dbFunction.getProcessStepActionable());
    params.put("eventActionable", dbFunction.getEventActionable() != null && dbFunction.getEventActionable());

    Long id = sqlCache.updateReturningId("dbFunction.insertFunction", params, "id").longValue();
    return getDbFunction(id);
  }

  public DbFunction insertDbFunctionParam(DbFunctionParam dbFunctionParam) {
    Map<String, Object> params = new HashMap<>();
    params.put("parameterName", dbFunctionParam.getParameterName());
    params.put("dbFunctionId", dbFunctionParam.getDbFunctionId());
    params.put("dataTypeId", dbFunctionParam.getDataTypeId());
    params.put("parameterTypeId", dbFunctionParam.getParameterTypeId());
    params.put("systemValueId", dbFunctionParam.getSystemValueId());

    sqlCache.update("dbFunction.insertParam", params);
    return getDbFunction(dbFunctionParam.getDbFunctionId());
  }

  public DbFunction addToCompany(Long functionId, DbFunctionController.AddToCompanyRequest req) {
    Map<String, Object> params = new HashMap<>();
    params.put("functionId", functionId);
    params.put("displayName", req.getDisplayName());

    for (Long companyId : req.getSelectedCompanyIds()) {
      params.put("companyId", companyId);
      sqlCache.update("dbFunction.addToCompany", params);
    }

    return getDbFunction(functionId);
  }

  public List<SystemValue> getSystemValues() {
    return sqlCache.query("dbFunction.getSystemValues", Collections.emptyMap(), SystemValue.class);
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

      bw.registerCustomEditor(
          List.class,
          "dbFunctionParams",
          new JsonCollectionDeserializer(dbFunctionParamRef, objectMapper));

      TypeReference<List<CompanyFunction>> companyFunctionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "companyFunctions",
          new JsonCollectionDeserializer(companyFunctionsRef, objectMapper));
    }
  }
}
