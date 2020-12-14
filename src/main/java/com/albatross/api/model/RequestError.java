package com.albatross.api.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class RequestError {

  private String message, path;
  private int status;

  public RequestError(String message) {
    this.message = message;
  }
}
