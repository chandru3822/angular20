package com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions;

public class InvalidStateApiException extends RuntimeException {
  public InvalidStateApiException() {
    super();
  }

  public InvalidStateApiException(String message) {
    super(message);
  }

  public InvalidStateApiException(String message, Throwable cause) {
    super(message, cause);
  }

  public InvalidStateApiException(Throwable cause) {
    super(cause);
  }

  public InvalidStateApiException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
    super(message, cause, enableSuppression, writableStackTrace);
  }
}
