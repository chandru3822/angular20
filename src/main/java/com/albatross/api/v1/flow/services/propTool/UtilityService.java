package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Utility;
import com.albatross.api.v1.flow.model.propTool.UtilityState;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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
public class UtilityService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Utility> getUtilitiesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Utility> results = sqlCache.query("propToolUtility.getAllForCompany", params, new UtilityMapper<>(Utility.class, om));
    return results;
  }

  public Optional<Utility> getUtility(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Utility> results = sqlCache.get("propToolUtility.getOne", params, new UtilityMapper<>(Utility.class, om));
    return results;
  }

  public Optional<Utility> saveUtility(Utility utility) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("utilityCompany", utility.getUtilityCompany());
    params.put("modifiedById", user.getId());
    params.put("createdById", user.getId());
    params.put("active", utility.getActive());
    params.put("companyId", user.getCompanyId());
    Long id;

    if(null != utility.getId()) {
      id = utility.getId();
      params.put("id", id);
      sqlCache.update("propToolUtility.update", params);
    } else {
      id = sqlCache.updateReturningId("propToolUtility.insert", params, "id").longValue();
    }

    for(UtilityState utilityState : utility.getUtilityStates()) {
      params.put("costPerKwh", utilityState.getCostPerKwh());
      params.put("escalator", utilityState.getEscalator());
      params.put("utilityId", id);
      params.put("archived", utilityState.isArchived());

      if(null != utilityState.getId()) {
        params.put("utilityStateId", utilityState.getId());
        sqlCache.update("propToolUtility.updateUtilityState", params);
      } else {
        if (!utilityState.isArchived()) {
          if (!params.containsKey("createdById")) {
            params.put("createdById", user.getId());
          }
          params.put("companyStateId", utilityState.getCompanyStateId());
          sqlCache.update("propToolUtility.insertUtilityState", params);
        }
      }

    }

    return getUtility(id);
  }

  public void deleteUtility(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("propToolUtility.delete", params);
  }

  public List<UtilityState> getUtilityStatesByCompanyStateId(Long companyStateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyStateId", companyStateId);
    List<UtilityState> results = sqlCache.query("propToolUtility.getUtilityStatesByCompanyStateId", params, UtilityState.class);
    return results;
  }

  public static class UtilityMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UtilityMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<UtilityState>> utilityStateRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "utilityStates",
          new JsonCollectionDeserializer(utilityStateRef, objectMapper));
    }
  }
}
