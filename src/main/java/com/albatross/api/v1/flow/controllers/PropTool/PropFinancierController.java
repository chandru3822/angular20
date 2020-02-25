package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.PropFinancier;
import com.albatross.api.v1.flow.services.propTool.PropFinancierService;
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
@RequestMapping(value = "/api/v1/flow/propTool/financier")
public class PropFinancierController {

  @Autowired
  private PropFinancierService financierService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<PropFinancier> getFinanciersForCompany() {
    return financierService.getFinanciersForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteFinancier(@PathVariable Long id) {
    financierService.deleteFinancier(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<PropFinancier> saveFinancier(@RequestBody PropFinancier financier) {
    return financierService.saveFinancier(financier);
  }

}
