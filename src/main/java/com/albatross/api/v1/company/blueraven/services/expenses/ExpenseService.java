package com.albatross.api.v1.company.blueraven.services.expenses;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.expenses.GlCode;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Randa Nunn
 */
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ExpenseService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<GlCode> getAllGlCodes() {
    return sqlCache.query("expense.glCodes.getAll", Collections.emptyMap(), GlCode.class);
  }

  public Optional<GlCode> getOneGlCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.get("expense.glCodes.getOne", params, GlCode.class);
  }

  public Optional<GlCode> saveGlCode(GlCode glCode){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("code", glCode.getCode());
    params.put("description", glCode.getDescription());
    params.put("userId", currentUser.trueUserId());

    Long id;
    if(null != glCode.getId()){
      id = glCode.getId();
      params.put("id", glCode.getId());
      sqlCache.update("expense.glCodes.updateGlCode", params);
    }else{
      id = sqlCache.updateReturningId("expense.glCodes.insertGlCode", params, "id").longValue();
    }

    return getOneGlCode(id);
  }

  public void deleteGlCode(Long id){
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.trueUserId());

    sqlCache.update("expense.glCodes.deleteGlCode", params);
  }

}
