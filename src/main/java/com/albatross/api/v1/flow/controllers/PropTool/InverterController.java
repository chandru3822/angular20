package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.Inverter;
import com.albatross.api.v1.flow.services.propTool.InverterService;
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
@RequestMapping(value = "/api/v1/flow/propTool/inverter")
public class InverterController {

  @Autowired
  private InverterService inverterService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Inverter> getInvertersForCompany() {
    return inverterService.getInvertersForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteInverter(@PathVariable Long id) {
    inverterService.deleteInverter(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Inverter> saveInverter(@RequestBody Inverter inverter) {
    return inverterService.saveInverter(inverter);
  }

}
