package com.blueraven.config;

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

    @Value("${baseCRM.api.v3.key}")
    String baseCRMAPIV3Key;

    @Value("${baseCRM.api.v2.key}")
    String baseCRMAPIV2Key;

    @Value("${baseCRM.api.v1.key}")
    String baseCRMAPIV1Key;

    @Value("${spring.datasource.url}")
    String databaseURL;

    @Value("${spring.datasource.username}")
    String databaseUsername;

    @Value("${spring.datasource.password}")
    String databasePassword;

    @Value("${mosaic.host.name}")
    String mosaicHostName;

    @Value("${mosaic.root.url}")
    String mosaicRootURL;

    @Value("${mosaic.client.secret}")
    String mosaicClientSecret;

    @Value("${baseCRM.dosync}")
    Boolean baseCRMDoSync;

    @Value("${baseCRM.baseCRMSyncClientUUID}")
    String baseCRMSyncClientUUID;

    @Value("${baseCRM.baseCRMCollaboratorsSyncClientUUID}")
    String baseCRMCollaboratorsSyncClientUUID;

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

    @Value("${excel.user}")
    String excelUser;

    @Value("${excel.password}")
    String excelPassword;

    @Value("${sitecapture.auth_header}")
    String siteCaptureAuthHeader;

    @Value("${sitecapture.api_key}")
    String siteCaptureApiKey;

    @Value("${sitecapture.page_size}")
    Integer siteCapturePageSize;
}
