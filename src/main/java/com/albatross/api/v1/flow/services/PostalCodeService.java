package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.queries.PostalCodeQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PostalCodeService {

  private final SqlCache sqlCache;
  private final SqlArrayService sqlArrayService;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<PostalCode> getPostalCodes() {
    return sqlCache.queryBySql(PostalCodeQuery.getActivePostalCodes, Collections.emptyMap(), PostalCode.class);
  }

  public Optional<PostalCode> getPostalCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(PostalCodeQuery.getPostalCodeById, params, PostalCode.class);
  }

  public Optional<PostalCode> savePostalCode(PostalCode postalCode) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("roundRobinId", postalCode.getRoundRobinId());
    params.put("placeName", postalCode.getPlaceName());
    params.put("notes", postalCode.getNotes());
    params.put("active", postalCode.getActive());
    params.put("disqualified", postalCode.getDisqualified());
    params.put("userId", user.trueUserId());
    Long id;

    if(null != postalCode.getId()) {
      id = postalCode.getId();
      params.put("id", id);
      sqlCache.updateBySql(PostalCodeQuery.updatePostalCode, params);
    } else {
      params.put("postalCode", postalCode.getPostalCode());
      id = sqlCache.updateBySqlReturningId(PostalCodeQuery.insertPostalCode, params, "id").longValue();
    }
    return getPostalCode(id);
  }

  public List<PostalCodeZone> getPostalCodeZones() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    return sqlCache.queryBySql(PostalCodeQuery.getPostalCodeZones, params, PostalCodeZone.class);
  }

  public Optional<PostalCodeZone> getPostalCodeZone(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(PostalCodeQuery.getPostalCodeZoneById, params, new PostalCodeZoneMapper<>(PostalCodeZone.class, om));
  }

  public Optional<PostalCodeZone> savePostalCodeZone(PostalCodeZone postalCodeZone) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("metroAreaId", postalCodeZone.getMetroAreaId());
    params.put("zoneName", postalCodeZone.getZoneName());
    params.put("userId", user.trueUserId());
    Long id;

    if(null != postalCodeZone.getId()) {
      id = postalCodeZone.getId();
      params.put("id", id);
      sqlCache.updateBySql(PostalCodeQuery.updatePostalCodeZone, params);
    } else {
      id = sqlCache.updateBySqlReturningId(PostalCodeQuery.insertPostalCodeZone, params, "id").longValue();
    }
    return getPostalCodeZone(id);
  }

  public List<PostalCode> getAvailablePostalCodesForZone(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.queryBySql(PostalCodeQuery.getAvailablePostalCodesForZone, params, PostalCode.class);
  }

  public Optional<PostalCodeZonePostalCode> savePostalCodeToZone(Long zoneId, PostalCode postalCode) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("zoneId", zoneId);
    params.put("postalCodeId", postalCode.getId());
    params.put("userId", user.trueUserId());

    Long id = sqlCache.updateBySqlReturningId(PostalCodeQuery.insertPostalCodeZonePostalCode, params, "id").longValue();
    return getOnePostalCodeToZone(id);
  }

  public void deletePostalCodeFromZone(Long zoneId, Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", user.trueUserId());

    sqlCache.updateBySql(PostalCodeQuery.deletePostalCodeFromZone, params);
  }

  public Optional<PostalCodeZonePostalCode> getOnePostalCodeToZone(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(PostalCodeQuery.getOnePostalCodeToZone, params, PostalCodeZonePostalCode.class);
  }

  public static class PostalCodeZoneMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public PostalCodeZoneMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<PostalCodeZonePostalCode>> postalCodeRef = new TypeReference<>() {};
      bw.registerCustomEditor(
              List.class,
              "postalCodes",
              new JsonCollectionDeserializer(postalCodeRef, objectMapper));

    }
  }
}
