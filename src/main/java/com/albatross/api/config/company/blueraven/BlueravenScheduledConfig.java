package com.albatross.api.config.company.blueraven;

import com.albatross.api.v1.company.blueraven.services.GenesysService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;

import javax.annotation.PostConstruct;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;


@Slf4j
@Configuration
@RequiredArgsConstructor
// only enable scheduled tasks if `app.scheduled.enabled` property or `CRON_ENABLED` env var are true
@ConditionalOnProperty(prefix = "app.scheduled.blueraven", value = "enabled")
public class BlueravenScheduledConfig implements SchedulingConfigurer {

  @Value(value = "${app.cron.blueraven.processGenesysContacts.enabled:false}")
  private Boolean updateGenesysContacts;

  private final GenesysService genesysService;

  /*
  //
  // FYI: DON'T SCHEDULE ANYTHING FOR 2AM MOUNTAIN, THAT IS WHEN AUTO TRIGGERS
  // FYI: RUN AND THEY DO SOME HEAVY LIFTING ON THE DB
  //
  */

  /*
  //
  // WARNING: ENSURE THAT ANY FUNCTIONS RUNNING ARE SPECIFIC TO BLUERAVEN DATA
  //
  */

  @PostConstruct
  public void init() {
    log.info("*** BRS_CRON: cron service enabled ***");
  }

  //    every  day at 1 am
  @Scheduled(cron = "0 0 1 * * *", zone = "America/Denver")
  public void updateGenesysContacts() {
    if (updateGenesysContacts) {
      log.info("*** CRON: start processing Genesys contacts ***");
      genesysService.processGenesysContacts();
      log.info("*** CRON: end processing Genesys contacts ***");
    }
  }

  @Bean(destroyMethod = "shutdown")
  public Executor taskExecutor() {
    return Executors.newScheduledThreadPool(10);
  }

}
