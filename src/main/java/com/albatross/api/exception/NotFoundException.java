package com.albatross.api.exception;

public class NotFoundException extends ApiException {
  public NotFoundException() {
    super();
  }

  public NotFoundException(String message) {
    super(message);
  }

  protected NotFoundException(
      String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
