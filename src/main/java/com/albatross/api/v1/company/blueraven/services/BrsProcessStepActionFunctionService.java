package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.GoodleapDocumentStatus;
import com.albatross.api.v1.flow.model.ActionParamDynamicValue;
import com.albatross.api.v1.flow.model.ProcessStepActionChildFunction;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
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

  private final AuroraProxy auroraService;

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
    } catch (GoodleapService.NotFoundException e) {
      final String originalFuncName = func.getFunctionName();
      final int dot = originalFuncName.indexOf('.');
      final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));

      throw new RuntimeException(String.format("PPS: Unable to perform autotrigger java function: %s *** %s", functionName, e.getMessage()));
    }
  }

  public void getLoanDocsSignedDate(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
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
    } catch (GoodleapService.NotFoundException e) {
      final String originalFuncName = func.getFunctionName();
      final int dot = originalFuncName.indexOf('.');
      final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));

      throw new RuntimeException(String.format("PPS: Unable to perform autotrigger java function: %s *** %s", functionName, e.getMessage()));
    }
  }

  public void getLoanApprovalStatus(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
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
    } catch (GoodleapService.NotFoundException e) {
      final String originalFuncName = func.getFunctionName();
      final int dot = originalFuncName.indexOf('.');
      final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));

      throw new RuntimeException(String.format("PPS: Unable to perform autotrigger java function: %s *** %s", functionName, e.getMessage()));
    }
  }

  public void getLoanDocumentStatus(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
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
    } catch (GoodleapService.NotFoundException e) {
      final String originalFuncName = func.getFunctionName();
      final int dot = originalFuncName.indexOf('.');
      final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));

      throw new RuntimeException(String.format("PPS: Unable to perform autotrigger java function: %s *** %s", functionName, e.getMessage()));
    }
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

  public void getLoanStipulations(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
      JSONArray stipulations = goodleapService.getApplicationStipulations(Long.parseLong(systemValues.get("projectId").toString()));
      StringBuilder formattedStipulations = new StringBuilder();

      for (Object stipulation: stipulations) {
        var stip = (JSONObject) stipulation;
        formattedStipulations.append(String.format("%s\n", stip.getString("name")));
      }

      // Remove the last comma and space
      if (!formattedStipulations.isEmpty()) {
        formattedStipulations.delete(formattedStipulations.length() - 1, formattedStipulations.length());
      }

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
      params.put("customFieldGroupAssignmentId", Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue()));

      params.put("textValue", formattedStipulations);

      //default values
      params.put("dateValue", null);
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

  /**
   * Fetch design summary using Aurora's API
   *
   * 1) get aurora id
   * 2) fetch design summary
   * 3) save fields to specific param CFGA ids
   * 4) save entire json object by upserting into given param CFGA id
   *
   * @param func The DB function being ran
   * @param systemValues System/context values
   */
  @Transactional
  public void getDesignSummary(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {

      log.info(systemValues.toString());

      Long ppsId = Long.parseLong(systemValues.get("ppsId").toString());
      //This is hardcoded to the specific custom field group assignment ID of the used custom field. Not ideal
      Long designCfgaId = 22560L;

      log.info("ZZZ debug 0");

      String designId = auroraService.getDesignId(ppsId, designCfgaId);
      if (designId == null) {
        throw new RuntimeException("Unable to fetch design ID");
      }

      log.info("ZZZ debug 1");

      AuroraProxy.DesignSummary designResponse = auroraService.getDesignSummary(designId);

      log.info("ZZZ debug 2");

      var design = designResponse.getFields().get("design");
      int productionEstimate = (int) Double.parseDouble(design.get("energy_production").get("annual").toString());
      var stringInverters = design.get("string_inverters"); //account for empty array
      var arrays = design.get("arrays");
      int panelQuantity = 0;
      String manufacturer = null;
      String inverter = null;

      log.info("ZZZ debug 3");

      if (!arrays.isEmpty()) {
        //this is returning with extra quotes around the string ¯\_(ツ)_/¯
        manufacturer = arrays.get(0).get("module").get("manufacturer").toString().replace("\"", "");

        for (JsonNode array : arrays) {
          if (array.has("module")) {
            panelQuantity += Integer.parseInt(array.get("module").get("count").toString());
          }
        }
      }

      if (!stringInverters.isEmpty()) {
        inverter = stringInverters.get(0).get("name").toString();
      }

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", ppsId);

      log.info("ZZZ debug 4");

      for(ActionParamDynamicValue dynamicValue : func.getActionParamDynamicValues()) {
        final String paramName = dynamicValue.getParameterName();
        var cfgaId = Long.parseLong(dynamicValue.getDynamicValue());
        params.put("customFieldGroupAssignmentId", cfgaId);

        //default values
        params.put("dateValue", null);
        params.put("textValue", null);
        params.put("timestampValue", null);
        params.put("booleanValue", false);
        params.put("numericValue", null);
        params.put("intValue", null);
        params.put("intArrayValue", null);
        params.put("jsonValue", null);

        log.info("ZZZ debug CDGA ID: " + cfgaId);

        //IDing by field name is about a generic as we can get as of now, but not ideal
        if (paramName.contains("System Size")) {
          params.put("numericValue", new BigDecimal(design.get("system_size_stc").toString()));
          sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
        } else if (paramName.contains("Panel Quantity")) {
          params.put("intValue", panelQuantity);
          sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
        } else if (paramName.contains("Production Estimate")) {
          params.put("intValue", productionEstimate);
          sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
        } else if (paramName.contains("Panel Brand")) {
          if (manufacturer != null) {
            Long lovId = sqlCache.queryForObject("customFieldValue.getListOfValueIdByCfgaIdAndName", Map.of("cfgaId", cfgaId, "name", manufacturer), Long.class);
            params.put("intValue", lovId);
          }
          sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
        } else if (paramName.contains("Inverter Brand")) {
          if (inverter != null) {
            Long lovId = sqlCache.queryForObject("customFieldValue.getListOfValueIdByCfgaIdAndName", Map.of("cfgaId", cfgaId, "name", inverter), Long.class);
            params.put("intValue", lovId);
          }
          sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
        } else if (paramName.contains("Design JSON")) {
          //store the entire json object for future proposal log history calculations
          params.put("jsonValue", design.toString());
          sqlCache.update("customFieldValue.upsertAuroraDesign", params);
        }
      }
    } catch (Exception e) {
      final String originalFuncName = func.getFunctionName();
      final int dot = originalFuncName.indexOf('.');
      final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));

      throw new RuntimeException(String.format("PPS: Unable to perform MANUAL action for java function: %s *** %s", functionName, e.getMessage()));
    }
  }
}
