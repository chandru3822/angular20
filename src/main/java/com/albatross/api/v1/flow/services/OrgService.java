package com.albatross.api.v1.flow.services;

import java.util.HashMap;
import java.util.List;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Org;
import com.albatross.api.v1.flow.model.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class OrgService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<Org> getOrgsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Org> results = sqlCache.query("org.getAllForCompany", params, Org.class);
    return results;
  }
  public List<Org> getOwningOrgsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Org> results = sqlCache.query("org.getOwningOrgsForCompany", params, Org.class);
    return results;
  }

}
