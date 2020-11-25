package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.DbFunctionService;
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
@RequestMapping(value = "/api/v1/flow/dbFunction")
public class DbFunctionController {

  // NOTE: ONLY THE ADMIN SCREEN FOR 7OAKS EMPLOYEES SHOULD EVER CALL THESE ENDPOINTS
  @Autowired
  private DbFunctionService dbFunctionService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DbFunction> getDbFunctions () {
    return dbFunctionService.getDbFunctions();
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public DbFunction getDbFunction (@PathVariable Long id) {
    return dbFunctionService.getDbFunction(id);
  }

  @GetMapping(value = "/types", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DbFunctionType> getDbFunctionTypes () {
    return dbFunctionService.getDbFunctionTypes();
  }

  @GetMapping(value = "/parameterTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ParameterType> getParameterTypes () {
    return dbFunctionService.getParameterTypes();
  }


  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public DbFunction insertDbFunction (@RequestBody DbFunction dbFunction) {
    return dbFunctionService.insertDbFunction(dbFunction);
  }

  @PostMapping(value = "/param", produces = MediaType.APPLICATION_JSON_VALUE)
  public DbFunction insertDbFunctionParam (@RequestBody DbFunctionParam dbFunctionParam) {
    return dbFunctionService.insertDbFunctionParam(dbFunctionParam);
  }

  @GetMapping(value = "/systemValues", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SystemValue> getSystemValues () {
    return dbFunctionService.getSystemValues();
  }

}
