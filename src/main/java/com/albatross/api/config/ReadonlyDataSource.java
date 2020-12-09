package com.albatross.api.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.sql.Connection;
import java.sql.SQLException;

@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Configuration
public class ReadonlyDataSource {

  private final PropertiesConfiguration propConfig;

  private HikariDataSource ds;

  @PostConstruct
  public void init() {
    HikariConfig config = new HikariConfig();
    config.setJdbcUrl(propConfig.databaseReadonlyURL);
    config.setUsername(propConfig.databaseUsername);
    config.setPassword(propConfig.databasePassword);
    ds = new HikariDataSource(config);
  }

  @PreDestroy
  public void destroy() {
    ds.close();
  }

  public Connection getConnection() throws SQLException {
    return ds.getConnection();
  }

  public HikariDataSource getDs() {
    return ds;
  }
}
