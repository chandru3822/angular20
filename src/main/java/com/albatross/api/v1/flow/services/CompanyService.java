package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Company;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CompanyService {
  // @TODO: Move the sql queries into their own sql xml file

  private final SqlCache sqlCache;

  public List<Company> getCompanies() {
    return sqlCache.query("select id, company_name as name from flow.company;", null, Company.class);
  }

  public Optional<Company> getCompany(Long id) {
    return sqlCache.get("select id, company_name as name from flow.company where id = :id;", ImmutableMap.of("id", id), Company.class);
  }
}
