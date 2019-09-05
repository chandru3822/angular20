package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
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

  public String getCustomFieldValuesByPrimaryIdAndType(Long companyId, Long primaryId, Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("primaryId", primaryId);
    params.put("objectTypeId", objectTypeId);

    String results = sqlCache.queryForObject("customFieldValues.getCustomFieldValuesByPrimaryIdAndType", params, String.class);
    return results;
  }
}
