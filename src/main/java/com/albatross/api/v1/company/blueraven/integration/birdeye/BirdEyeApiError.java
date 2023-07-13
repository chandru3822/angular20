package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class BirdEyeApiError {
  private Integer status;
  private Integer code;
  private String message;
}
