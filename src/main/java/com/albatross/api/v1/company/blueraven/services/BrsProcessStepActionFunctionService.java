package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.GoodleapDocumentStatus;
import com.albatross.api.v1.flow.model.ProcessStepActionChildFunction;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@Service
public class BrsProcessStepActionFunctionService {

  private final SqlCache sqlCache;

  private final GoodleapService goodleapService;

  public void getLoanDocsSentDate(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {

    try {
      JSONObject application = goodleapService.getApplicationByProjectId(Long.parseLong(systemValues.get("projectId").toString()), true);

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
      params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));

      LocalDate sentAt = null;

      if (!application.isNull("docsSentAt")) {
        sentAt = LocalDate.parse(application.getString("docsSentAt"), DateTimeFormatter.ISO_DATE_TIME);
      }

      params.put("dateValue", sentAt);

      //default values
      params.put("textValue", null);
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

  public void getLoanDocsSignedDate(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    JSONObject application = goodleapService.getApplicationByProjectId(Long.parseLong(systemValues.get("projectId").toString()), true);

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
    params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
    params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));

    LocalDate signedAt = null;

    if (!application.isNull("docsSignedAt")) {
      signedAt = LocalDate.parse(application.getString("docsSignedAt"), DateTimeFormatter.ISO_DATE_TIME);
    }

    params.put("dateValue", signedAt);

    //default values
    params.put("textValue", null);
    params.put("timestampValue", null);
    params.put("booleanValue", false);
    params.put("numericValue", null);
    params.put("intValue", null);
    params.put("intArrayValue", null);

    sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
  }

  public void getLoanApprovalStatus(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    JSONObject application = goodleapService.getApplicationByProjectId(Long.parseLong(systemValues.get("projectId").toString()));

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
    params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
    params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));

    params.put("textValue", application.getString("status"));

    //default values
    params.put("dateValue", null);
    params.put("timestampValue", null);
    params.put("booleanValue", false);
    params.put("numericValue", null);
    params.put("intValue", null);
    params.put("intArrayValue", null);

    sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
  }

  public void getLoanDocumentStatus(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    JSONObject application = goodleapService.getApplicationByProjectId(Long.parseLong(systemValues.get("projectId").toString()), true);

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
    params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
    params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));

    String status = GoodleapDocumentStatus.UNSENT.toString();

    if (!application.isNull("docsSignedAt")) {
      status = GoodleapDocumentStatus.SIGNED.toString();
    } else if (!application.isNull("docsSentAt")) {
      status = GoodleapDocumentStatus.SENT.toString();
    }

    params.put("textValue", status);

    //default values
    params.put("dateValue", null);
    params.put("timestampValue", null);
    params.put("booleanValue", false);
    params.put("numericValue", null);
    params.put("intValue", null);
    params.put("intArrayValue", null);

    sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
  }

  public void sendLoanDocuments(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
      JSONObject application = goodleapService.getApplicationByProjectId(Long.parseLong(systemValues.get("projectId").toString()));
      goodleapService.sendDocs(application.getString("id"));

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
      params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));

      params.put("dateValue", LocalDate.now());

      //default values
      params.put("textValue", null);
      params.put("timestampValue", null);
      params.put("booleanValue", false);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);

      sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
    } catch (Exception e) {
      final String originalFuncName = func.getFunctionName();
      final int dot = originalFuncName.indexOf('.');
      final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));

      throw new RuntimeException(String.format("PPS: Unable to perform autotrigger java function: %s *** %s", functionName, e.getMessage()));
    }
  }
}
