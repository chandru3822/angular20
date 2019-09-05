package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Country;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
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

  public List<Country> getAllCountries() {
    List<Country> results = sqlCache.query("country.getAll", Collections.emptyMap(), Country.class);
    return results;
  }

}
