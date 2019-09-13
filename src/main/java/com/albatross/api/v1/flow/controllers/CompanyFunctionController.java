package com.albatross.api.v1.flow.controllers;

import java.util.List;

import com.albatross.api.v1.flow.model.CompanyFunction;
import com.albatross.api.v1.flow.model.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.RequirementParamDynamicValue;
import com.albatross.api.v1.flow.model.SystemValue;
import com.albatross.api.v1.flow.services.CompanyFunctionService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
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
@RequestMapping(value = "/api/v1/flow/function")
public class CompanyFunctionController {

  @Autowired
  private CompanyFunctionService companyFunctionService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFunction> getCompanyFunctions () {
    return companyFunctionService.getCompanyFunctions();
  }

  @RequestMapping(value = "{id}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCompanyFunction (@PathVariable Long id) {
    companyFunctionService.deleteCompanyFunction(id);
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public CompanyFunction getFunctionDetails (@PathVariable Long id) {
    return companyFunctionService.getFunctionDetails(id);
  }

  @RequestMapping(value = "/{id}/dynamicParams", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<RequirementParamDynamicValue> getFunctionDynamicParams(@PathVariable Long id) {
    return companyFunctionService.getFunctionDynamicParams(id);
  }

  @RequestMapping(value = "/{id}/param", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public CompanyFunctionParam saveParams (@PathVariable("id") Long functionId,
                          @RequestBody CompanyFunctionParam param) {
    return companyFunctionService.saveFunctionParams(functionId, param);
  }

  // this could be in a system value controller but i dont think it will be needed outside of functions??
  @RequestMapping(value = "/systemValues", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SystemValue> getSystemValues () {
    return companyFunctionService.getSystemValues();
  }

}
