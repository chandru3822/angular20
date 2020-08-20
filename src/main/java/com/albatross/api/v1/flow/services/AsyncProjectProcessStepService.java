package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.ProcessStepActionChildFunction;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

@Slf4j
@Service
@Component
public class AsyncProjectProcessStepService {

  private final SqlCache sqlCache;

  private final ProcessStepActionService processStepActionService;

  private final ProjectProcessStepService projectProcessStepService;

  private final SecurityService securityService;

    public AsyncProjectProcessStepService(SqlCache sqlCache, ProcessStepActionService processStepActionService, @Lazy ProjectProcessStepService projectProcessStepService, SecurityService securityService) {
        this.sqlCache = sqlCache;
        this.processStepActionService = processStepActionService;
        this.projectProcessStepService = projectProcessStepService;
        this.securityService = securityService;
    }

    @Async
  public void asyncRunChildFunctions(Long actionId, Long projectProcessStepId, Long userId) {
    List<ProcessStepActionChildFunction> childFunctions = processStepActionService.getChildFunctionsWithParamValues(actionId, projectProcessStepId);
    childFunctions.forEach(childFunction -> {
      try {
        String params = String.join(", ", prepareFunctionParams(childFunction.getCompanyFunctionParams(), childFunction.getProjectId(), userId));
        String query = String.format("select * from %s(%s)", childFunction.getFunctionName(), params);
        sqlCache.getBySql(query, null, new SingleColumnRowMapper<>(Object.class));
        log.info(String.format("Successfully executed child action function. CFA ID: %s, action ID: %s",childFunction.getId(), actionId));
      } catch (Exception e) {
        log.error(String.format("Unable to run child action function. CFA ID: %s, action ID: %s", childFunction.getId(), actionId));
        e.printStackTrace();
      }
    });
  }

  @Async
  public void asyncPerformAutoTriggerActions (Long processStepId, Long ppsId, UserAccountDetails userDetails) {
      // Set the security context so we have user details in the async downline
      securityService.setCurrentUserDetails(userDetails);
      Instant start = Instant.now();
      projectProcessStepService.performAutoTriggerActions(processStepId, ppsId);
      Instant end = Instant.now();
      log.info("");
      log.info(String.format("*** DURATION MILLI: %s ***", Duration.between(start, end).toMillis()));
      log.info(String.format("*** DURATIONS SECS: %s ***", Duration.between(start, end).toSeconds()));
      log.info("");
  }

  //@TODO: getParamValueByDataType is annoyingly copied from projectProcessStepService. Fix it
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
            Object paramValue = projectProcessStepService.getParamValueByDataType(param);
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
}
