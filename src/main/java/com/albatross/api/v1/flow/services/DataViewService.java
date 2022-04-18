package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.DataView;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@Slf4j
@Service
@RequiredArgsConstructor
public class DataViewService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<DataView> getCompanyDataViews() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.query("dataView.getAllForCompany", params, DataView.class);
  }


  public Optional<DataView> getView(Long viewId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
//    use company id to verify user has access to this view
    params.put("companyId", user.getCompanyId());
    params.put("viewId", viewId);
    Optional<DataView> result = sqlCache.get("dataView.getOne", params, DataView.class);
    return result;
  }

}
