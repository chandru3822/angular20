package com.albatross.api.v1.flow.services;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.ProjectTagMessage;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeService;
import com.albatross.api.v1.company.blueraven.services.*;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.SystemActivity;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.model.projectProcessStep.*;
import com.albatross.api.v1.flow.queries.*;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;


//@TODO: Had to make private functions public in this class to be able to unit test due to this issue. https://github.com/powermock/powermock/issues/929
// I don't like it and would rather have them be private. Change back if/when possible

@Slf4j
@Service
@RequiredArgsConstructor
public class AutoTriggerHandlerService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ProjectProcessStepService projectProcessStepService;

  public void handlePpsAutoTriggersAfterStatusUpdate(Long projectProcessStepId) {
      try {
          List<ProjectProcessStepService.PpsActionResult> actionResults = new ArrayList<>();
          actionResults.add(projectProcessStepService.performAutoTriggerActions(
                  projectProcessStepId, securityService.getCurrentUserDetails()));

          // check for any actions using this PS - Status as a requirement - NOT including SELF
          // (because that creates a potential infinite loop) if active
          // run auto triggers for those actions
          List<ProjectProcessStep> steps =
                  sqlCache.queryBySql(ProjectProcessStepQuery.getUsingStatusByPpsIds,
                          Map.of("projectProcessStepIds", List.of(projectProcessStepId)),
                          ProjectProcessStep.class);
          for (ProjectProcessStep step : steps) {
              // only run if the referring PPS is active
              if (step.getProcessStepStatusTypeId() == 1) {
                  actionResults.add(projectProcessStepService.performAutoTriggerActions(
                          step.getProjectProcessStepId(), securityService.getCurrentUserDetails()));
              }
          }

          boolean doTagUpdate = actionResults.stream().anyMatch(ProjectProcessStepService.PpsActionResult::getShouldRunProjectTagUpdate);
          List<Long> ppsIds = new ArrayList<>();
          ppsIds.add(projectProcessStepId);
          projectProcessStepService.updateProjectTagsViaRedis(doTagUpdate, null, ppsIds);

      } catch (Exception e) {
          final String errMessage =

                  "PPS: Unable to AUTO trigger actions on PPS ID: %s *** %s".formatted(
                          projectProcessStepId, e.getMessage());
          log.error(errMessage);
          throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
      }
  }

  public void handlePpsAutoTriggersAfterCfvUpdate(Long projectId, Long projectProcessStepId, List<CustomFieldValue> values) {
      List<ProjectProcessStepService.PpsActionResult> actionResults = new ArrayList<>();
      try {
          actionResults.add(projectProcessStepService.performAutoTriggerActions(
                  projectProcessStepId, securityService.getCurrentUserDetails()));

          // grab all PPS where the updated fields are ancillary and perform auto triggers there
          List<Long> cfgaIds =
                  values.stream().map(CustomFieldValue::getCustomFieldGroupAssignmentId).toList();
          if (!cfgaIds.isEmpty()) {
              List<Long> ppsIds =
                      projectProcessStepService.getIdsForAutoTriggerByCfgaIds(projectId, null, cfgaIds);
              for (Long ppsId : ppsIds) {
                  // Don't re-check the ppsId we just previously did
                  if (!ppsId.equals(projectProcessStepId)) {
                      actionResults.add(projectProcessStepService.performAutoTriggerActions(
                              ppsId, securityService.getCurrentUserDetails()));
                  }
              }
              boolean doTagUpdate = actionResults.stream().anyMatch(ProjectProcessStepService.PpsActionResult::getShouldRunProjectTagUpdate);
              projectProcessStepService.updateProjectTagsViaRedis(doTagUpdate, null, ppsIds);
          }
      } catch (Exception e) {
          throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage());
      }
  }

}
