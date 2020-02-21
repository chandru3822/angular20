package com.albatross.api.v1.flow.controllers.PropTool;

import com.albatross.api.v1.flow.model.propTool.ZipCode;
import com.albatross.api.v1.flow.services.propTool.ZipCodeService;
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
@RequestMapping(value = "/api/v1/flow/propTool/zipCode")
public class ZipCodeController {

  @Autowired
  private ZipCodeService zipCodeService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ZipCode> getZipCodesForCompany() {
    return zipCodeService.getZipCodesForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteZipCode(@PathVariable Long id) {
    zipCodeService.deleteZipCode(id);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<ZipCode> saveZipCode(@RequestBody ZipCode zipCode) {
    return zipCodeService.saveZipCode(zipCode);
  }

}
