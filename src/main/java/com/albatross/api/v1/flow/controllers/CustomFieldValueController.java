package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping(
    value = "/api/v1/flow/customFieldValues",
    produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class CustomFieldValueController {

  private final CustomFieldValueService customFieldValueService;

  private final ProjectProcessStepService projectProcessStepService;

  private final ProjectService projectService;

  private final SecurityService securityService;

  // gets for all types
  @GetMapping(value = "/contact/{id}")
  public List<CustomFieldGroup> getCustomFieldValues(@PathVariable Long id) {
    return customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.CONTACT.toString(), id);
  }

  @GetMapping(value = "/org/{id}")
  public List<CustomFieldGroup> getOrgCustomValues(@PathVariable Long id) {
    return customFieldValueService.getCustomFieldGroupsAndValues(
        ObjectType.ORGANIZATION.toString(), id);
  }

  @GetMapping(value = "/user/{id}")
  public List<CustomFieldGroup> getUserCustomValues(@PathVariable Long id) {
    return customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.USER.toString(), id);
  }

  @GetMapping(value = "/getUserProfileFields")
  public List<CustomFieldValue> getUserProfileFields() {
    return customFieldValueService.getUserProfileFields(null, ObjectType.USER.id);
  }

  @GetMapping(value = "/project/{projectId}")
  public List<CustomFieldGroup> getFieldsByProjectId(@PathVariable Long projectId) {
    return customFieldValueService.getCustomFieldGroupsAndValues(
        ObjectType.PROJECT.toString(), projectId);
  }

  @GetMapping(value = "/project/{projectId}/processStep/{projectProcessStepId}")
  public ResponseEntity<List<CustomFieldGroup>> getFieldsByProjectProcessStepId(
      @PathVariable Long projectId, @PathVariable Long projectProcessStepId) {
    return new ResponseEntity<>(
        customFieldValueService.getCustomFieldGroupsAndValues(
            ObjectType.PROCESS_STEP.textValue(), projectProcessStepId),
        HttpStatus.OK);
  }

  @GetMapping(value = "/event/{id}")
  public List<CustomFieldGroup> getEventCustomFieldValues(@PathVariable Long id) {
    return customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.EVENT.toString(), id);
  }

  // updates for all object types
  @PostMapping(value = "/contact/{id}")
  public List<CustomFieldGroup> updateContactCustomFieldValues(
      @RequestBody List<CustomFieldValue> values, @PathVariable Long id) {
    List<CustomFieldGroup> groups =
        customFieldValueService.updateCustomFieldValues(values, id, ObjectType.CONTACT.toString());

    try {
      // grab all PPS where the updated fields are ancillary and perform auto triggers there
      List<Long> cfgaIds =
          values.stream().map(CustomFieldValue::getCustomFieldGroupAssignmentId).toList();
      if (!cfgaIds.isEmpty()) {
        List<Long> ppsIds =
            projectProcessStepService.getIdsForAutoTriggerByCfgaIds(null, id, cfgaIds);
        for (Long ppsId : ppsIds) {
          projectProcessStepService.performAutoTriggerActions(
              ppsId, securityService.getCurrentUserDetails());
        }
      }
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage());
    }

    return groups;
  }

  @PostMapping(value = "/org/{id}")
  public List<CustomFieldGroup> updateOrgCustomFieldValues(
      @RequestBody List<CustomFieldValue> values, @PathVariable Long id) {
    return customFieldValueService.updateCustomFieldValues(
        values, id, ObjectType.ORGANIZATION.toString());
  }

  @PostMapping(value = "/user/{id}")
  public List<CustomFieldGroup> updateUserCustomFieldValues(
      @RequestBody List<CustomFieldValue> values, @PathVariable Long id) {
    return customFieldValueService.updateCustomFieldValues(values, id, ObjectType.USER.toString());
  }

  @PostMapping(value = "/project/{projectId}")
  public List<CustomFieldGroup> updateProjectCustomFieldValues(
      @RequestBody List<CustomFieldValue> values, @PathVariable Long projectId) {
    List<CustomFieldGroup> groups =
        customFieldValueService.updateCustomFieldValues(
            values, projectId, ObjectType.PROJECT.toString());

    try {
      // grab all PPS where the updated fields are ancillary and perform auto triggers there
      List<Long> cfgaIds =
          values.stream().map(CustomFieldValue::getCustomFieldGroupAssignmentId).toList();
      if (!cfgaIds.isEmpty()) {
        List<Long> ppsIds =
            projectProcessStepService.getIdsForAutoTriggerByCfgaIds(projectId, null, cfgaIds);
        for (Long ppsId : ppsIds) {
          projectProcessStepService.performAutoTriggerActions(
              ppsId, securityService.getCurrentUserDetails());
        }
      }
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage());
    }

    return groups;
      
  }

  @PostMapping(value = "/project/{projectId}/processStep/{projectProcessStepId}")
  public List<CustomFieldGroup> updateProjectProcessStepCustomFieldValues(
      @RequestBody List<CustomFieldValue> values,
      @PathVariable Long projectId,
      @PathVariable Long projectProcessStepId) {
    List<CustomFieldGroup> groups =
        customFieldValueService.updateCustomFieldValues(
            values, projectProcessStepId, ObjectType.PROCESS_STEP.textValue());

    try {
      projectProcessStepService.performAutoTriggerActions(
          projectProcessStepId, securityService.getCurrentUserDetails());

      // grab all PPS where the updated fields are ancillary and perform auto triggers there
      List<Long> cfgaIds =
          values.stream().map(CustomFieldValue::getCustomFieldGroupAssignmentId).toList();
      if (!cfgaIds.isEmpty()) {
        List<Long> ppsIds =
            projectProcessStepService.getIdsForAutoTriggerByCfgaIds(projectId, null, cfgaIds);
        for (Long ppsId : ppsIds) {
          // Don't re-check the ppsId we just previously did
          if (!ppsId.equals(projectProcessStepId)) {
            projectProcessStepService.performAutoTriggerActions(
                ppsId, securityService.getCurrentUserDetails());
          }
        }
      }
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage());
    }

    return groups;
  }

  @PostMapping(value = "/project/{projectId}/customField/{customFieldId}")
  public ResponseEntity<String> updateProjectCustomFieldValue(
      @RequestBody CustomFieldValue cfv,
      @PathVariable Long projectId,
      @PathVariable Long customFieldId) {
    JSONObject result = new JSONObject();
    try {
      Optional<Project> project = projectService.getProject(projectId);
      if (project.isPresent()) {
        customFieldValueService.updateProjectCustomFieldValue(cfv, projectId, customFieldId);

        try {
          // grab all PPS where the updated fields are ancillary and perform auto triggers there
          ArrayList<Long> cfgaIds = new ArrayList<>();
          cfgaIds.add(cfv.getCustomFieldGroupAssignmentId());
          if (!cfgaIds.isEmpty()) {
            List<Long> ppsIds =
                projectProcessStepService.getIdsForAutoTriggerByCfgaIds(projectId, null, cfgaIds);
            for (Long ppsId : ppsIds) {
              projectProcessStepService.performAutoTriggerActions(
                  ppsId, securityService.getCurrentUserDetails());
            }
          }
        } catch (Exception e) {
          throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage());
        }
      } else {
        result.put("message", "User does not have access to this project.");
        return ResponseEntity.badRequest().body(result.toString());
      }

    } catch (Exception e) {
      result.put("message", e.getMessage());
      return ResponseEntity.badRequest().body(result.toString());
    }

    result.put("message", "Custom field value successfully updated.");
    return ResponseEntity.ok(result.toString());
  }

  @PostMapping(value = "/event/{projectProcessStepEventId}")
  public List<CustomFieldGroup> updateEventCustomFieldValues(
      @RequestBody List<CustomFieldValue> values, @PathVariable Long projectProcessStepEventId) {
    return customFieldValueService.updateCustomFieldValues(
        values, projectProcessStepEventId, ObjectType.EVENT.textValue());
  }
}
