package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ErrorLog;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ErrorLogService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  public List<ErrorLog> getErrorLogsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<ErrorLog> results = sqlCache.query("errorLog.getAllForCompany", params, ErrorLog.class);
    return results;
  }

  public void deleteErrorLog(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("id", id);
    sqlCache.update("errorLog.delete", params);
  }

}
