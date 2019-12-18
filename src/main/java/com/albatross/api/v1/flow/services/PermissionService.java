package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Permission;
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
public class PermissionService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<Permission> getPermissionsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Permission> results = sqlCache.query("permission.getAllForCompany", params, Permission.class);
    return results;
  }

  public Permission savePermission(Permission p) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("permissionName", p.getPermissionName());
    params.put("permissionCode", p.getPermissionCode());
    Long id;
    if(null != p.getId()) {
      id = p.getId();
      params.put("id", p.getId());
      sqlCache.update("permission.updatePermission", params);
    } else {
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("permission.insertPermission", params, "id").longValue();
    }
    return getPermission(id);
  }

  public Permission getPermission(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Permission> result = sqlCache.get("permission.getOne", params, Permission.class);
    return result.orElse(null);
  }

}
