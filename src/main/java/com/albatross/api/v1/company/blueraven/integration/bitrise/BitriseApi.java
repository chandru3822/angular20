package com.albatross.api.v1.company.blueraven.integration.bitrise;

import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeErrorDecoder;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import feign.*;
import feign.jackson.JacksonDecoder;
import feign.jackson.JacksonEncoder;
import feign.okhttp.OkHttpClient;
import feign.optionals.OptionalDecoder;
import org.json.JSONObject;

@Headers({
  "Content-Type: application/json",
  "Accept: application/json"
})
public interface BitriseApi {

  static BitriseApi connect(String apiKey, String appSlug) {
    final ObjectMapper objectMapper = JsonMapper.builder()
      .addModule(new JavaTimeModule())
      .build();

    String url = "https://api.bitrise.io/v0.1/apps/" + appSlug;

    return Feign.builder()
      .client(new OkHttpClient())
      .logLevel(Logger.Level.FULL)
//      .logger(new Logger() {
//        @Override
//        protected void log(String configKey, String format, Object... args) {
//          System.out.println(format.formatted(args));
//        }
//      })
      .encoder(new JacksonEncoder(objectMapper))
      .decoder(new OptionalDecoder(new JacksonDecoder(objectMapper)))
      .errorDecoder(new BitriseErrorDecoder(objectMapper))
      .requestInterceptor(requestTemplate -> requestTemplate.header("Authorization", apiKey))
      .target(BitriseApi.class, url);
  }
  //todo: if we ever need to hit an endpoint that doesn't start with /apps then we'll have to parameterize the slug a different way
  @RequestLine("POST /builds")
  void triggerAppBuild(BitriseApiBuildRequest request);
}
