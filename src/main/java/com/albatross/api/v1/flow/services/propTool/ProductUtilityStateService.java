package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.ProductUtilityState;
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
public class ProductUtilityStateService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<ProductUtilityState> getProductUtilityStatesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<ProductUtilityState> results = sqlCache.query("propToolProductUtilityState.getAllForCompany", params, ProductUtilityState.class);
    return results;
  }

  public Optional<ProductUtilityState> getProductUtilityState(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ProductUtilityState> results = sqlCache.get("propToolProductUtilityState.getOne", params, ProductUtilityState.class);
    return results;
  }

  public Optional<ProductUtilityState> saveProductUtilityState(ProductUtilityState p) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("productId", p.getProductId());
    params.put("active", p.getActive());
    params.put("fundingCap", p.getFundingCap());
    params.put("targetProductionFactor", p.getTargetProductionFactor());
    params.put("utilityStateId", p.getUtilityStateId());
    Long id;

    if(null != p.getId()) {
      id = p.getId();
      params.put("modifiedById", user.trueUserId());
      params.put("id", id);
      sqlCache.update("propToolProductUtilityState.update", params);
    } else {
      params.put("createdById", user.trueUserId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolProductUtilityState.insert", params, "id").longValue();
    }

    return getProductUtilityState(id);
  }

  public void deleteProductUtilityState(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("propToolProductUtilityState.delete", params);
  }

}
