package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.SystemList;
import com.albatross.api.v1.flow.services.SystemListService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/systemList")
public class SystemListController {

  @Autowired
  private SystemListService systemListService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SystemList> getSystemListsForCompany () {
    return systemListService.getSystemListsForCompany();
  }

  @GetMapping(value = "/{id}/options", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ListOfValue> getSystemListOptionsForCompany (@PathVariable("id") Long typeId,
                                                           @RequestParam Boolean subOptions,
                                                           @RequestParam(required = false) List<Long> systemListOptionIds) {
    return systemListService.getSystemListOptionsForCompany(typeId, subOptions, systemListOptionIds);
  }

}
