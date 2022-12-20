package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.CompanyProcessStepStatusType;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.processStep.ProcessStepLogic;
import com.albatross.api.v1.flow.model.projectProcessStep.*;
import com.albatross.api.v1.flow.queries.ProjectProcessStepQuery;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.ProjectProcessStepRequirementService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(
    value = "/api/v1/flow/projectProcessStep",
    produces = MediaType.APPLICATION_JSON_VALUE)
public class ProjectProcessStepController {

  private final ProjectProcessStepService projectProcessStepService;

  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;

  private final SecurityService securityService;

  private final CustomFieldValueService customFieldValueService;

  private final SqlCache sqlCache;

  @GetMapping(value = "/{projectProcessStepId}")
  public ResponseEntity<ProjectProcessStep> getProjectProcessStepById(
      @PathVariable Long projectProcessStepId) {
    try {
      ProjectProcessStep pps =
          projectProcessStepService.getProjectProcessStep(projectProcessStepId);

      int index = 0;
      for (ProjectProcessStepAction a : pps.getActions()) {
        pps.getActions().set(index, projectProcessStepService.getActionResult(a.getId(), a, pps));
        index++;
      }
      //do the same thing for banners which are technically just actions of actionTypeId = 3
      int bannerIndex = 0;
      for (ProjectProcessStepAction a : pps.getBanners()) {
        pps.getBanners().set(bannerIndex, projectProcessStepService.getActionResult(a.getId(), a, pps));
        bannerIndex++;
      }

      return new ResponseEntity<>(pps, HttpStatus.OK);
    } catch (Exception e) {
      final String errMessage =
          String.format(
              "Unable to get PPS, PPS ID: %s *** %s", projectProcessStepId, e.getMessage());
      log.error(errMessage);
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }
  }

