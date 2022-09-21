package com.albatross.api.utils;

import com.albatross.api.config.ReadonlyDataSource;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.xml.stream.XMLStreamException;
import java.io.IOException;

@Component
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SqlCacheRO extends BaseSqlCache {

  private final ReadonlyDataSource roDataSource;

  @PostConstruct
  public void init() throws IOException, XMLStreamException {
    setJdbc(new NamedParameterJdbcTemplate(roDataSource.getDs()));
  }
}
