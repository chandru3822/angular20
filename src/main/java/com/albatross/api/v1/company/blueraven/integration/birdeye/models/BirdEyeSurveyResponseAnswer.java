package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
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
