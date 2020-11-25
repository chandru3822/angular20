package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.CompanyDataType;
import com.albatross.api.v1.flow.model.DataType;
import com.albatross.api.v1.flow.model.DataTypeRequirement;
import com.albatross.api.v1.flow.services.DataTypeService;
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
@RequestMapping(value = "/api/v1/flow/dataType")
public class DataTypeController {

  @Autowired
  private DataTypeService dataTypeService;

  @GetMapping(value = "/getSystem", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DataType> getSystemDataTypes() {
    return dataTypeService.getSystemDataTypes();
  }

  @GetMapping(value = "/getCompanyDataTypes", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<CompanyDataType> getCompanyDataTypes() {
    return dataTypeService.getCompanyDataTypes();
  }

  @GetMapping(value = "/getDataTypeRequirements/{dataTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<DataTypeRequirement> getDataTypeRequirements(@PathVariable Long dataTypeId) {
    return dataTypeService.getDataTypeRequirements(dataTypeId);
  }

}
