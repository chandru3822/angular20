package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.DataView;
import com.albatross.api.v1.flow.model.DataViewFieldConfig;
import com.albatross.api.v1.flow.model.ProcessStepEvent;
import com.albatross.api.v1.flow.services.DataViewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

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
  public List<DataView> getCompanyDataViews () {
    return dataViewService.getCompanyDataViews();
  }

  @GetMapping(value = "/{viewId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<DataView> getViewById(@PathVariable Long viewId) {
    return dataViewService.getView(viewId);
  }

  @PostMapping(value = "/{viewId}/field", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<DataViewFieldConfig> addFieldConfig(@PathVariable Long viewId,
                             @RequestBody DataViewFieldConfig field) {
    return dataViewService.addFieldConfig(viewId, field);
  }

  @GetMapping(value = "/{viewId}/getAvailableDefaultFields", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DataViewFieldConfig> getAvailableDefaultFields(@PathVariable Long viewId) {
    return dataViewService.getAvailableDefaultFields(viewId);
  }

  @GetMapping(value = "/{viewId}/defaultFieldPsEvents/{defaultFieldId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStepEvent> getAvailablePsEventsForDefaultField(@PathVariable Long viewId,
                                                                    @PathVariable Long defaultFieldId) {
    return dataViewService.getAvailablePsEventsForDefaultField(viewId, defaultFieldId);
  }

}
