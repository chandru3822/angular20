package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.Financier;
import com.albatross.api.v1.company.blueraven.services.queries.FinancierQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Service
@RequiredArgsConstructor
public class FinancierService {
  private final SqlCache sqlCache;
  private final SecurityService securityService;

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
