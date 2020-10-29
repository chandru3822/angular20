package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyCountry;
import com.albatross.api.v1.flow.model.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
public class CountryService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<CompanyCountry> getAllCountries() {
    List<CompanyCountry> results = sqlCache.query("country.getAll", Collections.emptyMap(), CompanyCountry.class);
    return results;
  }

  public List<CompanyCountry> getAllCountriesForCompany() {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    List<CompanyCountry> results = sqlCache.query("country.getAllForCompany", params, CompanyCountry.class);
    return results;
  }

}
