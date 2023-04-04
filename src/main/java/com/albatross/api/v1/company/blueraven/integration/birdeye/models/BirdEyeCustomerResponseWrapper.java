package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public
class BirdEyeCustomerResponseWrapper {
  private List<BirdEyeCustomer> customers;
  private Integer page, size, totalPages, totalCount;
}
