package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyFeature;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.Role;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.RoleQuery;
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
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class RoleService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;

  private final SecurityService securityService;

  public List<Role> getRolesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Role> results = sqlCache.queryBySql(RoleQuery.getAllForCompany, params, Role.class);
    return results;
  }


  public Role getRole(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", user.getCompanyId());
    Optional<Role> result = sqlCache.getBySql(RoleQuery.getOne, params, new RoleMapper<>(Role.class, om));
    return result.orElse(null);
  }

  public Role insertRole(Role role) {
    User user = securityService.getCurrentUser();
    //insert role and get ID back
    HashMap<String, Object> params = new HashMap<>();
    params.put("roleName", role.getRoleName());
    params.put("companyId", user.getCompanyId());
    Long roleId = sqlCache.updateBySqlReturningId(RoleQuery.insertRole, params, "id").longValue();

    for(CompanyFeature cf : role.getCompanyFeatures()) {
      for(FeatureAccessControl ac : cf.getAccessControl()) {
        if(ac.isEnabled()) {
          params.put("companyFeatureId", cf.getId());
          params.put("accessControlId", ac.getId());
          params.put("roleId", roleId);
          sqlCache.updateBySql(RoleQuery.insertRoleFeatureAccessControl, params);
        }
      }
    }
    return getRole(roleId);
  }

  public void deleteRole(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.updateBySql(RoleQuery.archiveRole, params);
  }

  public Role updateRole(Role role) {
    //update the name
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", role.getId());
    params.put("roleName", role.getRoleName());
    sqlCache.updateBySql(RoleQuery.updateRole, params);

    for(CompanyFeature cf : role.getCompanyFeatures()) {
      for (FeatureAccessControl ac : cf.getAccessControl()) {
        if(null != ac.getId()) {
          params.put("enabled", ac.isEnabled());
          params.put("roleFeatureAccessControlId", ac.getAccessControlId());
          sqlCache.updateBySql(RoleQuery.updateRoleFeatureAccessControl, params);
        } else if (ac.isEnabled()) {
          params.put("companyFeatureId", cf.getId());
          params.put("accessControlId", ac.getAccessControlId());
          params.put("roleId", role.getId());
          sqlCache.updateBySql(RoleQuery.insertRoleFeatureAccessControl, params);
        }
      }
    }
    // todo look into making this an upsert

    return getRole(role.getId());
  }

  public Role saveRole(Role role) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("aField", role.getId());

    Long id;
    if (null != role.getId()) {
      id = role.getId();
      params.put("modifiedById", user.getCompanyId());
      params.put("id", id);
      sqlCache.updateBySql(RoleQuery.updateRole, params);
    } else {
      params.put("createdById", user.getCompanyId());
      id = sqlCache.updateBySqlReturningId(RoleQuery.insertRole, params, "id").longValue();
    }

    return getRole(id);
  }

  public static class RoleMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public RoleMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
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
