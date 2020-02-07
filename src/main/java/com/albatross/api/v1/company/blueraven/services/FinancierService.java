package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;

import com.albatross.api.v1.company.blueraven.models.Financier;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Service
public class FinancierService {
  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private SecurityService securityService;

  public List<Financier> getAllActiveFinanciers() {
    return sqlCache.query("financier.getActive", Collections.emptyMap(), Financier.class);
  }

  public Integer addFinancier(Financier financier) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("name", financier.getName());
    params.put("submissionMethod", financier.getSubmissionMethod());
    params.put("archived", financier.getArchived());
    params.put("currentUser", currentUser.getId());

    return sqlCache.update("financier.add", params);
  }

  public void updateFinancier(Financier financier) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", financier.getId());
    params.put("name", financier.getName());
    params.put("submissionMethod", financier.getSubmissionMethod());
    params.put("archived", financier.getArchived());
    params.put("currentUser", currentUser.getId());

    sqlCache.update("financier.update", params);
  }
}
