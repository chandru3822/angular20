package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.function.CompanyFunction;
import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.RequirementParamDynamicValue;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class CompanyFunctionService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<CompanyFunction> getCompanyFunctions() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.query("companyFunction.getFunctions", params, CompanyFunction.class);
  }

  public List<CompanyFunction> getCompanyFunctionsByType(Long typeId, Long objectTypeId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("typeId", typeId);
    params.put("processStepActionable", objectTypeId.equals(ObjectType.PROCESS_STEP.id));
    params.put("eventActionable", objectTypeId.equals(ObjectType.EVENT.id));
    //event = 6, ps = 4

    List<CompanyFunction> results = sqlCache.query("companyFunction.getFunctionsByType", params, CompanyFunction.class);
    return results;
  }

  public void deleteCompanyFunction(Long id) {
    //    todo: add updated by and date
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("companyFunction.deleteCompanyFunction", params);
  }

  public CompanyFunction getFunctionDetails(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache
        .get(
            "companyFunction.getFunctionDetails",
            params,
            new CompanyFunctionMapper<>(CompanyFunction.class, om))
        .orElse(null);
  }

  public List<RequirementParamDynamicValue> getFunctionDynamicParams(Long dbFunctionId) {
    Map<String, Object> params = new HashMap<>();
    params.put("dbFunctionId", dbFunctionId);
    // 2 = dynamic value params - maybe we pass this in later if needed
    params.put("parameterTypeId", 2);
//    this returns "false" as the default for boolean fields. fyi.  maybe we add this as an option to the dfp later
    return sqlCache.query(
        "companyFunction.getFunctionDynamicParams", params, RequirementParamDynamicValue.class);
  }

  public CompanyFunctionParam saveFunctionParams(Long functionId, CompanyFunctionParam param) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> queryParams = new HashMap<>();
    queryParams.put("functionId", functionId);

    //    todo: add values for date_modified and such when ready

    queryParams.put("dbFunctionParamId", param.getDbFunctionParamId());
    queryParams.put("companyFunctionId", param.getCompanyFunctionId());
    queryParams.put("customFieldGroupAssignmentId", param.getCustomFieldGroupAssignmentId());
    queryParams.put("dynamicValue", param.getDynamicValue());
    queryParams.put("systemValueId", param.getSystemValueId());
    queryParams.put("userId", currentUser.trueUserId());

    Long id = null;
    if (null != param.getId()) {
      id = param.getId();
      queryParams.put("id", param.getId());

      sqlCache.update("companyFunction.updateCompanyFunctionParam", queryParams);
    } else if (null != param.getCustomFieldGroupAssignmentId()
        || null != param.getDynamicValue()
        || null != param.getSystemValueId()) {
      // don't insert a new row if all the possible input values are null

      id =
          sqlCache
              .updateReturningId("companyFunction.insertCompanyFunctionParam", queryParams, "id")
              .longValue();
    }

    return getCompanyParam(id);
  }

  public CompanyFunctionParam getCompanyParam(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache
        .get("companyFunction.getCompanyParam", params, CompanyFunctionParam.class)
        .orElse(null);
  }

  public static class CompanyFunctionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CompanyFunctionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CompanyFunctionParam>> companyFunctionParamRef =
          new TypeReference<List<CompanyFunctionParam>>() {};

      bw.registerCustomEditor(
          List.class,
          "companyFunctionParams",
          new JsonCollectionDeserializer(companyFunctionParamRef, objectMapper));
    }
  }
}
