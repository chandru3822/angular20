package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
class BirdEyeSurveyPageQuestion {
  private Long id;
  private String title, name, type;
  private Integer showQuestionNumbers;
  private Boolean skipQuestion, displayQuestion, visible, isRequired, hidden;
  private Integer minimumValue, maximumValue, order;
  private List<BirdEyeSurveyPageQuestionChoice> choices;
}
