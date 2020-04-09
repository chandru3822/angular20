package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.ProcessStepActionChildFunction;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.TreeMap;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class AsyncProjectProcessStepService {

  private final SqlCache sqlCache;

  private final ProcessStepActionService processStepActionService;

  @Async
  public void asyncRunChildFunctions(Long actionId, Long projectProcessStepId, Long userId) {
    try {
      Thread.sleep(5000);
    } catch (Exception e) {
      log.error("this thing sucks");
    }
    List<ProcessStepActionChildFunction> childFunctions = processStepActionService.getChildFunctionsWithParamValues(actionId, projectProcessStepId);
    childFunctions.forEach(childFunction -> {
      try {
        String params = String.join(", ", prepareFunctionParams(childFunction.getCompanyFunctionParams(), childFunction.getProjectId(), userId));
        String query = String.format("select * from flow.%s(%s)", childFunction.getFunctionName(), params);
        sqlCache.getBySql(query, null, new SingleColumnRowMapper<>(Object.class));
        log.info(String.format("Successfully executed child action function. CFA ID: %s, action ID: %s",childFunction.getId(), actionId));
      } catch (Exception e) {
        log.error(String.format("Unable to run child action function. CFA ID: %s, action ID: %s", childFunction.getId(), actionId));
        e.printStackTrace();
      }
    });
  }

  //@TODO: prepareFunctionParams and getParamValueByDataType are annoyingly copied from getParamValueByDataType. Fix it
  private String[] prepareFunctionParams(List<CompanyFunctionParam> functionParams, Long projectId, Long userId) throws Exception {
    Map<Long, String> params = new TreeMap<>();

    functionParams.forEach(param -> {
      switch (param.getParameterTypeId().intValue()) {
        case 1:
          Long systemValue = null;
          switch (param.getSystemValueId().intValue()) {
            case 1:
              systemValue = userId;
              break;
            case 2:
              systemValue = projectId;
              break;
            default:
              //@TODO: die a horrible death
          }
          params.put(param.getDisplayOrder(), systemValue != null ? systemValue.toString() : null);
          break;
        case 2:
          params.put(param.getDisplayOrder(), param.getDynamicValue());
          break;
        case 3:
          try {
            Object paramValue = getParamValueByDataType(param);
            params.put(param.getDisplayOrder(), (paramValue != null) ? paramValue.toString() : null);
          } catch (Exception e) {
            ///@TODO: throw ex
          }
          break;
        default:
          //@TODO: throw exception
      }
    });

    return params.values().toArray(String[]::new);
  }

  private Object getParamValueByDataType(CompanyFunctionParam param) throws Exception {

    Object paramValue = null;

    switch (param.getDataTypeId().intValue()) {
      case 1:
        paramValue = param.getDateValue();
        break;
      case 2:
        paramValue = param.getTimestampValue();
        break;
      case 3:
        paramValue = param.getBooleanValue();
        break;
      case 4:
        paramValue = param.getNumericValue();
        break;
      case 5:
        paramValue = param.getTextValue();
        break;
      case 6:
        paramValue = param.getIntValue();
        break;
      case 7:
        paramValue = param.getIntArrayValue();
        break;
      default:
        //@TODO: throw nasty exception
    }

    return paramValue;
  }
}
