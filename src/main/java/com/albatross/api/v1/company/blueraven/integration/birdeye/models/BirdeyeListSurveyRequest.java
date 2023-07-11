package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.ToString;

import java.time.OffsetDateTime;

@Builder
@ToString
@JsonInclude(JsonInclude.Include.NON_NULL)
public class BirdeyeListSurveyRequest {
  @JsonFormat
    (shape = JsonFormat.Shape.STRING, pattern = "MM/dd/yyyy HH:mm:ss", timezone = "PST")
  private OffsetDateTime startDate, endDate;
  private String sorder;
}
