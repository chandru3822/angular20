package com.albatross.api.config;

import com.albatross.api.v1.flow.services.AvailabilityService;
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

    private final SMSService smsService;
    private final AvailabilityService availabilityService;

    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        taskRegistrar.setScheduler(taskExecutor());
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

    // last day of every month
    @Scheduled(cron = "0 0 0 L * ?")
    public void populateNextMonthsBudgets() {
        availabilityService.processFutureRecurringEvents();
    }

    @Bean(destroyMethod = "shutdown")
    public Executor taskExecutor() {
        return Executors.newScheduledThreadPool(10);
    }

}
