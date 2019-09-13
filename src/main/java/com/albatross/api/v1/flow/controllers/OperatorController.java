package com.albatross.api.v1.flow.controllers;

import java.util.List;

import com.albatross.api.v1.flow.model.OperatorType;
import com.albatross.api.v1.flow.services.OperatorService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

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

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OperatorType> getOperatorTypes () {
    return operatorService.getOperatorTypes();
  }

}
