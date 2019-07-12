package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.model.AhjSummary;
import com.albatross.api.v1.company.blueraven.services.AhjService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/ahj")
public class AhjController {

  @Autowired
  private AhjService ahjService;

  @RequestMapping(value = "", method = RequestMethod.GET)
  public List<AhjSummary> getAhjList() {
    return ahjService.getAhjList();
  }
}