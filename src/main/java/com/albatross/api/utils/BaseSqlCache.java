package com.albatross.api.utils;

import com.albatross.api.utils.convert.mapper.ConversionServiceBeanPropertyRowMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.convert.ConversionService;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSourceUtils;
import org.springframework.jdbc.support.GeneratedKeyHolder;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
public class BaseSqlCache {

  private NamedParameterJdbcTemplate jdbc;

  @Autowired
  private ObjectMapper objectMapper;

  @Autowired
  private ConversionService conversionService;

  @Autowired
  private SqlXmlParser sqlXmlParser;

  public void setJdbc(NamedParameterJdbcTemplate in) {
    jdbc = in;
  }

  public String getByKey(String key) {
    return sqlXmlParser.getSqlByKey(key);
  }

  public int update(String key, Map<String, Object> params, String... queryArgs) {
    MapSqlParameterSource paramSource = scrubParams(params);
    return update(key, paramSource, queryArgs);
  }

  public int update(String key, SqlParameterSource params, String... queryArgs) {
    String sql = getByKey(key);
    if (queryArgs.length > 0) {
      sql = String.format(sql, queryArgs);
    }

    return jdbc.update(sql, params);
  }

  public int updateBySql(String sql, Map<String, Object> params) {
    MapSqlParameterSource paramSource = scrubParams(params);
    return jdbc.update(sql, paramSource);
  }

  public Number updateReturningId(String key, Map<String, Object> params, String keyColumn) {
    MapSqlParameterSource paramSource = new MapSqlParameterSource(params);
    String sql = getByKey(key);

    GeneratedKeyHolder generatedKeyHolder = new GeneratedKeyHolder();
    jdbc.update(sql, paramSource, generatedKeyHolder, new String[]{keyColumn});

    return generatedKeyHolder.getKey();
  }

  public Number updateBySqlReturningId(String sql, Map<String, Object> params, String keyColumn) {
    MapSqlParameterSource paramSource = new MapSqlParameterSource(params);

    GeneratedKeyHolder generatedKeyHolder = new GeneratedKeyHolder();
    jdbc.update(sql, paramSource, generatedKeyHolder, new String[]{keyColumn});

    return generatedKeyHolder.getKey();
  }

  public <T> T queryForObject(String key, Map<String, Object> params, Class<T> elementType) {
    MapSqlParameterSource paramSource = scrubParams(params);
    String sql = getByKey(key);

    return (T) jdbc.queryForObject(sql, paramSource, elementType);
  }

  public <T> List<T> queryForList(String key, Map<String, Object> params, Class<T> elementType) {
    MapSqlParameterSource paramSource = scrubParams(params);
    String sql = getByKey(key);
    return jdbc.queryForList(sql, paramSource, elementType);
  }

  public <T> T queryForMap(String key, Map<String, Object> params) {
    MapSqlParameterSource paramSource = scrubParams(params);
    String sql = getByKey(key);

    return (T) jdbc.queryForMap(sql, paramSource);
  }

  public <T> T queryForMapBySql(String sql, Map<String, Object> params) {
    MapSqlParameterSource paramSource = scrubParams(params);
    return (T) jdbc.queryForMap(sql, paramSource);
  }

  public <T> Optional<T> queryForObjectOptional(
    String key, Map<String, Object> params, Class<T> elementType) {
    try {
      MapSqlParameterSource paramSource = scrubParams(params);
      String sql = getByKey(key);

      return Optional.ofNullable((T) jdbc.queryForObject(sql, paramSource, elementType));
    } catch (DataAccessException e) {
      return Optional.empty();
    }
  }

  public void query(String key, Map<String, Object> params, RowCallbackHandler rse) {
    MapSqlParameterSource paramSource = scrubParams(params);
    String sql = getByKey(key);
    jdbc.query(sql, paramSource, rse);
  }

  public <T> List<T> query(String key, Map<String, Object> params, Class<T> elementType) {
    return queryBySql(getByKey(key), params, elementType);
  }

  public <T> List<T> query(
    String key, Map<String, Object> params, Class<T> elementType, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return queryBySql(sql, params, elementType);
  }

