package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import lombok.Builder;
import lombok.Singular;

import java.util.List;

@Builder
public
class BirdEyeCustomerRequest {

  /**
   * Id of enterprise customer
   */
  private Long id;

  private String firstName, lastName, email, phone;
  private Boolean smsOptin, emailOptin, blocked;

  @Singular
  private List<Long> businessIds;

  @Singular
  private List<String> tags;
}
