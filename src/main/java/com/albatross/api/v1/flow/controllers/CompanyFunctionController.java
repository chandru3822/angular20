package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyFunction;
import com.albatross.api.v1.flow.services.CompanyFunctionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
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
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/function")
public class CompanyFunctionController {

  @Autowired
  private CompanyFunctionService companyFunctionService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyFunction> getCompanyFunctions (@PathVariable Long companyId) {
    return companyFunctionService.getCompanyFunctions(companyId);
  }

}
