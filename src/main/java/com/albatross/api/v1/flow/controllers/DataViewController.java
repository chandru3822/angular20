package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.DataView;
import com.albatross.api.v1.flow.services.DataViewService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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

}
