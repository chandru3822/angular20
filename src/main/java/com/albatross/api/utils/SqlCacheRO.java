package com.albatross.api.utils;

import com.albatross.api.config.ReadonlyDataSource;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

import javax.xml.stream.XMLStreamException;
import java.io.IOException;

@Component
@RequiredArgsConstructor
public class SqlCacheRO extends BaseSqlCache {

  private final ReadonlyDataSource roDataSource;

  @PostConstruct
  public void init() throws IOException, XMLStreamException {
    setJdbc(new NamedParameterJdbcTemplate(roDataSource.getDs()));
  }
}
