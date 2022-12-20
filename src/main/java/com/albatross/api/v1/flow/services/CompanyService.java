package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.Company;
import com.albatross.api.v1.flow.model.CompanyConfigurationValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.CompanyQuery;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class CompanyService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final AttachmentService attachmentService;

  public List<Company> getCompanies() {
    List<Company> results = sqlCache.queryBySql(CompanyQuery.getAll, null, Company.class);

    for (Company c : results) {
      // set the attachment presigned url, 29 = COMPANY_LOGO
      Attachment a = attachmentService.getOneBySourceIdAndType(c.getId(), 29L);
      c.setLogoPresignedUrl(null != a ? a.getPresignedUrl() : null);
    }
    return results;
  }

  public List<Company> getCompaniesAssignedToUser(Long userId) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId != null ? userId : currentUser.getId());
    List<Company> results =
        sqlCache.queryBySql(CompanyQuery.getCompaniesAssignedToUser, params, Company.class);

    for (Company c : results) {
      // set the attachment presigned url, 29 = COMPANY_LOGO
      Attachment a = attachmentService.getOneBySourceIdAndType(c.getId(), 29L);
      c.setLogoPresignedUrl(null != a ? a.getPresignedUrl() : null);
    }

    return results;
  }

  public List<Company> getCompaniesAvailableForUser() {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    // this is hardcoded to NOT return albatross as access to albatross is not controlled via
    // user_company

    return sqlCache.queryBySql(CompanyQuery.getCompaniesAvailableForUser, params, Company.class);
  }

  public Optional<Company> getCompany(Long id) {
    return sqlCache.getBySql(CompanyQuery.getById, ImmutableMap.of("id", id), Company.class);
  }

  public Optional<Company> saveCompany(Company company) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", company.getId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("companyName", company.getCompanyName());
    params.put("defaultPassword", company.getDefaultPassword());
    params.put("minuteIncrement", company.getMinuteIncrement());
    sqlCache.updateBySql(CompanyQuery.updateCompany, params);
    return getCompany(company.getId());
  }

  // configuration values
  public List<CompanyConfigurationValue> getCompanyConfigurationValues(Long companyId) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", companyId);
    //    for now we filter out the readonly values and don't even display them
    return sqlCache.queryBySql(
      CompanyQuery.getConfigurationValues, params, CompanyConfigurationValue.class);
  }

  public void saveCompanyConfigurationValue(CompanyConfigurationValue ccv) {
    User currentUser = securityService.getCurrentUser();

    if (!currentUser.getCompanyId().equals(ccv.getCompanyId())) {
      throw new ResponseStatusException(
          HttpStatus.UNAUTHORIZED, "You do not have access to edit this value.", new Exception());
    } else {
      HashMap<String, Object> params = new HashMap<>();
      params.put("id", ccv.getId());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("value", ccv.getValue());
      sqlCache.updateBySql(CompanyQuery.updateConfigurationValue, params);
    }
  }
}
