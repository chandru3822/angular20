package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Slf4j
@Service
@RequiredArgsConstructor
public class BlueravenProjectService {

  private final SqlCache sqlCache;

  public void processMetroAreaPostalCodes() {
    sqlCache.queryBySql(updateProjectMetroAreaPostalCodes, Collections.emptyMap(), String.class);
  }

  //language=PostgreSQL
  public final static String updateProjectMetroAreaPostalCodes = """
      select from brs.cron_update_project_metro_areas();
    """;

}
