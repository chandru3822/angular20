package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyCountry;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.CountryQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@RequiredArgsConstructor
public class CountryService {
  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<CompanyCountry> getAllCountries() {
    return sqlCache.queryBySql(CountryQuery.getAll, Collections.emptyMap(), CompanyCountry.class);
  }

  public List<CompanyCountry> getAllCountriesForCompany(Long companyId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", null != companyId ? companyId : currentUser.getCompanyId());
    return sqlCache.queryBySql(CountryQuery.getAllForCompany, params, CompanyCountry.class);
  }
}
