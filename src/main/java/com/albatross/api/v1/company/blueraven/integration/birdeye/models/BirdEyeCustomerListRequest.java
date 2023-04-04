package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import lombok.extern.jackson.Jacksonized;

import java.time.LocalDate;

@Jacksonized
@Builder
@ToString
@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public
class BirdEyeCustomerListRequest {
  @JsonFormat
    (shape = JsonFormat.Shape.STRING, pattern = "MM/dd/yyyy")
  private LocalDate startDate, endDate;
}
