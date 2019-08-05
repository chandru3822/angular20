package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyFunction;
import com.albatross.api.v1.flow.model.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.SystemValue;
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
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/function")
public class CompanyFunctionController {

  @Autowired
  private CompanyFunctionService companyFunctionService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFunction> getCompanyFunctions (@PathVariable Long companyId) {
    return companyFunctionService.getCompanyFunctions(companyId);
  }

  @RequestMapping(value = "/{id}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public CompanyFunction getFunctionDetails (@PathVariable Long id) {
    return companyFunctionService.getFunctionDetails(id);
  }

  @RequestMapping(value = "/{id}/params", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveParams (@PathVariable("id") Long functionId,
                          @RequestBody List<CompanyFunctionParam> params) {
    companyFunctionService.saveFunctionParams(functionId, params);
  }

  // this could be in a system value controller but i dont think it will be needed outside of functions??
  @RequestMapping(value = "/systemValues", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<SystemValue> getSystemValues () {
    return companyFunctionService.getSystemValues();
  }

}
