package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.disclosureForm.DisclosureFormService;
import com.albatross.api.solargraf.SolargrafProxy;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.GoodleapDocumentStatus;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeCheckInType;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeReviewInvitation;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeService;
import com.albatross.api.v1.company.blueraven.models.MarketoProject;
import com.albatross.api.disclosureForm.Srec;
import com.albatross.api.v1.company.blueraven.services.queries.MarketoQuery;
import com.albatross.api.v1.flow.model.ActionParamDynamicValue;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.processStep.ProcessStepActionChildFunction;
import com.albatross.api.v1.flow.queries.ContactQuery;
import com.albatross.api.v1.flow.queries.ApiQuery;
import com.albatross.api.v1.flow.queries.customFieldValues.CustomFieldValueQuery;
import com.albatross.api.v1.flow.queries.customFieldValues.ProcessStepCfvQuery;
import com.albatross.api.v1.flow.services.ListOfValueService;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.StreamSupport;

/**
 * This class is to hold functions performed by actions which perform http calls.
 * Each function should take the action function being ran (ProcessStepActionChildFunction) and a map of system values (this hold contextual values given from the action).
 * Each function should return void and throw a descriptive exception on failure (exceptions are handled within the action code for transactional purposes).
 */

@Slf4j
@RequiredArgsConstructor
@Service
public class BrsProcessStepActionFunctionService {

  private final SqlCache sqlCache;

  private final GoodleapService goodleapService;

  private final AuroraProxy auroraService;

  private final KlaviyoService klaviyoService;

  private final SolargrafProxy solargrafService;

  private final MarketoService marketoService;

  private final CustomerPortalService customerPortalService;

  private final ListOfValueService listOfValueService;

  private final BirdEyeService birdeyeService;

  private final StripeService stripeService;

  private final DisclosureFormService disclosureFormService;


  // @TODO: I would like this to have the usual @Value annotation to the marketo cron flag, but it doesn't work with the manual class instantiation used
  public Boolean klaviyoEnabled;
  public Boolean marketoEnabled;
  public Boolean ignoreAuroraErrors;

