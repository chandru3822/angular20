package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Incentive;
import com.albatross.api.v1.flow.model.propTool.IncentiveCategory;
import com.albatross.api.v1.flow.model.propTool.IncentiveEntity;
import com.albatross.api.v1.flow.model.propTool.IncentiveType;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
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

    List<Incentive> results = sqlCache.query("propToolIncentive.getAllIncentivesForCompany", params, Incentive.class);
    return results;
  }

  public List<IncentiveCategory> getIncentivesCategories() {
    List<IncentiveCategory> results = sqlCache.query("propToolIncentive.getCategories", Collections.emptyMap(), IncentiveCategory.class);
    return results;
  }

  public List<IncentiveType> getIncentivesTypes() {
    List<IncentiveType> results = sqlCache.query("propToolIncentive.getTypes", Collections.emptyMap(), IncentiveType.class);
    return results;
  }

  public List<IncentiveEntity> getIncentiveEntities(Long categoryId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    String sqlKey = null;

    if (categoryId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.COUNTRY.id)) {
      sqlKey = "propToolIncentive.getCountryEntities";
    } else if (categoryId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.STATE.id)) {
      sqlKey = "propToolIncentive.getStateEntities";
    } else if (categoryId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.UTILITY_STATE.id)) {
      sqlKey = "propToolIncentive.getUtilityStateEntities";
    }

    if (null != sqlKey) {
      List<IncentiveEntity> results = sqlCache.query(sqlKey, params, IncentiveEntity.class);
      return results;
    } else {
      return null;
    }
  }

  public Optional<Incentive> saveIncentive(Incentive incentive) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("incentiveCategoryId", incentive.getIncentiveCategoryId());
    params.put("incentiveTypeId", incentive.getIncentiveTypeId());
    params.put("amount", incentive.getAmount());
    params.put("active", incentive.getActive());
    params.put("incentiveEntityId", incentive.getIncentiveEntityId());

    String sqlKey = null;

    Long id;
    if(null != incentive.getId()) {
      id = incentive.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());

      if (incentive.getIncentiveCategoryId().equals(com.albatross.api.v1.flow.enums.IncentiveCategory.COUNTRY.id)) {
        sqlKey = "propToolIncentive.updateCountryIncentive";
      } else if (incentive.getIncentiveCategoryId().equals(com.albatross.api.v1.flow.enums.IncentiveCategory.STATE.id)) {
        sqlKey = "propToolIncentive.updateStateIncentive";
      } else if (incentive.getIncentiveCategoryId().equals(com.albatross.api.v1.flow.enums.IncentiveCategory.UTILITY_STATE.id)) {
        sqlKey = "propToolIncentive.updateUtilityStateIncentive";
      }
      sqlCache.update(sqlKey, params);
    } else {
      params.put("createdById", user.getId());
      if (incentive.getIncentiveCategoryId().equals(com.albatross.api.v1.flow.enums.IncentiveCategory.COUNTRY.id)) {
        sqlKey = "propToolIncentive.insertCountryIncentive";
      } else if (incentive.getIncentiveCategoryId().equals(com.albatross.api.v1.flow.enums.IncentiveCategory.STATE.id)) {
        sqlKey = "propToolIncentive.insertStateIncentive";
      } else if (incentive.getIncentiveCategoryId().equals(com.albatross.api.v1.flow.enums.IncentiveCategory.UTILITY_STATE.id)) {
        sqlKey = "propToolIncentive.insertUtilityStateIncentive";
      }
      id = sqlCache.updateReturningId(sqlKey, params, "id").longValue();
    }

    return getIncentiveById(id, incentive.getIncentiveCategoryId());
  }

  public Optional<Incentive> getIncentiveById(Long id, Long categoryTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    String sqlKey = null;
    if (categoryTypeId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.COUNTRY.id)) {
      sqlKey = "propToolIncentive.getCountryIncentiveById";
    } else if (categoryTypeId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.STATE.id)) {
      sqlKey = "propToolIncentive.getStateIncentiveById";
    } else if (categoryTypeId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.UTILITY_STATE.id)) {
      sqlKey = "propToolIncentive.getUtilityStateIncentiveById";
    }
    Optional<Incentive> result = sqlCache.get(sqlKey, params, Incentive.class);
    return result;
  }

  public void deleteIncentive(Long id, Long categoryTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    String sqlKey = null;
    if (categoryTypeId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.COUNTRY.id)) {
      sqlKey = "propToolIncentive.deleteCountryIncentive";
    } else if (categoryTypeId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.STATE.id)) {
      sqlKey = "propToolIncentive.deleteStateIncentive";
    } else if (categoryTypeId.equals(com.albatross.api.v1.flow.enums.IncentiveCategory.UTILITY_STATE.id)) {
      sqlKey = "propToolIncentive.deleteUtilityStateIncentive";
    }

    sqlCache.update(sqlKey, params);
  }


}
