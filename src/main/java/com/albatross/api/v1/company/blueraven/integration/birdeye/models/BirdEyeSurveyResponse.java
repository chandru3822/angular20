package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
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
