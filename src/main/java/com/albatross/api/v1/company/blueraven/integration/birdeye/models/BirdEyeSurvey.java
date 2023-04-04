package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
class BirdEyeSurvey {
  private Long surveyId;
  private String logoUrl;
  private String name;
  private String status;
  private Long responses;
  private Integer questionCount;
  private List<BirdEyeSurveyPage> pages;
}
