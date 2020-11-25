package com.albatross.api.config;

import com.albatross.api.v1.flow.services.AvailabilityService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import com.albatross.api.v1.flow.services.SMSService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;

import javax.annotation.PostConstruct;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;


@Slf4j
@Configuration
@EnableAsync
@EnableScheduling
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
// only enable scheduled tasks if `app.scheduled.enabled` property or `CRON_ENABLED` env var are true
@ConditionalOnProperty(prefix = "app.scheduled", value = "enabled")
public class ScheduledConfig implements SchedulingConfigurer {

    @Value(value = "${app.cron.sendSms.enabled:false}")
    private Boolean sendSmsNotifications;

    @Value(value = "${app.cron.processFutureAppointments.enabled:false}")
    private Boolean processFutureAppointments;

    @Value(value = "${app.cron.autoTriggers.enabled:false}")
    private boolean autoTriggers;

    @Value(value = "${app.cron.initialAutoTriggers.enabled:false}")
    private boolean initialAutoTriggers;

    @Value(value = "${app.cron.cacheAvailability.enabled:false}")
    private boolean runCachedAvailability;

    @Value(value = "${app.cron.refreshUserPositionOrgs.enabled:false}")
    private boolean refreshUserPositionOrgs;

    private final SMSService smsService;
    private final AvailabilityService availabilityService;
    private final ProjectProcessStepService projectProcessStepService;

    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        taskRegistrar.setScheduler(taskExecutor());
    }

    @PostConstruct
    public void init() {
      if (initialAutoTriggers) {
        log.info("*** CRON: start INITIAL auto triggers ***");
        projectProcessStepService.performInitialAutoTriggers();
        log.info("*** CRON: end INITIAL auto triggers ***");
      }
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
    @Scheduled(cron = "0 0 0 28-31 * ?")
    public void populateNextMonthsBudgets() {
        if(processFutureAppointments) {
            availabilityService.processFutureRecurringEvents();
        }
    }

    @Scheduled(cron = "0 0 2 * * *")
    public void autoTriggers() {
      if (autoTriggers) {
        log.info("*** CRON: start auto triggers ***");
        projectProcessStepService.performTimeBasedAutoTriggers();
        log.info("*** CRON: end auto triggers ***");
      }
    }

    @Bean(destroyMethod = "shutdown")
    public Executor taskExecutor() {
        return Executors.newScheduledThreadPool(10);
    }

}
