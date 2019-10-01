package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Position;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


/**
 * Created by randanunn on 10/1/19.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class PositionService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<Position> getPositionsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Position> results = sqlCache.query("position.getAllForCompany", params, Position.class);
    return results;
  }



}
