package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
class BirdEyeCustomer {
  private String id;
  private String firstName;
  private String lastName;
  private String email;
  private String phone;
  private boolean smsOptin;
  private List<BirdEyeCustomField> customFields;
  private List<BirdEyeContactMapping> mappings;
}
