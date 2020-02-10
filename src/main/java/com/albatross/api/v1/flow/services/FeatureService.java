package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class FeatureService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;

  private final SecurityService securityService;

  public List<Feature> getAllFeatures() {
    User user = securityService.getCurrentUser();
    List<Feature> results = sqlCache.query("feature.getAll", Collections.EMPTY_MAP, Feature.class);
    return results;
  }

  public Feature saveFeature(Feature f) {
    //this is used for adding/updating features to system
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("featureName", f.getFeatureName());
    params.put("featureCode", f.getFeatureCode());
    params.put("isSystem", null != f.getIsSystem() ? f.getIsSystem() : false);

    Long id;
    if(null != f.getId()) {
      id = f.getId();
      params.put("id", id);
      sqlCache.update("feature.updateFeature", params);

    } else {
      id = sqlCache.updateReturningId("feature.insertFeature", params, "id").longValue();
    }
    return getOneFeature(id);
  }

  public Feature getOneFeature(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Feature> f = sqlCache.get("feature.getOneFeature", params, Feature.class);
    return f.orElse(null);
  }

  public void deleteFeature(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("feature.deleteFeature", params);
  }

  public List<CompanyFeature> getFeaturesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyFeature> results = sqlCache.query("feature.getAllForCompany", params, CompanyFeature.class);
    return results;
  }

  public List<CompanyFeature> getFeaturesForCompanyWithAccess() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyFeature> results = sqlCache.query("feature.getAllForCompanyWithAccess", params, new CompanyFeatureMapper<>(CompanyFeature.class, om));
    return results;
  }

  public List<CompanyFeature> getFeaturesForUser(Long userId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);
    List<CompanyFeature> results = sqlCache.query("feature.getForUser", params, new CompanyFeatureMapper<>(CompanyFeature.class, om));
    return results;
  }

  public void saveUserCompanyFeatures(Long userId, List<CompanyFeature> features) {
    HashMap<String, Object> params = new HashMap<>();

    for(CompanyFeature cf : features) {
      for (FeatureAccessControl ac : cf.getAccessControl()) {
        if(null != ac.getId()) {
          params.put("enabled", ac.isEnabled());
          params.put("userFeatureAccessControlId", ac.getAccessControlId());
          sqlCache.update("feature.updateUserFeatureAccessControl", params);
        } else if (ac.isEnabled()) {
          params.put("companyFeatureId", cf.getId());
          params.put("accessControlId", ac.getAccessControlId());
          params.put("userId", userId);
          sqlCache.update("feature.insertUserFeatureAccessControl", params);
        }
      }
    }
  }

  public CompanyFeature getOneCompanyFeature(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<CompanyFeature> cf = sqlCache.get("feature.getOneCompanyFeature", params, CompanyFeature.class);
    return cf.orElse(null);
  }

  public void deleteCompanyFeature(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.update("feature.deleteCompanyFeature", params);
  }

  public CompanyFeature saveCompanyFeature(CompanyFeature cf) {
    //this is used for adding/updating company features to company
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("featureName", cf.getFeatureName());
    params.put("featureId", cf.getFeatureId());

    Long id;
    if(null != cf.getId()) {
      id = cf.getId();
      params.put("id", id);
      sqlCache.update("feature.updateCompanyFeature", params);

    } else {
      id = sqlCache.updateReturningId("feature.insertCompanyFeature", params, "id").longValue();
    }
    return getOneCompanyFeature(id);
  }

  public static class CompanyFeatureMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CompanyFeatureMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<FeatureAccessControl>> accessControlRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "accessControl",
          new JsonCollectionDeserializer(accessControlRef, objectMapper));

    }
  }

}
