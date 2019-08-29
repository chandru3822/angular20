package com.albatross.api.utils;

import com.albatross.api.utils.convert.mapper.ConversionServiceBeanPropertyRowMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import com.google.common.collect.Maps;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.convert.ConversionService;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSourceUtils;
import org.springframework.jdbc.support.GeneratedKeyHolder;

import javax.annotation.PostConstruct;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Created by dave on 12/16/15.
 */
@Slf4j
public class BaseSqlCache {

  private final Map<String, String> map = Maps.newHashMap();

  private NamedParameterJdbcTemplate jdbc;

  @Autowired
  private ObjectMapper objectMapper;

  @Autowired
  private ConversionService conversionService;

  @PostConstruct
  public void init() throws IOException, XMLStreamException {
    ResourcePatternResolver patternResolver = new PathMatchingResourcePatternResolver();
    Resource[] resources = patternResolver.getResources("classpath*:**/*.sql.xml");
    for (Resource resource : resources) {
      InputStream stream = resource.getInputStream();
      XMLStreamReader sr = XMLInputFactory.newInstance().createXMLStreamReader(stream);
      XmlMapper mapper = new XmlMapper();
      //noinspection unchecked
      Map<String, String> converted = mapper.readValue(sr, Map.class);
      map.putAll(converted);
    }
  }

  public void setJdbc(NamedParameterJdbcTemplate in) {
    jdbc = in;
  }

  public String getByKey(String key) {
    return map.get(key);
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

  public void query(String key, Map<String, Object> params, RowCallbackHandler rse) {
    MapSqlParameterSource paramSource = scrubParams(params);
    String sql = getByKey(key);
    jdbc.query(sql, paramSource, rse);
  }

  public <T> List<T> query(String key, Map<String, Object> params, Class<T> elementType) {
    return queryBySql(getByKey(key), params, elementType);
  }

  public <T> List<T> query(String key, Map<String, Object> params, Class<T> elementType, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return queryBySql(sql, params, elementType);
  }

  public <T> List<T> query(String key, Map<String, Object> params, RowMapper<T> rowMapper) {
    String sql = getByKey(key);
    return queryBySql(sql, params, rowMapper);
  }

  public <T> List<T> query(String key, Map<String, Object> params, RowMapper<T> rowMapper, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return queryBySql(sql, params, rowMapper);
  }

  public <T> List<T> queryBySql(String sql, Map<String, Object> params, Class<T> elementType) {
    MapSqlParameterSource paramSource = scrubParams(params);

    //noinspection unchecked
    return jdbc.query(sql, paramSource, new ConversionServiceBeanPropertyRowMapper(elementType, conversionService));
  }

  public <T> List<T> queryBySql(String sql, Map<String, Object> params, RowMapper<T> rowMapper) {
    MapSqlParameterSource paramSource = scrubParams(params);
    return jdbc.query(sql, paramSource, rowMapper);
  }

  public <T> Optional<T> get(String key, Map<String, Object> params, Class<T> elementType, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return getBySql(sql, params, elementType);
  }

  public <T> Optional<T> get(String key, Map<String, Object> params, RowMapper<T> rowMapper) {
    String sql = getByKey(key);
    return getBySql(sql, params, rowMapper);
  }

  public <T> Optional<T> get(String key, Map<String, Object> params, RowMapper<T> rowMapper, String... queryArgs) {
    String sql = String.format(getByKey(key), queryArgs);
    return getBySql(sql, params, rowMapper);
  }

  public <T> Optional<T> getBySql(String sql, Map<String, Object> params, Class<T> elementType) {
    List<T> results = queryBySql(sql, params, elementType);
    if (results.size() > 1) {
      log.warn("More than a single result returned for a GET of type {} on key={}", elementType, sql);
    }

    return results.isEmpty() ? Optional.empty() : Optional.ofNullable(results.get(0));
  }

  public <T> Optional<T> getBySql(String sql, Map<String, Object> params, RowMapper<T> rowMapper) {
    List<T> results = queryBySql(sql, params, rowMapper);
    if (results.size() > 1) {
      log.warn("More than a single result returned for a GET of type {} on rowMapper={}", rowMapper, sql);
    }

    return results.isEmpty() ? Optional.empty() : Optional.ofNullable(results.get(0));
  }

  public void updateBatch(final String key, final List<?> objects) {
    String sql = getByKey(key);
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


  public static class Dummy extends SimpleModule {


  }

}
