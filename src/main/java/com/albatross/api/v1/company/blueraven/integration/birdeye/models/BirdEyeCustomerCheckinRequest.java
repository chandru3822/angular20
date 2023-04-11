package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;
import lombok.Singular;
import lombok.ToString;
import lombok.extern.jackson.Jacksonized;

import java.util.List;
import java.util.Map;

@Jacksonized
@Builder
@ToString
@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public
class BirdEyeCustomerCheckinRequest {
  private String name, emailId, phone;

  @Singular
  private List<BirdEyeEmployee> employees;

  /**
   * Whether customer has opted to receive SMS request or not. Valid values are 0(false), 1(true). Default is 1.
   */
  @Builder.Default
  private int smsEnabled = 1;

  /**
   * Configure extra checkin params/Templates for communication with the customer, with tag group name as key and tag name as value in the additionalParams map
   */
  @Singular
  private Map<String, String> additionalParams;
}
