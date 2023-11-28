package com.albatross.api.v1.company.blueraven.integration.bitrise;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class BitriseApiError {
  private Integer status;
  private Integer code;
  private String message;
}
