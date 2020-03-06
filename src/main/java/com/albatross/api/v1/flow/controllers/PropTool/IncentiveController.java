package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.Incentive;
import com.albatross.api.v1.flow.model.propTool.IncentiveCategory;
import com.albatross.api.v1.flow.model.propTool.IncentiveEntity;
import com.albatross.api.v1.flow.model.propTool.IncentiveType;
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

  @GetMapping(value = "/categories", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<IncentiveCategory> getIncentivesCategories() {
    return incentiveService.getIncentivesCategories();
  }

  @GetMapping(value = "/types", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<IncentiveType> getIncentivesTypes() {
    return incentiveService.getIncentivesTypes();
  }

  @GetMapping(value = "/entities/{categoryId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<IncentiveEntity> getIncentiveEntities(@PathVariable Long categoryId) {
    return incentiveService.getIncentiveEntities(categoryId);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Incentive> saveIncentive(@RequestBody Incentive incentive) {
    return incentiveService.saveIncentive(incentive);
  }
}
