package com.albatross.api.utils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.stereotype.Component;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentMap;
import java.util.stream.Collectors;

@Slf4j
@Component
public class SqlXmlParser {

  private final ConcurrentMap<String, String> sqlMap;

  public SqlXmlParser() throws IOException {
    ResourcePatternResolver patternResolver = new PathMatchingResourcePatternResolver();
    Resource[] resources = patternResolver.getResources("classpath*:**/*.sql.xml");

    final XMLInputFactory inputFactory = XMLInputFactory.newInstance();
    final XmlMapper mapper = new XmlMapper();

    final TypeReference<Map<String, String>> mapTypeReference = new TypeReference<>() {
    };

    sqlMap = Arrays.stream(resources)
      .parallel()
      .map(resource -> {
        try (final InputStream inputStream = resource.getInputStream()) {
          XMLStreamReader sr = inputFactory.createXMLStreamReader(inputStream);
          return mapper.readValue(sr, mapTypeReference);
        } catch (IOException | XMLStreamException e) {
          log.error("Error parsing SQL XML", e);
        }
        return null;
      })
      .filter(Objects::nonNull)
      .flatMap(m -> m.entrySet().stream())
      .filter(m -> !m.getKey().trim().equals(""))
      .collect(Collectors.toConcurrentMap(m -> (String) m.getKey(), m -> (String) m.getValue()));
  }

  public String getSqlByKey(String key) {
    return sqlMap.get(key);
  }
}
