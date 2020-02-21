package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.Incentive;
import com.albatross.api.v1.flow.services.propTool.IncentiveService;
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
@RequestMapping(value = "/api/v1/flow/propTool/incentive")
public class IncentiveController {

  @Autowired
  private IncentiveService incentiveService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Incentive> getIncentivesForCompany() {
    return incentiveService.getIncentivesForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteIncentive(@PathVariable Long id) {
    incentiveService.deleteIncentive(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Incentive> saveIncentive(@RequestBody Incentive incentive) {
    return incentiveService.saveIncentive(incentive);
  }

}
