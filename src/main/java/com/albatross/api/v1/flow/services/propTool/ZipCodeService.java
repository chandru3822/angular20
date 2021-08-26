package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.ZipCode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ZipCodeService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<ZipCode> getZipCodesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<ZipCode> results = sqlCache.query("propToolZipCode.getAllForCompany", params, ZipCode.class);
    return results;
  }

  public Optional<ZipCode> getZipCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ZipCode> results = sqlCache.get("propToolZipCode.getOne", params, ZipCode.class);
    return results;
  }

  public Optional<ZipCode> saveZipCode(ZipCode zipCode) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("zipCode", zipCode.getZipCode());
    params.put("active", zipCode.getActive());
    Long id;

    if(null != zipCode.getId()) {
      id = zipCode.getId();
      params.put("modifiedById", user.trueUserId());
      params.put("id", id);
      sqlCache.update("propToolZipCode.update", params);
    } else {
      params.put("createdById", user.trueUserId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolZipCode.insert", params, "id").longValue();
    }

    return getZipCode(id);
  }

  public void deleteZipCode(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("propToolZipCode.delete", params);
  }

}
