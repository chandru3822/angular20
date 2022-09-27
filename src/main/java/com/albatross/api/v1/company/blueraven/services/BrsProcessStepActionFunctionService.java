package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.GoodleapDocumentStatus;
import com.albatross.api.v1.company.blueraven.models.MarketoProject;
import com.albatross.api.v1.flow.model.ActionParamDynamicValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.processStep.ProcessStepActionChildFunction;
import com.albatross.api.v1.flow.services.ListOfValueService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * This class is to hold functions performed by actions which peform async http calls.
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

    private final MarketoService marketoService;

    private final ListOfValueService listOfValueService;

    private final ProjectService projectService;

    private String formatErrorMessage(ProcessStepActionChildFunction func, String message) {
        final String originalFuncName = func.getFunctionName();
        final int dot = originalFuncName.indexOf('.');
        final String functionName = CleanString.snakeToCamel(originalFuncName.substring(dot + 1));
        final String functionType = (func.getRunInBackend()) ? "MANUAL" : "AUTOTRIGGER";

        throw new RuntimeException(String.format("PPS: Unable to perform %s action for java function: %s *** %s", functionType, functionName, message));
    }

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
            params.put("richTextValue", null);

            sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
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
            params.put("booleanValue", false);
            params.put("numericValue", null);
            params.put("intValue", null);
            params.put("intArrayValue", null);
            params.put("richTextValue", null);

            sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
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
            params.put("booleanValue", false);
            params.put("numericValue", null);
            params.put("intValue", null);
            params.put("intArrayValue", null);
            params.put("richTextValue", null);

            sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
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
            params.put("booleanValue", false);
            params.put("numericValue", null);
            params.put("intValue", null);
            params.put("intArrayValue", null);
            params.put("richTextValue", null);

            sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
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
            params.put("booleanValue", false);
            params.put("numericValue", null);
            params.put("intValue", null);
            params.put("intArrayValue", null);
            params.put("richTextValue", null);

            sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
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
            params.put("richTextValue", null);

            sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
        } catch (Exception e) {
            throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
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
     * @param func         The DB function being ran
     * @param systemValues System/context values
     */
    @Transactional
    public void getDesignSummary(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
        try {

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

            if (!arrays.isEmpty()) {
                //this is returning with extra quotes around the string ¯\_(ツ)_/¯
                manufacturer = arrays.get(0).get("module").get("manufacturer").toString().replace("\"", "");
                panelWatts = Math.round(Float.parseFloat(arrays.get(0).get("module").get("rating_stc").toString()));
                inverter = arrays.get(0).get("microinverter").get("name").toString();

                for (JsonNode array : arrays) {
                    if (array.has("module")) {
                        panelQuantity += Integer.parseInt(array.get("module").get("count").toString());
                    }
                }
            }

            if (inverter == null) {
                var inverters = design.get("string_inverters");
                if (!inverters.isEmpty()) {
                    inverter = inverters.get(0).get("name").toString();
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
                params.put("booleanValue", false);
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
                        final String javaSucksInverter = inverter.replace("\"", "");
                        //this is as general as I can make it as of now...
                        final long companyId = Long.parseLong(systemValues.get("companyId").toString());
                        final String sql = "select id from flow.custom_field cf where field_name = 'Inverter Brand' and company_id = " + companyId;
                        Long customFieldId = sqlCache.queryForObjectBySql(sql, null, Long.class);
                        List<ListOfValue> values = listOfValueService.getByCustomFieldId(customFieldId);
                        final Long inverterLovId = values.stream()
                                                         .filter(i -> Objects.equals(i.getCode(), javaSucksInverter))
                                                         .map(ListOfValue::getId)
                                                         .findFirst()
                                                         .orElse(null);
                        if (inverterLovId != null) {
                            params.put("intValue", inverterLovId);
                            sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
                        }
                        //@TODO: might be good to fail here if an inverter comes back from aurora but we can't identify it? Maybe add to the error log screen?
                    }
                } else if (paramName.contains("Panel Watts")) {
                    params.put("intValue", panelWatts);
                    sqlCache.update("customFieldValues.process_step.upsertCustomFieldValue", params);
                } else if (paramName.contains("Design JSON")) {
                    //store the entire json object for future proposal log history calculations
                    params.put("jsonValue", design.toString());
                    sqlCache.update("customFieldValue.upsertAuroraDesign", params);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
        }
    }

    public void pushDataToMarketo(ProcessStepActionChildFunction func, Map<String, Object> systemValues) {
        final Long projectId = Long.parseLong(systemValues.get("projectId").toString());
        MarketoProject project = sqlCache.get("marketo.getProject", Map.of("projectId", projectId), MarketoProject.class)
                                           .orElse(null);

        if (project == null) {
            throw new RuntimeException(formatErrorMessage(func, "Unable to find project from given projectId"));
        }

        try {
            Map<String, Object> lead = marketoService.projectToLead(project);
            List<ActionParamDynamicValue> paramValues = func.getActionParamDynamicValues();

            final String projectStatusParam = paramValues.get(0).getDynamicValue();
            if (projectStatusParam != null && !projectStatusParam.isBlank()) {

                if (projectStatusParam.trim().equalsIgnoreCase("Final Design Sent")) {
                    LocalDateTime yesterday = LocalDateTime.now().minusDays(1);
                    if (project.getFinalDesignSentToHomeownerDate().isAfter(yesterday)) {
                        lead.put("projectStatus", projectStatusParam);
                    }
                } else {
                    lead.put("projectStatus", projectStatusParam);
                }
            }

            Optional<Map<String, Object>> results;

            //@TODO: final design sent. Need to only update status to that if it's the first time it's been updated.
            // probably the CFV audit table and make sure it's the first entry with that cfgaId

            //closerAppointmentStartTime
            final String closerAppointmentRawValue = paramValues.get(1).getDynamicValue();
            if (closerAppointmentRawValue != null && !closerAppointmentRawValue.isBlank()) {
                final Long closerAppointmentPseId = Long.parseLong(closerAppointmentRawValue);
                results = sqlCache.get("marketo.getStartTimeByProcessStepEventId", Map.of("pseId", closerAppointmentPseId, "projectId", projectId), new ColumnMapRowMapper());
                results.ifPresent(r -> lead.put("closerAppointmentStartTime", marketoService.formatDateTime(r.get("startTime"))));
            }

            //installationStartTime
            final String installationRawValue = paramValues.get(2).getDynamicValue();
            if (installationRawValue != null && !installationRawValue.isBlank()) {
                final Long installationStartTimePseId = Long.parseLong(installationRawValue);
                results = sqlCache.get("marketo.getStartTimeByProcessStepEventId", Map.of("pseId", installationStartTimePseId, "projectId", projectId), new ColumnMapRowMapper());
                results.ifPresent(r -> lead.put("installationStartTime", marketoService.formatDateTime(r.get("startTime"))));
            }

            //substantialCompletionDate
            final String substantialRawValue = paramValues.get(3).getDynamicValue();
            if (substantialRawValue != null && !substantialRawValue.isBlank()) {
                final Long substantialCompletionDateCfgaId = Long.parseLong(substantialRawValue);
                results = sqlCache.get("marketo.getPpsFieldValueByCfgaId", Map.of("cfgaId", substantialCompletionDateCfgaId, "projectId", projectId), new ColumnMapRowMapper());
                results.ifPresent(r -> lead.put("substantialCompletionDate", r.get("dateValue").toString()));
            }

            //inspectionStartTime
            final String inspectionRawValue = paramValues.get(4).getDynamicValue();
            if (inspectionRawValue != null && !inspectionRawValue.isBlank()) {
                final Long inspectionStartTimePseId = Long.parseLong(inspectionRawValue);
                results = sqlCache.get("marketo.getStartTimeByProcessStepEventId", Map.of("pseId", inspectionStartTimePseId, "projectId", projectId), new ColumnMapRowMapper());
                results.ifPresent(r -> lead.put("inspectionStartTime", marketoService.formatDateTime(r.get("startTime"))));
            }

            //inspectionPassedDate
            final String inspectionPassedRawValue = paramValues.get(5).getDynamicValue();
            if (inspectionPassedRawValue != null && !inspectionPassedRawValue.isBlank()) {
                final Long inspectionPassedDateCfgaId = Long.parseLong(inspectionPassedRawValue);
                results = sqlCache.get("marketo.getPpsFieldValueByCfgaId", Map.of("cfgaId", inspectionPassedDateCfgaId, "projectId", projectId), new ColumnMapRowMapper());
                results.ifPresent(r -> lead.put("inspectionPassedDate", r.get("dateValue").toString()));
            }

            //energizedDate
            final boolean updateEnergizedDate = Boolean.parseBoolean(paramValues.get(6).getDynamicValue());
            if (updateEnergizedDate) {
                lead.put("energizedDate", project.getEnergizedDate());
            }

            //finalDesignApprovedDate
            final boolean updateFinalDesignApprovedDate = Boolean.parseBoolean(paramValues.get(7).getDynamicValue());
            if (updateFinalDesignApprovedDate) {
                if (project.getFinalDesignApprovedDate() != null) {
                    lead.put("finalDesignApprovedDate", project.getFinalDesignApprovedDate());
                }
            }

            try {
                marketoService.pushData(List.of(lead));
            } catch (Exception e) {
                throw new RuntimeException(e.getMessage());
            }
        } catch (Exception e) {
            throw new RuntimeException(formatErrorMessage(func, e.getMessage()));
        }
    }
}
