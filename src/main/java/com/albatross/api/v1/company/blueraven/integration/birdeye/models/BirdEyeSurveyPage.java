package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
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
