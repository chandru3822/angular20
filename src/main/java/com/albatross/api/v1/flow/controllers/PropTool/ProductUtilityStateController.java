package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.ProductUtilityState;
import com.albatross.api.v1.flow.services.propTool.ProductUtilityStateService;
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
@RequestMapping(value = "/api/v1/flow/propTool/productUtilityState")
public class ProductUtilityStateController {

  @Autowired
  private ProductUtilityStateService pricingService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProductUtilityState> getProductUtilityStateForCompany() {
    return pricingService.getProductUtilityStatesForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteProductUtilityState(@PathVariable Long id) {
    pricingService.deleteProductUtilityState(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ProductUtilityState> saveProductUtilityState(@RequestBody ProductUtilityState pricing) {
    return pricingService.saveProductUtilityState(pricing);
  }

}
