package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.smartlistv2.Smartlistv2;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class Smartlistv2Service {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final ObjectMapper om;

  public List<Smartlistv2> getMine() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("companyId", user.getCompanyId(), "userId", user.getId());
    return sqlCache.query("smartlistv2.getMine", params, Smartlistv2.class);
  }
}
