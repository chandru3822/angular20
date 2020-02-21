package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Pricing;
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
public class PricingService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Pricing> getPricingsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Pricing> results = sqlCache.query("propToolPricing.getAllForCompany", params, Pricing.class);
    return results;
  }

  public Optional<Pricing> getPricing(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Pricing> results = sqlCache.get("propToolPricing.getOne", params, Pricing.class);
    return results;
  }

  public Optional<Pricing> savePricing(Pricing pricing) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("pricing", pricing.getPricing());
    Long id;

    if(null != pricing.getId()) {
      id = pricing.getId();
      params.put("modifiedById", user.getId());
      params.put("id", id);
      sqlCache.update("propToolPricing.update", params);
    } else {
      params.put("createdById", user.getId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolPricing.insert", params, "id").longValue();
    }

    return getPricing(id);
  }

  public void deletePricing(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("propToolPricing.delete", params);
  }

}
