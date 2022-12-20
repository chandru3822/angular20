package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.SystemList;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.SystemListQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class SystemListService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<SystemList> getSystemListsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    return sqlCache.queryBySql(SystemListQuery.getSystemListsForCompany, params, SystemList.class);
  }

  public List<ListOfValue> getSystemListOptionsForCompany(
      Long listId, Boolean subOptions, List<Long> systemListOptionIds, Long companyId) {
    return getSystemListOptionsForCompany(listId, subOptions, systemListOptionIds, null, companyId);
  }

  public List<ListOfValue> getSystemListOptionsForCompany(
      Long listId,
      Boolean subOptions,
      List<Long> systemListOptionIds,
      Long intValue,
      Long companyId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", null != companyId ? companyId : user.getCompanyId());
    params.put("systemListId", listId);
    params.put("subOptions", subOptions);
    params.put("systemListOptionIds", systemListOptionIds);
    params.put("intValue", intValue);

    return sqlCache.queryBySql(SystemListQuery.getSystemListOptionsForCompany, params, ListOfValue.class);
  }
}
