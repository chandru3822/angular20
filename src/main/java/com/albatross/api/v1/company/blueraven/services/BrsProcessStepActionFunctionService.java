package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
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

  public void getLoanDocsSentDate(ProcessStepActionChildFunction func, Map<String, Object> systemValues) throws Exception {

    try {
      JSONObject application = goodleapService.getApplicationByProjectId(Long.parseLong(systemValues.get("projectId").toString()), true);

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
      params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));

      LocalDate sendAt = LocalDate.parse(application.getString("docsSentAt"), DateTimeFormatter.ISO_DATE_TIME);

      params.put("dateValue", sendAt.toString());

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
}
