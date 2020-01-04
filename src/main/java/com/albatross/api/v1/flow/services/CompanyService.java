package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.Company;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CompanyService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final AttachmentService attachmentService;

  public List<Company> getCompanies() {
    List<Company> results = sqlCache.query("company.getAll", null, Company.class);

    for(Company c : results) {
      // set the attachment presigned url, 29 = COMPANY_LOGO
      Attachment a = attachmentService.getOneBySourceIdAndType(c.getId(), 29L);
      c.setLogoPresignedUrl(null != a ? a.getPresignedUrl() : null);
    }
    return results;
  }

  public List<Company> getCompaniesAssignedToUser(Long userId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId != null ? userId : currentUser.getId());

    return sqlCache.query("company.getCompaniesAssignedToUser", params, Company.class);
  }

  public List<Company> getCompaniesAvailableForUser(Long userId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId != null ? userId : currentUser.getId());

    return sqlCache.query("company.getCompaniesAvailableForUser", params, Company.class);
  }

  public Optional<Company> getCompany(Long id) {
    return sqlCache.get("company.getById", ImmutableMap.of("id", id), Company.class);
  }

  public Optional<Company> saveCompany(Company company) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", company.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("companyName", company.getCompanyName());
    sqlCache.update("company.updateCompany", params);
    return getCompany(company.getId());
  }
}
