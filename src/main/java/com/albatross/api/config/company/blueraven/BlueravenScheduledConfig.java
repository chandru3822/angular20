package com.albatross.api.config.company.blueraven;

import com.albatross.api.v1.company.blueraven.services.GenesysService;
import com.albatross.api.v1.company.blueraven.services.MarketoService;
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

  @Value(value = "${app.cron.blueraven.pushProjectsToMarketo.enabled:false}")
  private Boolean pushProjectsToMarketo;

  private final GenesysService genesysService;

  private final MarketoService marketoService;

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

  @Override
  public void configureTasks(ScheduledTaskRegistrar blueravenTaskRegistrar) {
    blueravenTaskRegistrar.setScheduler(blueravenTaskExecutor());
  }

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

  // daily at 1:15 mountain time
   @Scheduled(cron = "0 0 * * * *", zone = "America/Denver")
  public void pushProjectsToMarketo() {
      if (pushProjectsToMarketo) {
          log.info("*** CRON: start pushing projects to Marketo ***");
          marketoService.pushDailyUpdatedProjects();
          log.info("*** CRON: end pushing projects to Marketo ***");
      }
  }

  @Bean(destroyMethod = "shutdown")
  public Executor blueravenTaskExecutor() {
    return Executors.newScheduledThreadPool(10);
  }

}
