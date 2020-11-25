package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.DbFunction;
import com.albatross.api.v1.flow.model.DbFunctionParam;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class DbFunctionService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<DbFunction> getDbFunctions() {
    List<DbFunction> results = sqlCache.query("dbFunction.getAll", Collections.emptyMap(), DbFunction.class);
    return results;
  }

  public DbFunction getDbFunction(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<DbFunction> result = sqlCache.get("dbFunction.getOne", params, DbFunction.class);
    return result.orElse(null);
  }

  public static class DbFunctionMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public DbFunctionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<DbFunctionParam>> dbFunctionParamRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "dbFunctionParams",
          new JsonCollectionDeserializer(dbFunctionParamRef, objectMapper));

    }
  }

}
