package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Incentive;
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
public class IncentiveService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Incentive> getIncentivesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Incentive> results = sqlCache.query("propToolIncentive.getAllForCompany", params, Incentive.class);
    return results;
  }

  public Optional<Incentive> getIncentive(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Incentive> results = sqlCache.get("propToolIncentive.getOne", params, Incentive.class);
    return results;
  }

  public Optional<Incentive> saveIncentive(Incentive incentive) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("incentive", incentive.getIncentive());
    Long id;

    if(null != incentive.getId()) {
      id = incentive.getId();
      params.put("modifiedById", user.getId());
      params.put("id", id);
      sqlCache.update("propToolIncentive.update", params);
    } else {
      params.put("createdById", user.getId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolIncentive.insert", params, "id").longValue();
    }

    return getIncentive(id);
  }

  public void deleteIncentive(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("propToolIncentive.delete", params);
  }

}
