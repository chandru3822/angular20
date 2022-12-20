package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ErrorLog;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.ErrorLogQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ErrorLogService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<ErrorLog> getErrorLogsForCompany() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(ErrorLogQuery.getAllForCompany, params, ErrorLog.class);
  }

  public void deleteErrorLog(Long id) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("id", id);
    sqlCache.updateBySql(ErrorLogQuery.delete, params);
  }
}
