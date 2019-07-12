package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.model.AhjSummary;

import com.albatross.api.utils.SqlCache;
//import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

//import javax.inject.Inject;

import java.util.HashMap;
import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Service
//@RequiredArgsConstructor(onConstructor = @__({@Inject}))
public class AhjService {
  @Autowired
  private SqlCache sqlCache;

  public List<AhjSummary> getAhjList() {
    return sqlCache.query("ahj.list", new HashMap<>(), AhjSummary.class);
  }
}