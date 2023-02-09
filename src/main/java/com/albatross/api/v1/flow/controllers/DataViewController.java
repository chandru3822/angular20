package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.ProcessStep;
import com.albatross.api.v1.flow.model.processStep.ProcessStepEvent;
import com.albatross.api.v1.flow.services.DataViewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/dataView")
public class DataViewController {


  private final DataViewService dataViewService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DataView> getCompanyDataViews() {
    return dataViewService.getCompanyDataViews();
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<DataView> saveDataView(@RequestBody DataView dataView) throws SQLException {
    return dataViewService.saveDataView(dataView);
  }

  @GetMapping(value = "/{viewId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<DataView> getViewById(@PathVariable Long viewId) {
    return dataViewService.getView(viewId);
  }

  @PostMapping(value = "/{viewId}/field", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<DataViewFieldConfig> saveFieldConfig(@PathVariable Long viewId,
                                                      @RequestBody DataViewFieldConfig field) {
    return dataViewService.saveFieldConfig(viewId, field);
  }

  @PostMapping(value = "/{viewId}/field/{fieldId}/childField", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<DataViewChildFieldConfig> saveChildFieldConfig(@PathVariable Long viewId,
                                                                @PathVariable Long fieldId,
                                                                @RequestBody DataViewChildFieldConfig childField) {
    return dataViewService.saveChildFieldConfig(viewId, fieldId, childField);
  }

  @GetMapping(value = "/{viewId}/getAvailableDefaultFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DefaultField> getAvailableDefaultFields(@PathVariable Long viewId) {
    return dataViewService.getAvailableDefaultFields(viewId);
  }

  @GetMapping(value = "/{viewId}/defaultFieldPsEvents/{defaultFieldId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepEvent> getAvailablePsEventsForDefaultField(@PathVariable Long viewId,
                                                                    @PathVariable Long defaultFieldId) {
    return dataViewService.getAvailablePsEventsForDefaultField(viewId, defaultFieldId);
  }

  @GetMapping(value = "/{viewId}/defaultFieldPs/{defaultFieldId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> getAvailablePsForDefaultField(@PathVariable Long viewId,
                                                         @PathVariable Long defaultFieldId) {
    return dataViewService.getAvailablePsForDefaultField(viewId, defaultFieldId);
  }

  @GetMapping(value = "/getUniqueBehaviorTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<UniqueBehaviorType> getUniqueBehaviorTypes() {
    return dataViewService.getUniqueBehaviorTypes();
  }

  @PreAuthorize("hasRootLevelAccess()")
  @GetMapping(value = "/doMaintenance", produces = MediaType.APPLICATION_JSON_VALUE)
  public void doMaintenance() {
    log.info("*** DATA VIEW: manually started data view maintenance ***");
    dataViewService.runViewMaintenance();
    log.info("*** DATA VIEW: ended manual data view maintenance ***");
  }
}
