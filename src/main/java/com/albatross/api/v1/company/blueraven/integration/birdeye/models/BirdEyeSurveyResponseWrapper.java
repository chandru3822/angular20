package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
class BirdEyeSurveyResponseWrapper {
  private List<BirdEyeSurveyResponse> responseList;
  private Integer totalResponses, pageNo, pageSize;
  private Boolean hasNext;
}
