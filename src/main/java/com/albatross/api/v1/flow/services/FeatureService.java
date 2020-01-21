package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.CompanyFeature;
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
