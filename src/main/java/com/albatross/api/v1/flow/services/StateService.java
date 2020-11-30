package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyState;
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

  public List<CompanyState> getAllStates() {
    List<CompanyState> states = sqlCache.query("state.getAllStates", Collections.emptyMap(), CompanyState.class);
    return states;
  }

  public List<CompanyState> getAvailableStates() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyState> states = sqlCache.query("state.getAvailableStates", params, CompanyState.class);
    return states;
  }

  public List<CompanyState> getActiveStatesByCompany() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyState> states = sqlCache.query("state.getActiveStatesByCompany", params, CompanyState.class);
    return states;
  }

  public List<CompanyState> getAllCompanyStates(Long companyId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", null != companyId ? companyId : user.getCompanyId());
    List<CompanyState> states = sqlCache.query("state.getAllCompanyStates", params, CompanyState.class);
    return states;
  }

  public CompanyState getOneCompanyState(Long companyStateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyStateId", companyStateId);
    Optional<CompanyState> state = sqlCache.get("state.getOneCompanyState", params, CompanyState.class);
    return state.orElse(null);
  }

  public void deleteCompanyState(Long companyStateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyStateId", companyStateId);
    sqlCache.update("state.deleteCompanyState", params);
  }

  public CompanyState saveCompanyState(CompanyState state) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("active", state.getActive() != null ? state.getActive() : true);
    params.put("mapLatitude", state.getMapLatitude());
    params.put("mapLongitude", state.getMapLongitude());
    params.put("mapZoom", state.getMapZoom());
    params.put("stateId", state.getStateId());

    Long companyStateId;
    if(null != state.getId()) {
      companyStateId = state.getId();
      params.put("companyStateId", companyStateId);
      sqlCache.update("state.updateCompanyState", params);

    } else {
      companyStateId = sqlCache.updateReturningId("state.insertCompanyState", params, "id").longValue();
    }
    return getOneCompanyState(companyStateId);
  }

  public List<CompanyState> getActiveStatesByHierarchy() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    // i dont even know why we have this anymore
    List<CompanyState> states = sqlCache.query("state.getActiveStatesByHierarchy", params, CompanyState.class);
    return states;
  }

}
