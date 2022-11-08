package com.albatross.api.v1.company.blueraven.integration.birdeye;

import lombok.Data;

@Data
public class BirdeyeApiError {
  private Integer code;
  private String message;
}
