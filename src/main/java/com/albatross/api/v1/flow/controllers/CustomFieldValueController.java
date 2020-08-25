package com.albatross.api.v1.flow.controllers;


import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.services.AsyncProjectProcessStepService;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/customFieldValues")
public class CustomFieldValueController {

  private final CustomFieldValueService customFieldValueService;

  private final ProjectProcessStepService projectProcessStepService;

  private final AsyncProjectProcessStepService asyncProjectProcessStepService;

  private final SecurityService securityService;

  // gets for all types
  @GetMapping(value = "/contact/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getCustomFieldValues(@PathVariable Long id) {
    return customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.CONTACT.toString(), id);
  }

  @GetMapping(value = "/org/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getOrgCustomValues(@PathVariable Long id) {
    return customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.ORGANIZATION.toString(), id);
  }

  @GetMapping(value = "/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getUserCustomValues(@PathVariable Long id) {
    return customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.USER.toString(), id);
  }

  @GetMapping(value = "/project/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> getFieldsByProjectId(@PathVariable Long projectId) {
    return customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.PROJECT.toString(), projectId);
  }

  @GetMapping(value = "/project/{projectId}/processStep/{projectProcessStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<List<CustomFieldGroup>> getFieldsByProjectProcessStepId(@PathVariable Long projectId,
                                                                                @PathVariable Long projectProcessStepId) {
    return new ResponseEntity<>(customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.PROCESS_STEP.textValue(), projectProcessStepId), HttpStatus.OK);
  }

  // updates for all object types
  @PostMapping(value = "/contact/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> updateContactCustomFieldValues(@RequestBody List<CustomFieldValue> values,
                                      @PathVariable Long id) {
      List<CustomFieldGroup> groups = customFieldValueService.updateCustomFieldValues(values, id, ObjectType.CONTACT.toString());

      //    @TODO: humes, this is hardcoded to my user only. Remove after testing
//    ************** This is temporary for testing in AWS rather than locally *********************
      if (!values.isEmpty() && List.of(99999994L, 2350555L, 2410143L).contains(securityService.getCurrentUser().getId())) {
          // grab all PPS where the updated fields are ancillary and perform auto triggers there
          List<Long> cfgaIds = values.stream()
              .map(CustomFieldValue::getCustomFieldGroupAssignmentId)
              .collect(Collectors.toList());
          if (!cfgaIds.isEmpty()) {
              List<Long> ppsIds = projectProcessStepService.getIdsForAutoTriggerByCfgaIds(null, id, cfgaIds);
              for (Long ppsId : ppsIds) {
                  asyncProjectProcessStepService.asyncPerformAutoTriggerActions(ppsId, securityService.getCurrentUserDetails());
              }
          }
      }

      return groups;
  }

  @PostMapping(value = "/org/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> updateOrgCustomFieldValues(@RequestBody List<CustomFieldValue> values,
                                                           @PathVariable Long id) {
    return customFieldValueService.updateCustomFieldValues(values, id, ObjectType.ORGANIZATION.toString());
  }

  @PostMapping(value = "/user/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> updateUserCustomFieldValues(@RequestBody List<CustomFieldValue> values,
                                          @PathVariable Long id) {
    return customFieldValueService.updateCustomFieldValues(values, id, ObjectType.USER.toString());
  }

  @PostMapping(value = "/project/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> updateProjectCustomFieldValues(@RequestBody List<CustomFieldValue> values,
                                                                               @PathVariable Long projectId) {
    List<CustomFieldGroup> groups = customFieldValueService.updateCustomFieldValues(values, projectId, ObjectType.PROJECT.toString());

//    @TODO: humes, this is hardcoded to my user only. Remove after testing
//    ************** This is temporary for testing in AWS rather than locally *********************
      if (!values.isEmpty() && List.of(99999994L, 2350555L, 2410143L).contains(securityService.getCurrentUser().getId())) {
          // grab all PPS where the updated fields are ancillary and perform auto triggers there
          List<Long> cfgaIds = values.stream()
              .map(CustomFieldValue::getCustomFieldGroupAssignmentId)
              .collect(Collectors.toList());
          if (!cfgaIds.isEmpty()) {
              List<Long> ppsIds = projectProcessStepService.getIdsForAutoTriggerByCfgaIds(projectId, null, cfgaIds);
              for (Long ppsId : ppsIds) {
                  asyncProjectProcessStepService.asyncPerformAutoTriggerActions(ppsId, securityService.getCurrentUserDetails());
              }
          }
      }

    return groups;
  }

  @PostMapping(value = "/project/{projectId}/processStep/{projectProcessStepId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CustomFieldGroup> updateProjectProcessStepCustomFieldValues(@RequestBody List<CustomFieldValue> values,
                                                                          @PathVariable Long projectId,
                                                                          @PathVariable Long projectProcessStepId) {
    List<CustomFieldGroup> groups = customFieldValueService.updateCustomFieldValues(values, projectProcessStepId, ObjectType.PROCESS_STEP.textValue());

//    @TODO: humes, this is hardcoded to my user only. Remove after testing
//    ************** This is temporary for testing in AWS rather than locally *********************
    if (!values.isEmpty() && List.of(99999994L, 2350555L, 2410143L).contains(securityService.getCurrentUser().getId())) {
        asyncProjectProcessStepService.asyncPerformAutoTriggerActions(projectProcessStepId, securityService.getCurrentUserDetails());

        // grab all PPS where the updated fields are ancillary and perform auto triggers there
        List<Long> cfgaIds = values.stream()
            .map(CustomFieldValue::getCustomFieldGroupAssignmentId)
            .collect(Collectors.toList());
        if (!cfgaIds.isEmpty()) {
            List<Long> ppsIds = projectProcessStepService.getIdsForAutoTriggerByCfgaIds(projectId, null, cfgaIds);
            for (Long ppsId : ppsIds) {
//            Don't re-check the ppsId we just previously did
                if (!ppsId.equals(projectProcessStepId)) {
                    asyncProjectProcessStepService.asyncPerformAutoTriggerActions(ppsId, securityService.getCurrentUserDetails());
                }
            }
        }
    }

    return groups;
  }
}