  private String formatErrorMessage(ProcessStepActionChildFunction func, String message) {
    final String originalFuncName = func.getFunctionName();
    final int dot = originalFuncName.indexOf('.');
    final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));
    final String functionType = (func.getRunInBackend()) ? "MANUAL" : "AUTOTRIGGER";

    throw new RuntimeException("PPS: Unable to perform %s action for java function: %s *** %s".formatted(functionType, functionName, message));
  }


  public void getLoanDocsSentDate(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {

    try {
      long projectId = Long.parseLong(systemValues.get("projectId").toString());
      JSONObject application = goodleapService.getApplicationByProjectId(projectId, true);

      Long cfgaId = Long.parseLong(func.getActionParamDynamicValues().get(0).getDynamicValue());
      if (cfgaId != null && cfgaId > 0) {
        //ensure that cfgaId is a valid id
        HashMap<String, Object> params = new HashMap<>();
        params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
        params.put("sourceId", Long.parseLong(systemValues.get("ppsId").toString()));
        params.put("customFieldGroupAssignmentId", cfgaId);

        LocalDate sentAt = null;

        if (!application.isNull("docsSentAt")) {
          sentAt = LocalDate.parse(application.getString("docsSentAt"), DateTimeFormatter.ISO_DATE_TIME);
        }

        params.put("dateValue", sentAt);

        //default values
        params.put("textValue", null);
        params.put("timestampValue", null);
        params.put("booleanValue", null);
        params.put("numericValue", null);
        params.put("intValue", null);
        params.put("intArrayValue", null);
        params.put("richTextValue", null);

        sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
      } else {
        //we think that sometimes this code fails to find a cfgaId. adding this log/code to help isolate and find out when/why
        log.error("ACTION FUNCTION: Could not find cfgaId for project {}", projectId);
        throw new RuntimeException(formatErrorMessage(func, "cfga not found"));
      }
    } catch (GoodleapService.NotFoundException e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
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
      params.put("booleanValue", null);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);
      params.put("richTextValue", null);

      sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
    } catch (GoodleapService.NotFoundException e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
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
      params.put("booleanValue", null);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);
      params.put("richTextValue", null);

      sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
    } catch (GoodleapService.NotFoundException e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
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
      params.put("booleanValue", null);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);
      params.put("richTextValue", null);

      sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
    } catch (GoodleapService.NotFoundException e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
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
      params.put("booleanValue", null);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);
      params.put("richTextValue", null);

      sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
    } catch (Exception e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
    }
  }

  public void getLoanStipulations(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
      JSONArray stipulations = goodleapService.getApplicationStipulations(Long.parseLong(systemValues.get("projectId").toString()));
      StringBuilder formattedStipulations = new StringBuilder();

      for (Object stipulation : stipulations) {
        var stip = (JSONObject) stipulation;
        formattedStipulations.append("%s\n".formatted(stip.getString("name")));
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
      params.put("booleanValue", null);
      params.put("numericValue", null);
      params.put("intValue", null);
      params.put("intArrayValue", null);
      params.put("richTextValue", null);

      sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
    } catch (Exception e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
    }
  }

  @Transactional
  public void getSolargrafSummary(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
      List<Map<String, Object>> apiConfigs = sqlCache.queryBySql(ApiQuery.getApiConfig,null, new ColumnMapRowMapper());
      Long ppsId = Long.parseLong(systemValues.get("ppsId").toString());
      String solargrafCfgaId = func.getActionParamDynamicValues().stream()
        .filter(p -> p.getParameterName().contains("Solargraf Design ID"))
        .map(ActionParamDynamicValue::getDynamicValue)
        .findFirst()
        .orElse(null);

      if (solargrafCfgaId == null) {
        throw new RuntimeException("Unable to locate Solargraf ID custom field");
      }

      String solargrafUrl = solargrafService.getSolargrafId(ppsId, Long.parseLong(solargrafCfgaId));
      //solargrafId = "2408140";
      if (solargrafUrl == null) {
        throw new RuntimeException("Unable to fetch Solargraf ID from Solargraf");
      }

      Pattern pattern = Pattern.compile("/projects/(\\d+)/proposals/([a-f0-9\\-]+)/");
      Matcher matcher = pattern.matcher(solargrafUrl);
      String projectId = null;
      String proposalId = null;
      if (matcher.find()) {
        projectId = matcher.group(1);
        proposalId = matcher.group(2);

      } else {
        System.out.println("No match found.");
      }

      SolargrafProxy.SolargrafPanelArrays panelArrays;
      SolargrafProxy.SolargrafMaterials materials;
      SolargrafProxy.SolargrafProductions productions;
      SolargrafProxy.SolargrafStorage storage;


      try {
        panelArrays = solargrafService.getSolargrafPanelArrays(projectId);
      } catch (Exception e) {
        throw new RuntimeException("Unable to fetch panel arrays from solargraf");
      }

      try {
        materials = solargrafService.getSolargrafMaterials(projectId);
      } catch (Exception e) {
        throw new RuntimeException("Unable to fetch materials from solargraf");
      }

      try {
        productions = solargrafService.getSolargrafProduction(projectId);
      } catch (Exception e) {
        throw new RuntimeException("Unable to fetch Production from solargraf");
      }

      try {
        storage = solargrafService.getSolargrafStorage(projectId);
      } catch (Exception e) {
        throw new RuntimeException("Unable to fetch storage from solargraf");
      }

      JsonNode pa = null;
      for (JsonNode items : panelArrays.getFields().path("data")) {
        for (JsonNode item : items) {
          JsonNode attributes = item.path("attributes");
          String proposal = attributes.path("proposalId").asText();
          if (proposal.equalsIgnoreCase(proposalId)) {
            pa = items;
            break;
          }
        }
      }

      JsonNode st = null;
      for (JsonNode storageItems : storage.getFields().path("data")) {
          String storageProposalId = storageItems.path("id").asText();
          if (storageProposalId.equalsIgnoreCase(proposalId)) {
            st = storageItems;
            break;
          }
      }
      String storageType = null;
      int storageTypeId = 0;
      if (st != null) {
        storageType = st.get("attributes").get("batteryProfile").asText();
        storageTypeId  =  getIdForAPI(storageType,apiConfigs);
      }
      double systemSize = 0;
      if(pa != null) {
           systemSize = StreamSupport.stream(pa.spliterator(), false)
          .map(jn -> jn.get("attributes").get("panelArrays").get("sizeInWatts"))
          .map(JsonNode::toString)
          .mapToDouble(Double::parseDouble)
          .sum();
      }

      //panel quantity
      double panelQuantity = 0;
      if(pa != null) {
           panelQuantity = StreamSupport.stream(pa.spliterator(), false)
          .map(jn -> jn.get("attributes").get("panelArrays").get("count"))
          .map(JsonNode::toString)
          .mapToDouble(Double::parseDouble)
          .sum();
      }
      //panel Manufacturer
      String panelBrand = null;
      double panelSizeInWatts = 0;
      String panelName = null;
      if(pa != null) {
        panelBrand = pa.get(0).get("attributes").get("panelArrays").get("panelManufacturer").asText();
        panelSizeInWatts = pa.get(0).get("attributes").get("panelArrays").get("panelSizeInWatts").asDouble();
        panelName = pa.get(0).get("attributes").get("panelArrays").get("panelName").asText();
      }

      //production Estimate
      JsonNode ps = productions.getFields().get("data");
      JsonNode production = null;
      for (JsonNode prodItems : ps) {

          JsonNode attributes = prodItems.path("attributes");
          String proposal = attributes.path("proposalId").asText();
          if (proposal.equalsIgnoreCase(proposalId)) {
            production = prodItems;
            break;
          }
      }
      double productionEstimate = 0;
      if (production != null) {
       productionEstimate = production.get("attributes").get("dcAnnual").asDouble();
      }

      int panelBrandId  =  getIdForAPI(panelBrand,apiConfigs);

      String inverterName = null;
      String manufacturerName = null;
      for (JsonNode item : materials.getFields().get("data")) {
        String materialType = item.path("attributes").path("materialType").asText();
        JsonNode proposalIdsNode = item.path("attributes").path("proposalIds");
        if (proposalId != null){
        for (JsonNode pid : proposalIdsNode) {
            if (proposalId.equals(pid.asText())) {
              if ("panel".equalsIgnoreCase(materialType)) {
                manufacturerName = item.path("attributes")
                  .path("manufacturer")
                  .path("name")
                  .path("en")
                  .asText();
              } else if ("inverter".equalsIgnoreCase(materialType)) {
                inverterName = item.path("attributes")
                  .path("name")
                  .path("en")
                  .asText();
              }
            }
          }
        }
      }
      int inverterId  =  getIdForAPI(inverterName,apiConfigs);

      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", ppsId);

      for (ActionParamDynamicValue dynamicValue : func.getActionParamDynamicValues()) {
        final String paramName = dynamicValue.getParameterName();
        var cfgaId = Long.parseLong(dynamicValue.getDynamicValue());
        params.put("customFieldGroupAssignmentId", cfgaId);

        //default values
        params.put("dateValue", null);
        params.put("textValue", null);
        params.put("timestampValue", null);
        params.put("booleanValue", null);
        params.put("numericValue", null);
        params.put("intValue", null);
        params.put("intArrayValue", null);
        params.put("richTextValue", null);
        params.put("jsonValue", null);

        //IDing by field name is about a generic as we can get as of now, but not ideal
        if (paramName.contains("System Size")) {
          // Divide by 1000 to get kilowatt system size
          double systemSizeInKw = systemSize / 1000;
          params.put("numericValue", systemSizeInKw);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Panel Quantity")) {
          params.put("intValue", panelQuantity);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Production Estimate")) {
          params.put("intValue", productionEstimate);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } //Panel Brand section
        else if (paramName.contains("Panel Brand") && panelBrandId != 0 ){
          params.put("intValue", panelBrandId);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        }
       else if (paramName.contains("Inverter Brand") && inverterId != 0 ) {
          params.put("intValue", inverterId);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        }
        else if (paramName.contains("Panel Watts")) {
          params.put("intValue", panelSizeInWatts);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Solargraf Production")) {
          //store the entire json object for future proposal log history calculations
          params.put("jsonValue", productions.getFields().toString());
          sqlCache.updateBySql(CustomFieldValueQuery.upsertAuroraDesign, params);
        } else if (paramName.contains("Solargraf Materials")) {
          //store the entire json object for future proposal log history calculations
          params.put("jsonValue", materials.getFields().toString());
          sqlCache.updateBySql(CustomFieldValueQuery.upsertAuroraDesign, params);
        }
        else if (paramName.contains("Solargraf Panel")) {
          //store the entire json object for future proposal log history calculations
          params.put("jsonValue", panelArrays.getFields().toString());
          sqlCache.updateBySql(CustomFieldValueQuery.upsertAuroraDesign, params);
        }
        else if (paramName.contains("Panel Name")) {
          params.put("textValue", panelName);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        }
       else if (paramName.contains("Storage Type") && !storageType.equals("null")) {
          params.put("intValue", storageTypeId);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        }
      }
    } catch (Exception e) {
        throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
    }
  }
  /**
   * Fetch design summary using Aurora's API
   * <p>
   * 1) get aurora id
   * 2) fetch design summary
   * 3) save fields to specific param CFGA ids
   * 4) save entire json object by upserting into given param CFGA id
   *
   * @param func         The DB function being ran
   * @param systemValues System/context values
   */
  @Transactional
  public void getDesignSummary(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
      List<Map<String, Object>> apiConfigs = sqlCache.queryBySql(ApiQuery.getApiConfig,null, new ColumnMapRowMapper());
      Long ppsId = Long.parseLong(systemValues.get("ppsId").toString());
      String designCfgaId = func.getActionParamDynamicValues().stream()
        .filter(p -> p.getParameterName().contains("Aurora Design ID"))
        .map(ActionParamDynamicValue::getDynamicValue)
        .findFirst()
        .orElse(null);

      if (designCfgaId == null) {
        throw new RuntimeException("Unable to locate Aurora Design ID custom field");
      }

      String designId = auroraService.getDesignId(ppsId, Long.parseLong(designCfgaId));
      if (designId == null) {
        throw new RuntimeException("Unable to fetch design ID from Aurora");
      }

      AuroraProxy.DesignSummary designResponse;

      try {
        designResponse = auroraService.getDesignSummary(designId);
      } catch (Exception e) {
        throw new RuntimeException("Unable to fetch design summary from Aurora");
      }

      var design = designResponse.getFields().get("design");
      int productionEstimate = (int) Double.parseDouble(design.get("energy_production").get("annual").toString());
      var arrays = design.get("arrays");
      int panelQuantity = 0;
      int panelWatts = 0;
      String manufacturer = null;
      String inverter = null;
      String panelName = null;
      String storageType = design.get("storage_selected_operating_mode").toString().replace("\"", "");
      int inverterId = 20063;

      if (!arrays.isEmpty()) {
        //this is returning with extra quotes around the string ¯\_(ツ)_/¯
        if(null != arrays.get(0).get("module").get("manufacturer")) {
          manufacturer = arrays.get(0).get("module").get("manufacturer").toString().replace("\"", "");
        }
        if(null != arrays.get(0).get("module").get("name")) {
          panelName = arrays.get(0).get("module").get("name").toString().replace("\"", "");
        }
        if(null != arrays.get(0).get("module").get("rating_stc")) {
          panelWatts = Math.round(Float.parseFloat(arrays.get(0).get("module").get("rating_stc").toString()));
        }

        if (arrays.get(0).get("microinverter") != null) {
          inverter = arrays.get(0).get("microinverter").get("name").toString().replace("\"", "");
           inverterId  =  getIdForAPI(inverter,apiConfigs);
        }

        for (JsonNode array : arrays) {
          if (array.has("module")) {
            panelQuantity += Integer.parseInt(array.get("module").get("count").toString().replace("\"", ""));
          }
        }
      }

      if (inverter == null) {
        var inverters = design.get("string_inverters");
        if (!inverters.isEmpty()) {
          inverter = inverters.get(0).get("name").toString().replace("\"", "");
           inverterId  =  getIdForAPI(inverter,apiConfigs);
        }
      }


      HashMap<String, Object> params = new HashMap<>();
      params.put("userId", Long.parseLong(systemValues.get("userId").toString()));
      params.put("sourceId", ppsId);

      for (ActionParamDynamicValue dynamicValue : func.getActionParamDynamicValues()) {
        final String paramName = dynamicValue.getParameterName();
        var cfgaId = Long.parseLong(dynamicValue.getDynamicValue());
        params.put("customFieldGroupAssignmentId", cfgaId);

        //default values
        params.put("dateValue", null);
        params.put("textValue", null);
        params.put("timestampValue", null);
        params.put("booleanValue", null);
        params.put("numericValue", null);
        params.put("intValue", null);
        params.put("intArrayValue", null);
        params.put("richTextValue", null);
        params.put("jsonValue", null);

        //IDing by field name is about a generic as we can get as of now, but not ideal
        if (paramName.contains("System Size")) {
          // Divide by 1000 to get kilowatt system size
          float systemSizeInKw = Float.parseFloat(design.get("system_size_stc").toString()) / 1000;
          params.put("numericValue", systemSizeInKw);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Panel Quantity")) {
          params.put("intValue", panelQuantity);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Production Estimate")) {
          params.put("intValue", productionEstimate);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Panel Brand")) {
          if (manufacturer != null) {
            try {
              Long lovId = sqlCache.queryForObjectBySql(CustomFieldValueQuery.getListOfValueIdByCfgaIdAndName, Map.of("cfgaId", cfgaId, "name", manufacturer), Long.class);
              params.put("intValue", lovId);
              sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
            } catch (EmptyResultDataAccessException e) {
              if(!ignoreAuroraErrors) {
                throw new RuntimeException("Unable to find list item for given panel brand");
              }
            }
          } else if (!ignoreAuroraErrors ){
            throw new RuntimeException("Unable to find list item for given panel brand");
          }
        } else if (paramName.contains("Inverter Brand")) {
          params.put("intValue", inverterId);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Panel Watts")) {
          params.put("intValue", panelWatts);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Design JSON")) {
          //store the entire json object for future proposal log history calculations
          params.put("jsonValue", design.toString());
          sqlCache.updateBySql(CustomFieldValueQuery.upsertAuroraDesign, params);
        } else if (paramName.contains("Panel Name")) {
          params.put("textValue", panelName);
          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        } else if (paramName.contains("Storage Type") && !storageType.equals("null")) {
          int storageTypeLovId =  getIdForAPI(storageType,apiConfigs);
          if (storageTypeLovId != 0) {
            params.put("intValue", storageTypeLovId);
            sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
          } else {
            if(!ignoreAuroraErrors) {
              throw new RuntimeException("Unable to find list item for given storage type");
            }
          }
        }
      }
    } catch (Exception e) {
      if(!ignoreAuroraErrors) {
        throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
      }
    }
  }

  public void pushDataToMarketo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    if (marketoEnabled) {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      MarketoProject project = sqlCache.getBySql(MarketoQuery.getProject, Map.of("projectId", projectId), MarketoProject.class)
        .orElse(null);

      if (project == null) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
      }

      try {
        Map<String, Object> lead = marketoService.projectToLead(project);
        List<ActionParamDynamicValue> paramValues = func.getActionParamDynamicValues();

        final String projectStatusParam = paramValues.get(0).getDynamicValue();
        if (projectStatusParam != null && !projectStatusParam.isBlank()) {
          lead.put("projectStatus", projectStatusParam);
        }

        if (project.getFinalDesignApprovedDate() == null) {
          lead.remove("finalDesignApprovedDate");
        }

        try {
          marketoService.pushData(List.of(lead));
        } catch (Exception e) {
          // This is a bandaid fix to let actions run while adobe/marketo get their act together
//          throw new RuntimeException(e.getMessage());
          log.error(String.format("MARKETO: Unable to update Marketo during action: %s", e.getMessage()));
        }
      } catch (Exception e) {
        // This is a bandaid fix to let actions run while adobe/marketo get their act together
//        throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
        log.error(String.format("MARKETO: Unable to update Marketo during action: %s", e.getMessage()));
      }
    }
  }

  public void postUnqualifiedEventToKlaviyo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    if (klaviyoEnabled) {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      try {
        klaviyoService.postUnqualifiedEvent(projectId);
      }
      catch (RuntimeException e) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
      }
      catch (Exception e) {
        log.error(String.format("KLAVIYO: %s", e.getMessage()));
      }
    }
  }

  public void postBookedEventToKlaviyo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    if (klaviyoEnabled) {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      try {
        klaviyoService.postBookedEvent(projectId);
      }
      catch (RuntimeException e) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
      }
      catch (Exception e) {
        log.error(String.format("KLAVIYO: %s", e.getMessage()));
      }
    }
  }

  public void postFinalDesignCompletedEventToKlaviyo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    if (klaviyoEnabled) {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      try {
        klaviyoService.postFinalDesignCompletedEvent(projectId);
      }
      catch (RuntimeException e) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
      }
      catch (Exception e) {
        log.error(String.format("KLAVIYO: %s", e.getMessage()));
      }
    }
  }

  public void postAppointmentSetEventToKlaviyo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    if (klaviyoEnabled) {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      try {
        klaviyoService.postAppointmentSetEvent(projectId);
      }
      catch (RuntimeException e) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
      }
      catch (Exception e) {
        log.error(String.format("KLAVIYO: %s", e.getMessage()));
      }
    }
  }

  public void postPitchedEventToKlaviyo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    if (klaviyoEnabled) {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      try {
        klaviyoService.postPitchedEvent(projectId);
      }
      catch (RuntimeException e) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
      }
      catch (Exception e) {
        log.error(String.format("KLAVIYO: %s", e.getMessage()));
      }
    }
  }

  public void postSubstantialCompletionEventToKlaviyo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    if (klaviyoEnabled) {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      try {
        klaviyoService.postSubstantialCompletionEvent(projectId);
      }
      catch (RuntimeException e) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
      }
      catch (Exception e) {
        log.error(String.format("KLAVIYO: %s", e.getMessage()));
      }
    }
  }

  public String generateStripeDownPaymentCheckout(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
    final Long ppsId = Long.parseLong(systemValues.get("ppsId").toString());
    try {
      String url = stripeService.chargeProject(projectId, ppsId);
      if (url != null) {
        return url;
      }
      else {
        throw new RuntimeException(formatErrorMessage(func, "Failed Charge"));
      }

    } catch (Exception e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
    }
  }

  public void generateCustomerPortalLink(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {
      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      final Long ppsId = Long.parseLong(systemValues.get("ppsId").toString());
      final Long userId = Long.parseLong(systemValues.get("userId").toString());

      String customerPortalLink = customerPortalService.getCustomerPortalLink(projectId);
      if (customerPortalLink == null) {
        throw new RuntimeException(formatErrorMessage(func, "Unable to generate customer portal link"));
      }

      func.getActionParamDynamicValues().stream()
        .filter(p -> p.getParameterName().contains("Custom Field Group Assignment ID"))
        .map(ActionParamDynamicValue::getDynamicValue)
        .filter(Objects::nonNull)
        .map(Long::parseLong)
        .findFirst()
        .ifPresent(cfgaId -> {

          HashMap<String, Object> params = new HashMap<>();
          params.put("userId", userId);
          params.put("sourceId", ppsId);
          params.put("customFieldGroupAssignmentId", cfgaId);
          params.put("textValue", customerPortalLink);

          //default values
          params.put("dateValue", null);
          params.put("timestampValue", null);
          params.put("booleanValue", null);
          params.put("numericValue", null);
          params.put("intValue", null);
          params.put("intArrayValue", null);
          params.put("richTextValue", null);
          params.put("jsonValue", null);

          sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
        });

      final boolean pushToMarketo = Boolean.parseBoolean(func.getActionParamDynamicValues().get(1).getDynamicValue());
      if (marketoEnabled && pushToMarketo) {
        MarketoProject project = marketoService.getProject(projectId);

        if (project == null) {
          throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
        }

        HashMap<String, Object> lead = new HashMap<>();
        lead.put("projectId", project.getProjectId());
        lead.put("firstName", project.getFirstName());
        lead.put("lastName", project.getLastName());
        lead.put("email", project.getEmail());
        lead.put("phone", project.getPhone());
        lead.put("customerPortalLink", customerPortalLink);

        try {
          marketoService.pushData(List.of(lead));
        } catch (Exception e) {
          throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
    }
  }

  public void sendBirdEyeCheckIn(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    try {

      final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
      final Long companyId = Long.parseLong(systemValues.get("companyId").toString());

      Map<String, Object> params = Map.of("projectId", projectId, "parentCompanyId", companyId, "isParent", false, "companyId", companyId);
      Contact contact = sqlCache.getBySql(ContactQuery.getByProjectId, params, Contact.class)
        .orElseThrow(() -> new RuntimeException(formatErrorMessage(func, "Unable to find contact")));

      String fieldTypeValue = func.getActionParamDynamicValues().stream()
        .filter(p -> p.getParameterName().contains("Check-In Type"))
        .map(ActionParamDynamicValue::getDynamicValue)
        .filter(Objects::nonNull)
        .findFirst()
        .orElse(BirdEyeCheckInType.SITE_SURVEY.getValue());

      BirdEyeReviewInvitation invitation = new BirdEyeReviewInvitation();
      invitation.setProjectId(projectId);
      invitation.setCustomerEmail(contact.getEmail());
      invitation.setCustomerName(contact.getFullName());
      invitation.setSendSms(true);
      invitation.setAdditionalParams(Map.of(BirdEyeReviewInvitation.FIELD_TYPE_ID, fieldTypeValue));

      if (contact.getMobile() != null && !contact.getMobile().trim().equals("")) {
        invitation.setCustomerPhone(contact.getMobile());
        birdeyeService.sendCheckIn(invitation);
      } else if (contact.getPhone() != null && !contact.getPhone().trim().equals("")) {
        invitation.setCustomerPhone(contact.getPhone());
        birdeyeService.sendCheckIn(invitation);
      }
//      else {
//        throw new RuntimeException(formatErrorMessage(func, "Unable to find phone number"));
//      }

    } catch (Exception e) {
      if( !e.getMessage().equals("Not a valid phone number.") ) {
        log.error("BRS:Action Function:sendBirdEyeCheckIn");
        throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
      }
    }
  }

  /**
   * Send disclosure form and save returned form ID to given CFGA ID
   * @param func
   * @param systemValues
   */
  public void sendDisclosureForm(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
    Long projectId = Long.parseLong(systemValues.get("projectId").toString());
    List<ActionParamDynamicValue> paramValues = func.getActionParamDynamicValues();
    Long propCFGAID = Long.parseLong(paramValues.getFirst().getDynamicValue());

    Long ppsID = Long.parseLong(systemValues.get("ppsId").toString());
    Long propNbr = disclosureFormService.getProposalNumber(propCFGAID, ppsID);

    if (propNbr == null) {
      throw new RuntimeException(formatErrorMessage(func, "unable to fetch proposal number"));
    }

    Srec srec = disclosureFormService.getSrec(projectId, propNbr);

    if (srec == null) {
      throw new RuntimeException(formatErrorMessage(func, "unable to fetch proposal"));
    }

    String disclosureID = srec.getIlSrecDisclosureFormId();
    if (disclosureID == null) {
      var success = disclosureFormService.send(projectId, propNbr);
      if (!success) {
        throw new RuntimeException(formatErrorMessage(func, "unable to send disclosure form"));
      }
      srec = disclosureFormService.getSrec(projectId, propNbr);
      disclosureID = srec.getIlSrecDisclosureFormId();
    }

    Long userID = Long.parseLong(systemValues.get("userId").toString());
    Long disclosureCFGAID = Long.parseLong(paramValues.get(1).getDynamicValue());
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userID);
    params.put("sourceId", ppsID);
    params.put("customFieldGroupAssignmentId", disclosureCFGAID);
    params.put("textValue", disclosureID);
    params.put("dateValue", null);
    params.put("timestampValue", null);
    params.put("booleanValue", null);
    params.put("numericValue", null);
    params.put("intValue", null);
    params.put("intArrayValue", null);
    params.put("richTextValue", null);
    params.put("jsonValue", null);
    sqlCache.updateBySql(ProcessStepCfvQuery.upsertCustomFieldValue, params);
  }

  public static int getIdForAPI(String name, List<Map<String, Object>> apiConfigs) {
    int id = 0;

    if (name != null) {
      name = name.toLowerCase();
      for (Map<String, Object> row : apiConfigs) {
        Object nameObj = row.get("value");
        Object idObj = row.get("list_of_value_id");

        if (nameObj != null && idObj instanceof Number) {
          String configName = nameObj.toString().toLowerCase();

          if (configName.contains(name) || name.contains(configName)) {
            id = ((Number) idObj).intValue();
            break;
          }
        }
      }
    }

    return id;
  }

}
