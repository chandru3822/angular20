package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Role;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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

  private final SecurityService securityService;

  public List<Role> getRolesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Role> results = sqlCache.query("role.getAllForCompany", params, Role.class);
    return results;
  }


  public Role getRole(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Role> result = sqlCache.get("role.getOne", params, Role.class);
    return result.orElse(null);
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
      sqlCache.update("role.updateRole", params);
    } else {
      params.put("createdById", user.getCompanyId());
      id = sqlCache.updateReturningId("role.insertRole", params, "id").longValue();
    }

    return getRole(id);
  }


}
