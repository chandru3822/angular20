package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.function.DbFunction;
import com.albatross.api.v1.flow.model.function.DbFunctionParam;
import com.albatross.api.v1.flow.model.function.DbFunctionType;
import com.albatross.api.v1.flow.services.DbFunctionService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
@RequiredArgsConstructor
public class DbFunctionController {

  // NOTE: ONLY THE ADMIN SCREEN FOR 7OAKS EMPLOYEES SHOULD EVER CALL THESE ENDPOINTS
  private final DbFunctionService dbFunctionService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DbFunction> getDbFunctions () {
    return dbFunctionService.getDbFunctions();
  }

  @GetMapping(value = "/{id}/availableCompanies", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Company> getAvailableCompanies (@PathVariable Long id) {
    return dbFunctionService.getAvailableCompanies(id);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public DbFunction getDbFunction (@PathVariable Long id) {
    return dbFunctionService.getDbFunction(id);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteDbFunction (@PathVariable Long id) {
    dbFunctionService.archiveDbFunction(id);
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

  @PutMapping(value = "/param", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateDbFunctionParam (@RequestBody DbFunctionParam dbFunctionParam) {
    dbFunctionService.updateDbFunctionParam(dbFunctionParam);
  }

  @Data
  public static class AddToCompanyRequest extends DbFunction {
    private List<Long> selectedCompanyIds;
  }

  @PostMapping(value = "/{id}/addToCompany", produces = MediaType.APPLICATION_JSON_VALUE)
  public DbFunction addToCompany (@PathVariable Long id,
                            @RequestBody AddToCompanyRequest req) {
    return dbFunctionService.addToCompany(id, req);
  }

  @GetMapping(value = "/systemValues", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SystemValue> getSystemValues () {
    return dbFunctionService.getSystemValues();
  }

}
