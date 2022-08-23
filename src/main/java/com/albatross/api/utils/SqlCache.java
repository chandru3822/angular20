package com.albatross.api.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.xml.stream.XMLStreamException;
import java.io.IOException;

@Component
public class SqlCache extends BaseSqlCache {

  @Autowired
  @Qualifier("namedParameterJdbcTemplate")
  private NamedParameterJdbcTemplate sqlJdbc;

  @PostConstruct
  public void init() throws IOException, XMLStreamException {
    setJdbc(sqlJdbc);
  }
}
