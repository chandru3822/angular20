package com.albatross.api.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
public class PropertiesConfiguration {

    @Value("${application.name}")
    String applicationName;

    @Value("${application.description}")
    String applicationDescription;

    @Value("${spring.datasource.url}")
    String databaseURL;

    @Value("${spring.datasource.readonly.url}")
    String databaseReadonlyURL;

    @Value("${spring.datasource.username}")
    String databaseUsername;

    @Value("${spring.datasource.password}")
    String databasePassword;

    @Value("${smtp.server}")
    String smtpServer;

    @Value("${smtp.port}")
    String smtpPort;

    @Value("${smtp.user}")
    String smtpUser;

    @Value("${smtp.password}")
    String smtpPassword;

    @Value("${twilio.phoneNumber:}")
    String twilioPhoneNumber;

    @Value("${twilio.accountSID}")
    String twilioAccountSID;

    @Value("${twilio.authToken}")
    String twilioAuthToken;

    @Value("${twilio.messageServiceSID:}")
    String twilioMessageServiceSID;

    @Value("${twilio.customersMessageServiceSID:}")
    String twilioCustomersMessageServiceSID;

}
