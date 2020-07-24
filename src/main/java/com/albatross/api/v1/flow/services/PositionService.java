package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyFeature;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.Position;
import com.albatross.api.v1.flow.model.User;
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
 * Created by randanunn on 10/1/19.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class PositionService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;

  private final SecurityService securityService;

  public List<Position> getPositionsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Position> results = sqlCache.query("position.getAllForCompany", params, Position.class);
    return results;
  }

  public List<Position> getSchedulingPositions() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);

    List<Position> results = sqlCache.query("position.getSchedulingPositions", params, Position.class);
    return results;
  }


  public List<Position> getPositionsForCompanyWithParent() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    List<Position> results = sqlCache.query("position.getAllForCompanyWithParent", params, Position.class);
    return results;
  }

  public Position getPosition(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", user.getCompanyId());
    Optional<Position> result = sqlCache.get("position.getOne", params, new PositionMapper<>(Position.class, om));
    return result.orElse(null);
  }

  public Position insertPosition(Position p) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgTypeId", p.getOrgTypeId());
    params.put("position", p.getPosition());
    params.put("schedulable", null != p.getSchedulable() ? p.getSchedulable() : false);
    params.put("availableToChildren", null != p.getAvailableToChildren() ? p.getAvailableToChildren() : false);
    params.put("createdById", user.getId());
    Long positionId = sqlCache.updateReturningId("position.insert", params, "id").longValue();

    for(CompanyFeature cf : p.getCompanyFeatures()) {
      for(FeatureAccessControl ac : cf.getAccessControl()) {
        if(ac.isEnabled()) {
          params.put("companyFeatureId", cf.getId());
          params.put("accessControlId", ac.getId());
          params.put("positionId", positionId);
          sqlCache.update("position.insertPositionFeatureAccessControl", params);
        }
      }
    }

    return getPosition(positionId);
  }

  public Position updatePosition(Position p) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgTypeId", p.getOrgTypeId());
    params.put("position", p.getPosition());
    params.put("schedulable", null != p.getSchedulable() ? p.getSchedulable() : false);
    params.put("availableToChildren", null != p.getAvailableToChildren() ? p.getAvailableToChildren() : false);
    params.put("id", p.getId());
    params.put("modifiedById", user.getId());
    sqlCache.update("position.update", params);

    for(CompanyFeature cf : p.getCompanyFeatures()) {
      for (FeatureAccessControl ac : cf.getAccessControl()) {
        if(null != ac.getId()) {
          params.put("enabled", ac.isEnabled());
          params.put("positionFeatureAccessControlId", ac.getAccessControlId());
          sqlCache.update("position.updatePositionFeatureAccessControl", params);
        } else if (ac.isEnabled()) {
          params.put("companyFeatureId", cf.getId());
          params.put("accessControlId", ac.getAccessControlId());
          params.put("positionId", p.getId());
          sqlCache.update("position.insertPositionFeatureAccessControl", params);
        }
      }
    }

    return getPosition(p.getId());
  }

  public void deletePosition(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());
    sqlCache.update("position.delete", params);
  }

  public static class PositionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PositionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {

      TypeReference<List<CompanyFeature>> companyFeaturesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "companyFeatures",
          new JsonCollectionDeserializer(companyFeaturesRef, objectMapper));

    }
  }


}
