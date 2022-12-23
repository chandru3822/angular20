package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.Financier;
import com.albatross.api.v1.company.blueraven.services.queries.FinancierQuery;
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
    return sqlCache.queryBySql(FinancierQuery.getActive, Collections.emptyMap(), Financier.class);
  }

  public Integer addFinancier(Financier financier) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("name", financier.getName());
    params.put("submissionMethod", financier.getSubmissionMethod());
    params.put("archived", financier.getArchived());
    params.put("currentUser", currentUser.trueUserId());

    return sqlCache.updateBySql(FinancierQuery.add, params);
  }

  public void updateFinancier(Financier financier) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", financier.getId());
    params.put("name", financier.getName());
    params.put("submissionMethod", financier.getSubmissionMethod());
    params.put("archived", financier.getArchived());
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(FinancierQuery.update, params);
  }
}
