package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;
import lombok.ToString;
import lombok.extern.jackson.Jacksonized;

@Jacksonized
@Builder
@ToString
@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public
class BirdEyeCustomerGetRequest {
  private Long id;
  private String email, phone;
}
