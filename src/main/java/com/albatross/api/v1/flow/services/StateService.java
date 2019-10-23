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

}
