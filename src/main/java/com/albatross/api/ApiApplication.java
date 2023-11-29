package com.albatross.api;

import com.albatross.api.config.AwsProperties;
import com.albatross.api.config.AppProperties;
import com.albatross.api.config.company.blueraven.BirdEyeProperties;
import com.albatross.api.config.company.blueraven.BitriseProperties;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.joda.time.DateTimeZone;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Import;

import java.util.TimeZone;

@OpenAPIDefinition(
    info =
        @Info(
            title = "Albatross API",
            version = "1.0",
            description = "A collection of endpoints for korriej :)"))
@SpringBootApplication
@Import({AwsProperties.class, AppProperties.class, BirdEyeProperties.class, BitriseProperties.class})
public class ApiApplication {

  public static TimeZone TIMEZONE = TimeZone.getTimeZone("UTC");

  public static void main(String[] args) {
    //don't show annoying message about the graaljs polyglot engine being in interpreter mode
    System.setProperty("polyglot.engine.WarnInterpreterOnly", "false");

    TimeZone.setDefault(TIMEZONE);
    DateTimeZone.setDefault(DateTimeZone.forTimeZone(TIMEZONE));
    SpringApplication.run(ApiApplication.class, args);
  }
}
