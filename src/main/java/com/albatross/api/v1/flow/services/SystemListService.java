package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.SystemList;
import com.albatross.api.v1.flow.model.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class SystemListService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<SystemList> getSystemListsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<SystemList> results = sqlCache.query("systemList.getSystemListsForCompany", params, SystemList.class);
    return results;
  }

  public List<ListOfValue> getSystemListOptionsForCompany(Long listId, Boolean subOptions, List<Long> systemListOptionIds) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("systemListId", listId);
    params.put("subOptions", subOptions);
    params.put("systemListOptionIds", systemListOptionIds);
    String sqlKey = "systemList.getSystemListOptionsForCompany";

    List<ListOfValue> results = sqlCache.query(sqlKey, params, ListOfValue.class);
    return results;
  }

}
