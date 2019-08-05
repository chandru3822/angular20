package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyFunction;
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
public class CompanyFunctionService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<CompanyFunction> getCompanyFunctions(Long companyId) {
//    todo: add companyId in
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    List<CompanyFunction> results = sqlCache.query("companyFunction.getFunctions", params, CompanyFunction.class);
    return results;
  }

}
