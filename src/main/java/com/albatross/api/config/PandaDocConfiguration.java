package com.albatross.api.config;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Slf4j
@Configuration
@Data
public class PandaDocConfiguration {
    @Value("${pandadoc.api.enabled:false}")
    private Boolean enabled;

    @Value("${pandadoc.api.access_token}")
    private String accessToken;

    @Value("${pandadoc.api.document.prefix:}")
    private String documentPrefix;

    @Value("${pandadoc.api.document.delay:30000}")
    private Integer documentCreationDelay;

    @Value("${pandadoc.api.notification.delay:5000}")
    private Integer notificationDelay;

    @Value("${pandadoc.api.notification.email:}")
    private String notificationEmail;

    @Value("${pandadoc.api.notification.enabled:false}")
    private Boolean notificationEnabled;

    @Value("${pandadoc.api.role.customer:Customer}")
    private String customerRole;

    @Value("${pandadoc.api.role.closer:Sales Representative}")
    private String closerRole;

    @Value("${pandadoc.api.role.support:Blue Raven Solar}")
    private String supportRole;

    @Value("${pandadoc.api.genericName:Generic}")
    private String genericName;
}
