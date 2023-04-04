package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
class BirdEyeCustomerCheckin {
  private String customerId, checkinUrl;
}
