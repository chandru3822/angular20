package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.OperatorType;
import com.albatross.api.v1.flow.services.OperatorService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/operator")
public class OperatorController {

  @Autowired
  private OperatorService operatorService;

  @GetMapping(value = "/{dataTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OperatorType> getOperatorTypes (@PathVariable Long dataTypeId) {
    return operatorService.getOperatorTypes(dataTypeId);
  }

}
