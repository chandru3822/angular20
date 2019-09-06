package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CustomFieldValueService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public String getCustomFieldValuesByPrimaryIdAndType(Long companyId, Long primaryId, Integer objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("primaryId", primaryId);
    params.put("objectTypeId", objectTypeId);

    String results = sqlCache.queryForObject("customFieldValues.getCustomFieldValuesByPrimaryIdAndType", params, String.class);
    return results;
  }

  public String getProjectCustomValues(Long companyId, int objectTypeId, Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("objectTypeId", objectTypeId);
    params.put("projectId", projectId);

    return sqlCache.queryForObject("customFieldValues.getProjectFieldValues", params, String.class);
  }
}
