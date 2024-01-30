package com.albatross.api.config.company.blueraven;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeSyncService;
import com.albatross.api.v1.company.blueraven.services.*;
import com.albatross.api.v1.company.blueraven.services.expenses.ExpenseBudgetService;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.Scheduled;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.concurrent.TimeUnit;


@Slf4j
@Configuration
@RequiredArgsConstructor
// only enable scheduled tasks if `app.scheduled.enabled` property or `CRON_ENABLED` env var are true
@ConditionalOnProperty(prefix = "app.scheduled.blueraven", value = "enabled")
public class BlueravenScheduledConfig {
  @Value(value = "${app.cron.blueraven.processFive9Contacts.enabled:false}")
  private Boolean updateFive9Contacts;

  @Value(value = "${app.cron.blueraven.processGenesysContacts.enabled:false}")
  private Boolean updateGenesysContacts;

  @Value(value = "${app.cron.blueraven.marketo.enabled:false}")
  private Boolean marketoEnabled;

  @Value(value = "${app.cron.blueraven.processMetroPostalCodes.enabled:false}")
  private Boolean processMetroPostalCodes;

  private final Five9Service five9Service;

  private final GenesysService genesysService;

  private final MarketoService marketoService;

  private final BirdEyeSyncService birdeyeSyncService;

  private final BlueravenProjectService blueravenProjectService;

  private final SecurityService securityService;

  private final CompanyDashboardService companyDashboardService;

  private final ExpenseBudgetService expenseBudgetService;
  /*
  //
  // FYI: DON'T SCHEDULE ANYTHING FOR 2AM MOUNTAIN (8 am utc), THAT IS WHEN AUTO TRIGGERS
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

  //    every  day at 1 am - mtn
  @Scheduled(cron = "0 0 7 * * *", zone = "UTC")
  public void updateGenesysContacts() {
    if (updateGenesysContacts) {
      log.info("*** CRON: start processing Genesys contacts ***");
      genesysService.processGenesysContacts();
      log.info("*** CRON: end processing Genesys contacts ***");
    }
  }

  //    27th of every month at 7 am utc
  @Scheduled(cron = "0 0 7 27 * *", zone = "UTC")
  public void generateNextMonthBudgetsFromTemplate() {
    log.info("*** CRON: start generating monthly budgets ***");
    expenseBudgetService.generateNextMonthBudgets();
    log.info("*** CRON: end generating monthly budgets ***");
  }

  //    every  day at 1 am - mtn
  @Scheduled(cron = "0 0 7 * * *", zone = "UTC")
  public void updateFive9Contacts() {
    if (updateFive9Contacts) {
      log.info("*** CRON: start processing Five 9 contacts ***");
      five9Service.processFive9Contacts();
      log.info("*** CRON: end processing Five 9 contacts ***");
    }
  }

  //    every  day at 11 pm - mtn
  @Scheduled(cron = "0 0 5 * * *", zone = "UTC")
  public void updateProjectMetroAreaPostalCodes() {
    if (processMetroPostalCodes) {
      log.info("*** CRON: start processing Metro Area Postal Codes ***");
      blueravenProjectService.processMetroAreaPostalCodes();
      log.info("*** CRON: end processing Metro Area Postal Codes ***");
    }
  }

  // daily at 4:00am mountain time
  @Scheduled(cron = "0 0 10 * * *", zone = "UTC")
  public void pushProjectsToMarketo() {
    if (marketoEnabled) {
      log.info("*** CRON: start pushing projects to Marketo ***");
      marketoService.pushDailyUpdatedProjects();
      log.info("*** CRON: end pushing projects to Marketo ***");
    }
  }

  @Scheduled(fixedDelay = 1, timeUnit = TimeUnit.HOURS)
  public void syncBirdeyeResponses() {
    log.debug("*** CRON: start sync surveys from BirdEye ***");
    setBlueravenSystemUser();

    birdeyeSyncService.syncSurveyResponses();
    log.debug("*** CRON: end sync surveys from BirdEye ***");
  }

  @Scheduled(cron = "0 0 12 * * *", zone = "UTC") //12pm UTC / 6am-ish Mountain
  public void syncBirdeyeReviews() {
    log.debug("*** CRON: start sync reviews from BirdEye ***");
    Instant startTime = Instant.now();
    setBlueravenSystemUser();

    birdeyeSyncService.syncReviews();
    Duration duration = Duration.between(startTime, Instant.now());
    log.debug("*** CRON: end sync surveys from BirdEye in {} ***", duration);
  }

  @Scheduled(cron = "0 0 3 * * *", zone = "America/Denver")
  public void dailyCompanyDashboardSetup() {
    companyDashboardService.callCompanyDashboardSetup(null);
  }

  @Scheduled(fixedDelay = 5, timeUnit = TimeUnit.MINUTES)
  public void companyDashboardSetup() {
    companyDashboardService.callCompanyDashboardSetup(LocalDate.now());
  }

  private void setBlueravenSystemUser() {
    log.debug("Setting BR System User");
    final SystemSettings brSystemUser = SystemSettings.BR_SYSTEM_USER;

    final User user = new User();
    user.setId(brSystemUser.getId());
    user.setCompanyId(brSystemUser.getCompanyId());
    user.setAwsBucket(brSystemUser.getAwsBucket());
    user.setHighestCompanyId(brSystemUser.getCompanyId());
    user.setHighestParentCompanyId(brSystemUser.getCompanyId());
    user.setHasAccess(true);

    final UserAccountDetails uad = new UserAccountDetails(user, List.of());

    securityService.setCurrentUserDetails(uad);
  }

}
