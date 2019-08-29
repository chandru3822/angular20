package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.OperationType;
import com.albatross.api.v1.flow.services.OperationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/operation")
public class OperationController {

  @Autowired
  private OperationService operationService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<OperationType> getOperationTypes () {
    return operationService.getOperationTypes();
  }

}
