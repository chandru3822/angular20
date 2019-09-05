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

  @Autowired
  NamedParameterJdbcTemplate jdbc;

  public String getCustomFieldValuesByPrimaryIdAndType(Long companyId, Long primaryId, Long objectTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("primaryId", primaryId);
    params.put("objectTypeId", objectTypeId);

//    List<CustomFieldGroup> results = sqlCache.query("customFieldValues.getCustomFieldValuesByPrimaryIdAndType", params, CustomFieldGroup.class);
    String results = sqlCache.queryForObject("customFieldValues.getCustomFieldValuesByPrimaryIdAndType", params, String.class);
//    String sql = sqlCache.getByKey("customFieldValues.getCustomFieldValuesByPrimaryIdAndType");
//    String results = jdbc.queryForObject(sql, params, String.class);
    return results;
  }
}
