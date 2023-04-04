package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;
import lombok.Singular;
import lombok.ToString;
import lombok.extern.jackson.Jacksonized;

import java.time.LocalDate;
import java.util.List;

@Jacksonized
@Builder
@ToString
@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public
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

  private Boolean fetchExtraParams;
  private Boolean needCustomerInfo;

}
