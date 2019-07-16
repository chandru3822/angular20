package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.StatusType;
import com.albatross.api.v1.flow.services.StatusService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/status")
public class StatusController {

  @Autowired
  private StatusService statusService;

  @RequestMapping(value = "", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
  public List<StatusType> getStatusTypesForCompany (@PathVariable Long companyId) {
    return statusService.getStatusTypesForCompany(companyId);
  }

  @RequestMapping(value = "/{typeId}", method = RequestMethod.DELETE, produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteType(@PathVariable Long typeId) {
    statusService.deleteType(typeId);
  }

  @RequestMapping(value = "", method = RequestMethod.PUT, produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateProcess(@RequestBody StatusType type) {
    statusService.updateType(type);
  }

  @RequestMapping(value = "", method = RequestMethod.POST, produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<StatusType> insertProcess(@RequestBody StatusType type) {
    return statusService.insertType(type);
  }

}
