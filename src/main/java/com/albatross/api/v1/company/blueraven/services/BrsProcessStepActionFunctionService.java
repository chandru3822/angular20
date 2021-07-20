package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProcessStepActionChildFunction;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class BrsProcessStepActionFunctionService {

  private final LoanPalService loanPalServiceAutowire;

  private final SqlCache sqlCacheAutowire;

  private static LoanPalService loanPalService;

  private static SqlCache sqlCache;

  @PostConstruct
  public void init() {
    BrsProcessStepActionFunctionService.loanPalService = loanPalServiceAutowire;
    BrsProcessStepActionFunctionService.sqlCache = sqlCacheAutowire;
  }

  public static void updateLoanDocumentStatus(ProcessStepActionChildFunction func, Map<String, Object> systemValues) throws Exception {

    try {
      JSONObject application = loanPalService.getApplicationByProjectId(systemValues.get("projectId").toString());

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
      params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));
      params.put("textValue", application.get("status").toString());

      //default values
      params.put("dateValue", null);
      params.put("timestampValue", null);
      params.put("booleanValue", false);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);

      sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
    } catch (Exception e) {
      throw e;
    }
  }
}
