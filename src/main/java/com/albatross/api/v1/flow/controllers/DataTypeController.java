package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyDataType;
import com.albatross.api.v1.flow.services.DataTypeService;
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
@RequestMapping(value = "/api/v1/flow/{companyId}/dataType")
public class DataTypeController {

  @Autowired
  private DataTypeService dataTypeService;

  @RequestMapping(value = "/getCompanyDataTypes", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyDataType> getCompanyDataTypes(@PathVariable Long companyId) {
    return dataTypeService.getCompanyDataTypes(companyId);
  }

}
