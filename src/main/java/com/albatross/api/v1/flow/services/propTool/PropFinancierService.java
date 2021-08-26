package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.PropFinancier;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class PropFinancierService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<PropFinancier> getFinanciersForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<PropFinancier> results = sqlCache.query("propToolFinancier.getAllForCompany", params, PropFinancier.class);
    return results;
  }

  public Optional<PropFinancier> getFinancier(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<PropFinancier> results = sqlCache.get("propToolFinancier.getOne", params, PropFinancier.class);
    return results;
  }

  public Optional<PropFinancier> saveFinancier(PropFinancier financier) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("name", financier.getName());
    params.put("active", financier.getActive());
    Long id;

    if(null != financier.getId()) {
      id = financier.getId();
      params.put("modifiedById", user.trueUserId());
      params.put("id", id);
      sqlCache.update("propToolFinancier.update", params);
    } else {
      params.put("createdById", user.trueUserId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolFinancier.insert", params, "id").longValue();
    }

    return getFinancier(id);
  }

  public void deleteFinancier(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("propToolFinancier.delete", params);
  }

}
