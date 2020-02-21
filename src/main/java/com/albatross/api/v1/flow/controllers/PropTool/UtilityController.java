package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.Utility;
import com.albatross.api.v1.flow.services.propTool.UtilityService;
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
@RequestMapping(value = "/api/v1/flow/propTool/utility")
public class UtilityController {

  @Autowired
  private UtilityService utilityService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Utility> getUtilitiesForCompany() {
    return utilityService.getUtilitiesForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteUtility(@PathVariable Long id) {
    utilityService.deleteUtility(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Utility> saveUtility(@RequestBody Utility utility) {
    return utilityService.saveUtility(utility);
  }

}
