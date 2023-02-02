package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import feign.*;
import feign.jackson.JacksonDecoder;
import feign.jackson.JacksonEncoder;
import feign.okhttp.OkHttpClient;
import feign.optionals.OptionalDecoder;
import lombok.*;
import lombok.extern.jackson.Jacksonized;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
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
      .errorDecoder(new BirdeyeErrorDecoder(objectMapper))
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

  enum BirdEyeReviewStatus {
    published,
    parked,
    all
  }

  @Jacksonized
  @Builder
  @ToString
  @Getter
  @JsonInclude(JsonInclude.Include.NON_NULL)
  class BirdEyeCustomerGetRequest {
    private Long id;
    private String email, phone;
  }

  @Jacksonized
  @Builder
  @ToString
  @Getter
  @JsonInclude(JsonInclude.Include.NON_NULL)
  class BirdEyeCustomerListRequest {
    @JsonFormat
      (shape = JsonFormat.Shape.STRING, pattern = "MM/dd/yyyy")
    private LocalDate startDate, endDate;
  }


  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeCustomField {
    private String fieldName, type, fieldValue;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeContactMapping {
    private String cid, location, bid, businessNumber;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeCustomer {
    private String id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private boolean smsOptin;
    private List<BirdEyeCustomField> customFields;
    private List<BirdEyeContactMapping> mappings;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeCustomerResponseWrapper {
    private List<BirdEyeCustomer> customers;
    private Integer page, size, totalPages, totalCount;
  }


  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeSurvey {
    private Long surveyId;
    private String logoUrl;
    private String name;
    private String status;
    private Long responses;
    private Integer questionCount;
    private List<BirdEyeSurveyPage> pages;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeSurveyPage {
    private Long id;
    private String name;
    private String pageTitle;
    private String thankyouMsg;
    private Integer order;
    private Integer showQuestionNumbers;
    private Boolean visible, hidden;
    private List<BirdEyeSurveyPageQuestion> questions;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeSurveyPageQuestion {
    private Long id;
    private String title, name, type;
    private Integer showQuestionNumbers;
    private Boolean skipQuestion, displayQuestion, visible, isRequired;
    private Integer minimumValue, maximumValue, order;
    private List<BirdEyeSurveyPageQuestionChoice> choices;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeSurveyPageQuestionChoice {
    private Long id;
    private String title;
    private Integer order;
  }

  @Builder
  class BirdEyeCustomerRequest {

    /**
     * Id of enterprise customer
     */
    private Long id;

    private String firstName, lastName, email, phone;
    private Boolean smsOptin, emailOptin, blocked;

    @Singular
    private List<Long> businessIds;

    @Singular
    private List<String> tags;
  }

  @Builder
  class BirdEyeListPageable {
    @Builder.Default
    private Integer page = 0;
    private Integer size;
    private String sortby, sorder;
  }

  @Builder
  @JsonInclude(JsonInclude.Include.NON_NULL)
  class BirdeyeListSurveyRequest {
    @JsonFormat
      (shape = JsonFormat.Shape.STRING, pattern = "MM/dd/yyyy HH:mm:ss", timezone = "PST")
    private OffsetDateTime startDate, endDate;
    private String sorder;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeSurveyResponseWrapper {
    private List<BirdEyeSurveyResponse> responseList;
    private Integer totalResponses, pageNo, pageSize;
    private Boolean hasNext;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeSurveyResponse {
    private Long responseId;
    @JsonFormat
      (shape = JsonFormat.Shape.STRING, pattern = "MM/dd/yyyy")
    private LocalDate requestDate, responseDate;
    private Boolean completed;
    private Integer questionCount;
    private String locale;
    private Long surveyId;
    private String surveyType;
    private String surveyName;
    private String locationName;
    private String customerId;
    private String customerName;
    private String customerPhone;
    private Boolean ticketed;
    private List<BirdEyeSurveyResponseAnswer> answers;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeSurveyResponseAnswer {
    private String questionTitle, questionType, answer;
    private Boolean visible, conditional, shownToCustomer, hidden, showTime, showDate;
    private Integer maxValue, minValue;

    public String getAnswer() {
      if (answer == null) {
        return null;
      }

      //Answer in the response is surrounded by an extra double quote character
      return answer.replaceAll("\"", "");
    }
  }


  @Jacksonized
  @Builder
  @ToString
  @Getter
  @JsonInclude(JsonInclude.Include.NON_NULL)
  class BirdEyeReviewRequest {

    @JsonFormat
      (shape = JsonFormat.Shape.STRING, pattern = "MM/dd/yyyy")
    private LocalDate fromDate, toDate;

    @JsonFormat
      (shape = JsonFormat.Shape.STRING, pattern = "MM/dd/yyyy")
    private LocalDate updateFromDate, updateToDate;

    private String searchStr;

    @Singular
    private List<Integer> ratings;

    @Singular
    private List<BirdEyeReviewStatus> statuses;

  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeCustomerCheckin {
    private String customerId, checkinUrl;
  }

  @Jacksonized
  @Builder
  @ToString
  @Getter
  @JsonInclude(JsonInclude.Include.NON_NULL)
  class BirdEyeCustomerCheckinRequest {
    private String name, emailId, phone;

    @Singular
    private List<BirdEyeEmployee> employees;

    /**
     * Whether customer has opted to receive SMS request or not. Valid values are 0(false), 1(true). Default is 1.
     */
    @Builder.Default
    private int smsEnabled = 1;

    /**
     * Configure extra checkin params/Templates for communication with the customer, with tag group name as key and tag name as value in the additionalParams map
     */
    @Singular
    private Map<String, String> additionalParams;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeEmployee {
    private final String emailId;
  }

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeLocation {
    private String id, name, alias, status;
  }

  @Data
  @NoArgsConstructor
  @JsonIgnoreProperties(ignoreUnknown = true)
  class BirdEyeReview {

    private String businessId;
    private String businessName;
    private String reviewId;
    private Integer rating;
    private String title;
    private String comments;
    private String status;

    @JsonFormat
      (shape = JsonFormat.Shape.STRING, pattern = "MMM dd, yyyy")
    private LocalDate reviewDate;

    private String uniqueReviewUrl;

    private BirdeyeReviewer reviewer;

    private String sourceType;

    @JsonFormat
      (shape = JsonFormat.Shape.STRING, pattern = "MMM dd, yyyy hh:mm a")
    private LocalDate responseDate;

    private String response;

    private Integer featured;

    private Boolean enableReply;

    private String customerId;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class BirdeyeReviewer {
      private String firstName, lastName, nickName, emailId, phone, city, state;
      private String thumbnailUrl;
    }
  }
}
