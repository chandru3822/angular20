package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.queries.ReleaseQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Created by Alex Acevedo on 06/27/24.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ReleaseService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;

  public List<Release> getAllReleases() {
    return sqlCache.queryBySql(ReleaseQuery.getAll, Map.of(), Release.class);
  }

  public List<Release> saveRelease(Release r) {

    Map<String, Object> params = new HashMap<>();
    params.put("name", r.getReleaseName());
    params.put("stageLockDate", r.getStageLockDate());
    params.put("uatLockDate", r.getUatLockDate());
    params.put("releaseDate", r.getReleaseDate());
    params.put("archived", r.getArchived());
    params.put("userId", securityService.getCurrentUser().getId());

    Long id;
    if (null != r.getId()) {
      id = r.getId();
      params.put("id", id);
      sqlCache.updateBySql(ReleaseQuery.updateRelease, params);

    } else {
      id = sqlCache.updateBySqlReturningId(ReleaseQuery.insertRelease, params, "id").longValue();
    }
    if(id != null){
      return getAllReleases();
    }
    else{
      return null;
    }
  }

  public Release getNextRelease() {
    Map<String, Object> params = new HashMap<>();
    Optional<Release> r = sqlCache.getBySql(ReleaseQuery.getNextRelease, params, Release.class);
    return r.orElse(null);
  }

  public Release getOneRelease(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Release> r = sqlCache.getBySql(ReleaseQuery.getOneRelease, params, Release.class);
    return r.orElse(null);
  }

  public List<Release> deleteRelease(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    sqlCache.updateBySql(ReleaseQuery.deleteRelease, params);
    return getAllReleases();
  }

}
