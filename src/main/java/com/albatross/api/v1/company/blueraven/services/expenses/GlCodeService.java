package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.expenses.GlCode;
import com.albatross.api.v1.company.blueraven.services.expenses.queries.GlCodeQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * Created by Randa Nunn
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class GlCodeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<GlCode> getAllGlCodes() {
    return sqlCache.queryBySql(GlCodeQuery.getAllGlCodes, Collections.emptyMap(), GlCode.class);
  }

  public Optional<GlCode> getOneGlCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(GlCodeQuery.getOneGlCode, params, GlCode.class);
  }

  public Optional<GlCode> saveGlCode(GlCode glCode) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("code", glCode.getCode());
    params.put("description", glCode.getDescription());
    params.put("userId", currentUser.trueUserId());

    Long id;
    if (null != glCode.getId()) {
      id = glCode.getId();
      params.put("id", glCode.getId());
      sqlCache.updateBySql(GlCodeQuery.updateGlCode, params);
    } else {
      id = sqlCache.updateBySqlReturningId(GlCodeQuery.insertGlCode, params, "id").longValue();
    }

    return getOneGlCode(id);
  }

  public void deleteGlCode(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.updateBySql(GlCodeQuery.deleteGlCode, params);
  }

}
