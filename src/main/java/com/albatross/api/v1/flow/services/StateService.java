package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.State;
import com.albatross.api.v1.flow.model.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
public class StateService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<State> getAllStates() {
    List<State> states = sqlCache.query("state.getAllStates", Collections.emptyMap(), State.class);
    return states;
  }

  public List<State> getActiveStatesByCompany() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<State> states = sqlCache.query("state.getActiveStatesByCompany", params, State.class);
    return states;
  }

  public List<State> getAllStatesByCompany() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<State> states = sqlCache.query("state.getAllStatesByCompany", params, State.class);
    return states;
  }

  public State getOneCompanyState(Long companyStateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyStateId", companyStateId);
    Optional<State> state = sqlCache.get("state.getOneCompanyState", params, State.class);
    return state.orElse(null);
  }

  public void deleteCompanyState(Long companyStateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyStateId", companyStateId);
    sqlCache.update("state.deleteCompanyState", params);
  }

  public State saveCompanyState(State state) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("active", state.getActive() != null ? state.getActive() : true);
    params.put("mapLatitude", state.getMapLatitude());
    params.put("mapLongitude", state.getMapLongitude());
    params.put("mapZoom", state.getMapZoom());
    params.put("stateId", state.getId());

    Long companyStateId;
    if(null != state.getCompanyStateId()) {
      companyStateId = state.getCompanyStateId();
      params.put("companyStateId", companyStateId);
      sqlCache.update("state.updateCompanyState", params);

    } else {
      companyStateId = sqlCache.updateReturningId("state.insertCompanyState", params, "id").longValue();
    }
    return getOneCompanyState(companyStateId);
  }

  public List<State> getActiveStatesByHierarchy() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<State> states = sqlCache.query("state.getActiveStatesByHierarchy", params, State.class);
    return states;
  }

}
