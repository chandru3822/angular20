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

  private final SecurityService securityService;

  public List<Position> getPositionsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Position> results = sqlCache.query("position.getAllForCompany", params, Position.class);
    return results;
  }

  public Position getPosition(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Position> result = sqlCache.get("position.getOne", params, Position.class);
    return result.orElse(null);
  }

  public Position savePosition(Position p) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("orgTypeId", p.getOrgTypeId());
    params.put("position", p.getPosition());
    Long id;
    if(null != p.getId()) {
      id = p.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());
      sqlCache.update("position.update", params);
    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("position.insert", params, "id").longValue();
    }
    return getPosition(id);
  }

  public void deletePosition(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());
    sqlCache.update("position.delete", params);
  }



}
