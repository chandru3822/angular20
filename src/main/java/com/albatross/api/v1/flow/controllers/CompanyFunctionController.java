package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.FunctionType;
import com.albatross.api.v1.flow.model.CompanyFunction;
import com.albatross.api.v1.flow.model.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.RequirementParamDynamicValue;
import com.albatross.api.v1.flow.services.CompanyFunctionService;
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
@RequestMapping(value = "/api/v1/flow/function")
public class CompanyFunctionController {

  @Autowired
  private CompanyFunctionService companyFunctionService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFunction> getCompanyFunctions () {
    return companyFunctionService.getCompanyFunctions();
  }

  @GetMapping(value = "/action", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFunction> getActionCompanyFunctions () {
    return companyFunctionService.getCompanyFunctionsByType(FunctionType.ACTION.id);
  }

  @GetMapping(value = "/requirement", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFunction> getRequirementCompanyFunctions () {
    return companyFunctionService.getCompanyFunctionsByType(FunctionType.REQUIREMENT.id);
  }

  @DeleteMapping(value = "{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCompanyFunction (@PathVariable Long id) {
    companyFunctionService.deleteCompanyFunction(id);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public CompanyFunction getFunctionDetails (@PathVariable Long id) {
    return companyFunctionService.getFunctionDetails(id);
  }

  @GetMapping(value = "/{id}/dynamicParams", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RequirementParamDynamicValue> getFunctionDynamicParams(@PathVariable("id") Long dbFunctionId) {
    return companyFunctionService.getFunctionDynamicParams(dbFunctionId);
  }

  @PostMapping(value = "/{id}/param", produces = MediaType.APPLICATION_JSON_VALUE)
  public CompanyFunctionParam saveParams (@PathVariable("id") Long functionId,
                          @RequestBody CompanyFunctionParam param) {
    return companyFunctionService.saveFunctionParams(functionId, param);
  }

}
