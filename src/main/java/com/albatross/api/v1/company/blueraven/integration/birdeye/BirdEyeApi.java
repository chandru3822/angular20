package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.albatross.api.v1.company.blueraven.integration.birdeye.models.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import feign.*;
import feign.jackson.JacksonDecoder;
import feign.jackson.JacksonEncoder;
import feign.okhttp.OkHttpClient;
import feign.optionals.OptionalDecoder;

import java.util.List;
import java.util.Optional;

@Headers({
  "Content-Type: application/json",
  "Accept: application/json"
})
public interface BirdEyeApi {

  static BirdEyeApi connect(String apiKey) {
    final ObjectMapper objectMapper = JsonMapper.builder()
      .addModule(new JavaTimeModule())
      .build();

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
      .errorDecoder(new BirdEyeErrorDecoder(objectMapper))
      .requestInterceptor(requestTemplate -> requestTemplate.query("api_key", apiKey))
      .target(BirdEyeApi.class, "https://api.birdeye.com");
  }

  @RequestLine("GET /resources/v1/business/child/all?pid={pid}")
  List<BirdEyeLocation> getChildBusinesses(@Param String pid);

  @RequestLine("POST /resources/v1/customer/checkin?bid={businessId}")
  Optional<BirdEyeCustomerCheckin> createCustomerCheckIn(@Param String businessId, BirdEyeCustomerCheckinRequest request);

  @RequestLine("POST /resources/v1/review/businessId/{businessId}")
  List<BirdEyeReview> getReviewsByBusinessId(@Param String businessId, BirdEyeReviewRequest request);

  @RequestLine("GET /resources/v1/survey/business/{businessId}/all")
  List<BirdEyeSurvey> getAllSurveys(@Param String businessId);

  @RequestLine("GET /resources/v1/survey/{surveyId}?businessId={businessId}")
  BirdEyeSurvey getSurvey(@Param String surveyId, @Param String businessId);

  @RequestLine("POST /resources/v1/survey/ext/list/responses/{surveyId}?businessNumber={businessId}")
  BirdEyeSurveyResponseWrapper getSurveyResponses(@Param String surveyId, @Param String businessId, BirdeyeListSurveyRequest request, @QueryMap BirdEyeListPageable pageable);

  @RequestLine("POST /resources/v1/customer-v2/external/getCustomer?businessId={businessId}")
  BirdEyeCustomer getCustomer(@Param String businessId, BirdEyeCustomerGetRequest request);

  @RequestLine("POST /resources/v2/customer/list?bid={businessId}")
  BirdEyeCustomerResponseWrapper getAllCustomers(@Param String businessId, BirdEyeCustomerListRequest request, @QueryMap BirdEyeListPageable pageable);
}
