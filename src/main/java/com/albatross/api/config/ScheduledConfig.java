package com.albatross.api.config;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.services.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;

import javax.annotation.PostConstruct;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

@Slf4j
@Configuration
@EnableScheduling
@RequiredArgsConstructor
// only enable scheduled tasks if `app.scheduled.enabled` property or `CRON_ENABLED` env var are
// true
@ConditionalOnProperty(prefix = "app.scheduled", value = "enabled")
public class ScheduledConfig implements SchedulingConfigurer {

  private final SMSService smsService;
  private final MailService mailService;
  private final AvailabilityService availabilityService;
  private final ProjectProcessStepService projectProcessStepService;
  private final ContactService contactService;
  private final MessagingService messagingService;
  private final DataViewService dataViewService;
  private final SecurityService securityService;

  @Value(value = "${app.cron.sendSms.enabled:false}")
  private Boolean sendSmsNotifications;

  @Value(value = "${app.cron.sendEmail.enabled:false}")
  private Boolean sendEmailNotifications;

  @Value(value = "${app.home_url}")
  private String homeUrl;

  @Value(value = "${app.cron.processFutureAppointments.enabled:false}")
  private Boolean processFutureAppointments;

  @Value(value = "${app.cron.autoTriggers.enabled:false}")
  private boolean autoTriggers;

  @Value(value = "${app.cron.initialAutoTriggers.enabled:false}")
  private boolean initialAutoTriggers;

  @Value(value = "${app.cron.cacheAvailability.enabled:false}")
  private boolean runCachedAvailability;

  @Value(value = "${app.cron.fillProjectGeoCoords.enabled:false}")
  private boolean fillProjectGeoCoords;

  @Value(value = "${app.cron.closeProjectConversations.enabled:false}")
  private boolean closeProjectConversations;

  @Value(value = "${app.cron.runDataViewMaintenance.enabled:false}")
  private boolean doViewMaintenance;

  @Override
  public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
    final ScheduledExecutorService scheduledExecutorService = Executors.newScheduledThreadPool(10);
    taskRegistrar.setScheduler(scheduledExecutorService);
  }

  /*
  //
  // FYI: DON'T SCHEDULE ANYTHING FOR 2AM MOUNTAIN, THAT IS WHEN AUTO TRIGGERS
  // FYI: RUN AND THEY DO SOME HEAVY LIFTING ON THE DB
  //
  */

  @PostConstruct
  public void init() {
    log.info("*** CRON: cron service enabled ***");
  }

  //    every  minute
  @Scheduled(fixedDelayString = "${app.cron.sendSms.delay:20000}")
  public void sendSmsNotifications() {
    if (sendSmsNotifications) {
      smsService.processMessages();

      // Update the status for any text messages that Twilio has recently told us about.
      // This is separate from the processMessages call because a failure within that
      // method will rollback the db transaction which contains very important information
      // about outbound texts
      smsService.processTwilioWebhookPayloads();
    }
  }

  //    every  day at midnight zone = "America/Denver")
  @Scheduled(cron = "0 0 0 * * *", zone = "America/Denver")
  public void runViewMaintenance() {
    if (doViewMaintenance) {
      log.info("*** CRON: start data view maintenance ***");
      setCronUser();
      dataViewService.runViewMaintenance();
      log.info("*** CRON: end data view maintenance ***");
    }
  }

  //    every  day at 1 am
  @Scheduled(cron = "0 0 1 * * *", zone = "America/Denver")
  // zone = "America/Denver")
  public void closeProjectConversations() {
    if (closeProjectConversations) {
      setCronUser();
      log.info("*** CRON: start close SMS project conversations ***");
      messagingService.closeStaleProjects(SystemSettings.CRON_USER.getId());
      log.info("*** CRON: end close SMS project conversations ***");
    }
  }

  //    every  minute
  @Scheduled(fixedDelayString = "${app.cron.sendEmail.delay:60000}")
  public void sendUnprocessedEmails() throws InterruptedException {
    if (sendEmailNotifications) {
      mailService.sendUnprocessedEmails();
    }
  }

  //    every  day at 1 am
  @Scheduled(cron = "0 0 1 * * *", zone = "America/Denver")
  public void cacheAvailability() {
    if (runCachedAvailability) {
      log.info("*** CRON: start cache availability ***");
      availabilityService.cacheAvailability();
      log.info("*** CRON: end cache availability ***");
    }
  }

  // last day of every month
  //    @Scheduled(cron = "0 0 0 L * ?")
  @Scheduled(cron = "0 0 2 27 * *", zone = "America/Denver")
  public void processFutureRecurringEvents() {
    if (processFutureAppointments) {
      log.info("*** CRON: start populating recurring events ***");
      availabilityService.processFutureRecurringEvents();
      log.info("*** CRON: end populating recurring events ***");
    }
  }

  @Scheduled(cron = "0 0 2 * * *", zone = "America/Denver")
  public void autoTriggers() {
    if (autoTriggers) {
      log.info("*** CRON: start auto triggers ***");
      projectProcessStepService.performTimeBasedAutoTriggers();
      log.info("*** CRON: end auto triggers ***");
    }
  }

  // @TODO: This is temporary - randa. updating contact geo-location until all are finished
  @Scheduled(cron = "0 0 4 * * *", zone = "America/Denver")
  public void updateContactLatLong() throws Exception {
    log.info("*** CRON: start CONTACT geo coords updates ***");
    contactService.updateContactLatLong(50000);
    log.info("*** CRON: end CONTACT geo coords updates ***");
  }

  @Bean(destroyMethod = "shutdown", name = "scheduledTheadPool")
  public Executor taskExecutor() {
    return Executors.newScheduledThreadPool(10);
  }

  private void setCronUser() {
    log.debug("Setting CRON User");
    final SystemSettings cronUser = SystemSettings.CRON_USER;

    final User user = new User();
    user.setId(cronUser.getId());
    user.setCompanyId(cronUser.getCompanyId());
    user.setHighestCompanyId(cronUser.getCompanyId());
    user.setHighestParentCompanyId(cronUser.getCompanyId());

    final UserAccountDetails uad = new UserAccountDetails(user, List.of());

    securityService.setCurrentUserDetails(uad);
  }
}
