package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Smartlist;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SmartlistService {

  private final SecurityService securityService;

  private final SqlCache sqlCache;

  public List<Smartlist> getSmartlists() {
    return sqlCache.query("smartlist.get", null, Smartlist.class);
  }

  public Smartlist getSmartlist(Long id) {
    return sqlCache.get("smartlist.getById", Map.of("id", id), Smartlist.class).orElse(null);
  }

  public Smartlist addSmartlist(Smartlist smartlist) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("name", smartlist.getName(), "companyObjectTypeId", smartlist.getCompanyObjectTypeId(), "ownerId", user.getId(), "createdById", user.getId());
    Long smartlistId = sqlCache.updateReturningId("smartlist.add", params, "id").longValue();
    return getSmartlist(smartlistId);
  }

  public void updateSmartlist(Smartlist smartlist) {
    Map<String, Object> params = Map.of("id", smartlist.getId(), "name", smartlist.getName(), "companyObjectTypeId", smartlist.getCompanyObjectTypeId());
    sqlCache.update("smartlist.update", params);
  }
}
