package com.albatross.api.config;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Slf4j
@Configuration
@Data
public class PandaDocConfiguration {
    @Value("${pandadoc.enabled:false}")
    private Boolean enabled;

    @Value("${pandadoc.access_token}")
    private String accessToken;

    @Value("${pandadoc.document.prefix:}")
    private String documentPrefix;

    @Value("${pandadoc.document.delay:30000}")
    private Integer documentCreationDelay;

    @Value("${pandadoc.notification.delay:5000}")
    private Integer notificationDelay;

    @Value("${pandadoc.notification.email:}")
    private String notificationEmail;

    @Value("${pandadoc.notification.enabled:false}")
    private Boolean notificationEnabled;

    @Value("${pandadoc.role.customer:Customer}")
    private String customerRole;

    @Value("${pandadoc.role.closer:Sales Representative}")
    private String closerRole;

    @Value("${pandadoc.role.closer:Blue Raven Solar}")
    private String supportRole;

    @Value("${pandadoc.genericName:Generic}")
    private String genericName;
}
