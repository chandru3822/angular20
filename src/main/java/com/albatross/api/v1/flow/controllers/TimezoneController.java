package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyTimezone;
import com.albatross.api.v1.flow.services.TimezoneService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/timezone")
public class TimezoneController {

  private final TimezoneService timezoneService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyTimezone> getTimezonesForCompany() {
    return timezoneService.getTimezonesForCompany();
  }


}