  public <T> List<T> query(String key, Map<String, Object> params, RowMapper<T> rowMapper) {
    String sql = getByKey(key);
    return queryBySql(sql, params, rowMapper);
  }

  public <T> List<T> query(
    String key, Map<String, Object> params, RowMapper<T> rowMapper, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return queryBySql(sql, params, rowMapper);
  }

  public <T> List<T> queryBySql(String sql, Map<String, Object> params, Class<T> elementType) {
    MapSqlParameterSource paramSource = scrubParams(params);

    //noinspection unchecked
    return jdbc.query(
      sql,
      paramSource,
      new ConversionServiceBeanPropertyRowMapper(elementType, conversionService));
  }

  public <T> List<T> queryBySql(String sql, Map<String, Object> params, RowMapper<T> rowMapper) {
    MapSqlParameterSource paramSource = scrubParams(params);
    return jdbc.query(sql, paramSource, rowMapper);
  }

  public <T> T queryForObjectBySql(String sql, Map<String, Object> params, Class<T> elementType) {
    MapSqlParameterSource paramSource = scrubParams(params);
    return jdbc.queryForObject(sql, paramSource, elementType);
  }

  public <T> Optional<T> queryForObjectOptionalBySql(
    String sql, Map<String, Object> params, Class<T> elementType) {
    try {
      MapSqlParameterSource paramSource = scrubParams(params);

      return Optional.ofNullable((T) jdbc.queryForObject(sql, paramSource, elementType));
    } catch (DataAccessException e) {
      return Optional.empty();
    }
  }

  public <T> Optional<T> get(String key, Map<String, Object> params, Class<T> elementType, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return getBySql(sql, params, elementType);
  }

  public <T> Optional<T> get(String key, Map<String, Object> params, RowMapper<T> rowMapper) {
    String sql = getByKey(key);
    return getBySql(sql, params, rowMapper);
  }

  public <T> Optional<T> get(
    String key, Map<String, Object> params, RowMapper<T> rowMapper, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return getBySql(sql, params, rowMapper);
  }

  public <T> Optional<T> getBySql(String sql, Map<String, Object> params, Class<T> elementType) {
    List<T> results = queryBySql(sql, params, elementType);
    if (results.size() > 1) {
      log.warn(
        "SQL: More than a single result returned for a GET of type {} on key={}",
        elementType,
        sql);
    }

    return results.isEmpty() ? Optional.empty() : Optional.ofNullable(results.get(0));
  }

  public <T> Optional<T> getBySql(String sql, Map<String, Object> params, RowMapper<T> rowMapper) {
    List<T> results = queryBySql(sql, params, rowMapper);
    if (results.size() > 1) {
      log.warn(
        "SQL: More than a single result returned for a GET of type {} on rowMapper={}",
        rowMapper,
        sql);
    }

    return results.isEmpty() ? Optional.empty() : Optional.ofNullable(results.get(0));
  }

  public void updateBatch(final String key, final List<?> objects) {
    String sql = getByKey(key);
    SqlParameterSource[] batch = SqlParameterSourceUtils.createBatch(objects.toArray());
    jdbc.batchUpdate(sql, batch);
  }

  public void updateBatchBySql(final String sql, final List<?> objects) {
    SqlParameterSource[] batch = SqlParameterSourceUtils.createBatch(objects.toArray());
    jdbc.batchUpdate(sql, batch);
  }

  private MapSqlParameterSource scrubParams(Map<String, Object> params) {
    MapSqlParameterSource source = new MapSqlParameterSource();

    if (params != null) {
      params.entrySet().stream()
        .map(this::reduceMaps)
        .forEach(e -> source.addValue(e.getKey(), e.getValue()));
    }

    return source;
  }

  @SneakyThrows
  private Map.Entry<String, Object> reduceMaps(Map.Entry<String, Object> e) {
    String key = e.getKey();
    Object value = e.getValue();

    if (value instanceof Map) {
      String json = objectMapper.writeValueAsString(value);

      PGobject pg = new PGobject();
      pg.setType("json");
      pg.setValue(json);
      value = pg;
    }

    //noinspection unchecked
    return new HashMap.SimpleEntry(key, value);
  }
}