  @DeleteMapping(value = "/{projectProcessStepId}")
  public ResponseEntity<Void> deleteProjectProcessStep(@PathVariable Long projectProcessStepId) {
    try {
      projectProcessStepService.deleteProjectProcessStep(projectProcessStepId);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping(value = "/{ppsId}/history")
  public ResponseEntity<List<ProjectProcessStepHistory>> getPpsHistory(@PathVariable Long ppsId) {
    try {
      return new ResponseEntity<>(projectProcessStepService.getPpsHistory(ppsId), HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
  }

  @GetMapping(value = "/{ppsId}/actionResult/{actionId}")
  public ResponseEntity<ProjectProcessStepAction> getActionResult(
      @PathVariable Long ppsId, @PathVariable Long actionId) {
    try {
      return new ResponseEntity<>(
          projectProcessStepService.getActionResult(actionId, ppsId), HttpStatus.OK);
    } catch (Exception e) {
      final String errMessage =
          String.format(
              "Unable to get action result, action ID: %s, PPS ID: %s *** %s",
              actionId, ppsId, e.getMessage());
      log.error(errMessage);
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }
  }

  @PostMapping(value = "/{projectProcessStepId}/action/{actionId}")
  public ResponseEntity<ProjectProcessStepStatus> performAction(
      @PathVariable Long projectProcessStepId, @PathVariable Long actionId) {
    try {
      List<ProjectProcessStepService.PpsActionResult> actionResults = new ArrayList<>();
      ProjectProcessStep pps =
          projectProcessStepService.getProjectProcessStep(projectProcessStepId);
      ProjectProcessStepAction action =
          pps.getActions().stream()
              .filter(a -> a.getId().equals(actionId))
              .findFirst()
              .orElse(null);

      if (pps.getProcessStepStatusTypeId() != 1 || action == null) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }

      List<Long> requirementIds =
          action.getProcessStepLogicList().stream()
              .filter(step -> step.getProcessStepRequirementId() != null)
              .map(ProcessStepLogic::getProcessStepRequirementId)
              .collect(Collectors.toList());
      List<ProjectProcessStepRequirement> requirements =
          projectProcessStepRequirementService.getByProjectProcessStepId(
              pps.getProjectProcessStepId(), requirementIds);
      ProjectProcessStepAction actionResult =
          projectProcessStepService.canPerformAction(action, pps, requirements);
      boolean canPerform = actionResult.getCanPerform();
      if (!canPerform) {
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      }
      actionResults.add(projectProcessStepService.performAction(action, pps, new ArrayList<>()));

      // Since something on the PPS might have changed, run autotriggers for it
      actionResults.add(projectProcessStepService.performAutoTriggerActions(
          projectProcessStepId, securityService.getCurrentUserDetails()));

      // @TODO: This code to run autotriggers for ancillary fields exists in a few places.
      // Consolidate to projectProcessStepService
      // run autotriggers for ancillary fields
      List<Long> cfgaIds = customFieldValueService.getIdsByPPSId(projectProcessStepId);
      if (!cfgaIds.isEmpty()) {
        List<Long> ppsIds =
            projectProcessStepService.getIdsForAutoTriggerByCfgaIds(
                pps.getProjectId(), null, cfgaIds);
        for (Long ppsId : ppsIds) {
          // Don't re-check the ppsId we just previously did
          if (!ppsId.equals(projectProcessStepId)) {
            actionResults.add(projectProcessStepService.performAutoTriggerActions(
                ppsId, securityService.getCurrentUserDetails()));
          }
        }
      }

      // check for any actions using this PS - Status as a requirement - NOT including SELF (because
      // that creates a potential infinite loop) if active
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
      ProjectProcessStepStatus status =
          projectProcessStepService.getProjectProcessStepStatus(projectProcessStepId);

      boolean doTagUpdate = actionResults.stream().anyMatch(ProjectProcessStepService.PpsActionResult::getShouldRunProjectTagUpdate);
      projectProcessStepService.updateProjectTagsViaRedis(doTagUpdate, pps.getProjectId(), null);

      return new ResponseEntity<>(status, HttpStatus.OK);
    } catch (Exception e) {
      final String errMessage =
          String.format(
              "PPS: Unable to MANUALLY trigger action ID: %s, PPS ID: %s *** %s",
              actionId, projectProcessStepId, e.getMessage());
      log.error(errMessage);
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }
  }

  @PostMapping(
      value =
          "/initialStatus/{initialCompanyProcessStepStatusTypeId}/existingStatus/{existingCompanyProcessStepStatusTypeId}",
      consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Long> createProjectProcessStep(
      @PathVariable Long initialCompanyProcessStepStatusTypeId,
      @PathVariable Long existingCompanyProcessStepStatusTypeId,
      @RequestBody ProjectProcessStep projectProcessStep) {

    Long newPpsId =
        projectProcessStepService.insertProjectProcessStep(
            projectProcessStep.getProjectId(),
            projectProcessStep.getProcessStepId(),
            null,
            null,
            true,
            initialCompanyProcessStepStatusTypeId,
            existingCompanyProcessStepStatusTypeId);

    try {
      // @TODO: This code to run autotriggers for ancillary fields exists in a few places.
      // Consolidate to projectProcessStepService
      List<Long> cfgaIds = customFieldValueService.getIdsByPPSId(newPpsId);
      List<ProjectProcessStepService.PpsActionResult> actionResults = new ArrayList<>();
      if (!cfgaIds.isEmpty()) {
        List<Long> ppsIds =
            projectProcessStepService.getIdsForAutoTriggerByCfgaIds(
                projectProcessStep.getProjectId(), null, cfgaIds);
        for (Long ppsId : ppsIds) {
          // Don't re-check the ppsId we just previously did
          if (!ppsId.equals(newPpsId)) {
            actionResults.add(projectProcessStepService.performAutoTriggerActions(
                ppsId, securityService.getCurrentUserDetails()));
          }
        }
      }

      // check for any actions using this PS - Status as a requirement - NOT including SELF (because
      // that creates a potential infinite loop) if active
      // run auto triggers for those actions
      List<ProjectProcessStep> steps =
          sqlCache.queryBySql(ProjectProcessStepQuery.getUsingStatusByPpsIds,
              Map.of("projectProcessStepIds", List.of(newPpsId)),
              ProjectProcessStep.class);
      for (ProjectProcessStep step : steps) {
        // only run if the referring PPS is active
        if (step.getProcessStepStatusTypeId() == 1) {
          actionResults.add(projectProcessStepService.performAutoTriggerActions(
              step.getProjectProcessStepId(), securityService.getCurrentUserDetails()));
        }
      }
      boolean doTagUpdate = actionResults.stream().anyMatch(ProjectProcessStepService.PpsActionResult::getShouldRunProjectTagUpdate);
      projectProcessStepService.updateProjectTagsViaRedis(doTagUpdate, projectProcessStep.getProjectId(), null);
    } catch (Exception e) {
      final String errMessage =
          String.format(
              "PPS: Unable to AUTO trigger actions on PPS ID: %s *** %s", newPpsId, e.getMessage());
      log.error(errMessage);
      throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
    }

    return new ResponseEntity<>(newPpsId, HttpStatus.OK);
  }

  @GetMapping(value = "/{projectProcessStepId}/attachments")
  public ResponseEntity<List<Attachment>> getProjectProcessStepAttachments(@PathVariable Long projectProcessStepId,
                                                                           @RequestParam(required = false) Boolean isMobile,
                                                                           @RequestParam(required = false) Boolean linked) {
    return new ResponseEntity<>(
        projectProcessStepService.getProjectProcessStepAttachments(projectProcessStepId, isMobile, linked),
        HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepId}/linkAttachment/{attachmentId}")
  public void linkAttachment(@PathVariable Long projectProcessStepId,
                             @PathVariable Long attachmentId,
                             @RequestParam Boolean doLink) {
    projectProcessStepService.linkAttachment(projectProcessStepId, attachmentId, doLink);
  }

  @PostMapping(value = "/{projectProcessStepId}/attachment")
  public ResponseEntity<Attachment> uploadProjectProcessStepAttachment(
      @PathVariable Long projectProcessStepId,
      @RequestParam Long attachmentTypeId,
      @RequestParam String displayName,
      @RequestParam("file") MultipartFile file)
      throws IOException {
    return new ResponseEntity<>(
        projectProcessStepService.addAttachment(file, projectProcessStepId, attachmentTypeId, displayName),
        HttpStatus.OK);
  }

  @GetMapping(value = "/owners/{processStepProcessId}")
  public ResponseEntity<List<Owner>> getAvailableProjectProcessStepOwners(
      @PathVariable Long processStepProcessId) {
    return new ResponseEntity<>(
        projectProcessStepService.getOwners(processStepProcessId), HttpStatus.OK);
  }

  @PostMapping(value = "/{projectProcessStepId}/owner")
  public ResponseEntity<Void> updateProjectProcessStepOwner(
      @PathVariable Long projectProcessStepId, @RequestBody Owner owner) {
    projectProcessStepService.updateOwner(projectProcessStepId, owner, false);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

  @PostMapping(value = "/{projectProcessStepId}/owner/checkExisting")
  public ResponseEntity<?> updateProjectProcessStepOwnerCheckExisting(
      @PathVariable Long projectProcessStepId, @RequestBody Owner owner) {
    return projectProcessStepService.updateOwner(projectProcessStepId, owner, true);
  }

  @PostMapping(
      value = "/{projectProcessStepId}/status",
      consumes = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Void> updateProjectProcessStepStatus(
      @PathVariable Long projectProcessStepId, @RequestBody CompanyProcessStepStatusType status) {
    try {
      List<ProjectProcessStepService.PpsActionResult> actionResults = new ArrayList<>();
      projectProcessStepService.setStatus(
          projectProcessStepId,
          status.getProcessStepStatusTypeId(),
          status.getId(),
          status.getCancelledCompanyProcessStepStatusTypeId());

      // @TODO: Few dupes of this code fragment. Combine when there if free time... lol... free
      // time... good one
      try {
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
            String.format(
                "PPS: Unable to AUTO trigger actions on PPS ID: %s *** %s",
                projectProcessStepId, e.getMessage());
        log.error(errMessage);
        throw new ResponseStatusException(HttpStatus.CONFLICT, errMessage, e);
      }

      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (RuntimeException e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }

  @PostMapping(value = "/{ppsId}/main")
  public ResponseEntity<Void> updateMainProjectProcessStep(
      @PathVariable Long ppsId, @RequestBody CompanyProcessStepStatusType status) {
    try {
      projectProcessStepService.setMain(ppsId, status);
      return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    } catch (RuntimeException e) {
      throw new ResponseStatusException(HttpStatus.CONFLICT, e.getMessage(), e);
    }
  }
}
