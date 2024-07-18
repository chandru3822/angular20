package com.albatross.api.utils;

import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.User;
import jakarta.validation.ConstraintViolationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.catalina.connector.ClientAbortException;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.context.request.ServletWebRequest;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.context.request.async.AsyncRequestTimeoutException;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.multipart.support.StandardMultipartHttpServletRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.io.EOFException;
import java.io.IOException;
import java.net.SocketTimeoutException;
import java.util.List;

@Slf4j
@ControllerAdvice
@RequiredArgsConstructor
public class AlbatrossExceptionHandler extends ResponseEntityExceptionHandler {

  private final SecurityService securityService;

  @Override
  protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
    final var fieldErrorMessages =
      ex.getBindingResult().getFieldErrors().stream()
        .map(e -> new FieldErrorMessage(e.getField(), e.getDefaultMessage()))
        .toList();
    return ResponseEntity.badRequest().body(fieldErrorMessages);
  }

  @ExceptionHandler(ConstraintViolationException.class)
  protected ResponseEntity<Object> handleConstraintViolationException(
    ConstraintViolationException ex, WebRequest request) {
    final List<FieldErrorMessage> fieldErrorMessages =
      ex.getConstraintViolations().stream()
        .map(v -> new FieldErrorMessage(v.getPropertyPath().toString(), v.getMessage()))
        .toList();
    return ResponseEntity.badRequest().body(fieldErrorMessages);
  }

  @ResponseStatus(code = HttpStatus.NOT_FOUND)
  @ExceptionHandler(value = NotFoundException.class)
  protected ResponseEntity<ErrorMessage> handleNotFoundException(NotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ErrorMessage(ex.getMessage()));
  }

  @ExceptionHandler(value = ApiException.class)
  protected ResponseEntity<ErrorMessage> handleApiException(ApiException ex) {
    final Throwable rootCause = ExceptionUtils.getRootCause(ex);
    return ResponseEntity.badRequest().body(new ErrorMessage(rootCause.getMessage()));
  }

  @ExceptionHandler(value = ClientAbortException.class)
  protected void handleClientAbortException() {
    // client was impatient or cancelled a request and we don't currently care about it
  }

  @Override
  protected ResponseEntity<Object> handleAsyncRequestTimeoutException(AsyncRequestTimeoutException ex, HttpHeaders headers, HttpStatusCode status, WebRequest request) {
    //don't log this out
    return null;
  }

  @ExceptionHandler(value = MultipartException.class)
  protected void multiExHandler(MultipartException e, WebRequest request) {
    final Throwable rootCause = ExceptionUtils.getRootCause(e);
    if (!(rootCause instanceof EOFException || rootCause instanceof SocketTimeoutException)) {
      logFileUploadException(request);
      log.error(e.getMessage());
    }
  }

  @ExceptionHandler(value = IOException.class)
  protected void ioExHandler(IOException e, WebRequest request) {
    if (e.getMessage() != null && e.getMessage().contains("Broken pipe")) {
      if (request instanceof NativeWebRequest webRequest){
        final var servletRequest = ((ServletWebRequest) webRequest).getRequest();
        if (servletRequest.getRequestURI().contains("/notifications/")){
          log.debug("Ignored broken pipe exception for /notifications URL");
          return;
        }
      }
    }
    logFileUploadException(request);
    log.error(e.getMessage());
  }

  private void logFileUploadException(WebRequest request) {

    String info = request.getDescription(false);

    try {
      info += ", method=" + ((ServletWebRequest) request).getHttpMethod();
    } catch (Exception e) {
      // noop
    }

    User user = securityService.getCurrentUser();
    if (user != null) {
      info += ", userId=" + user.getId();
      info += ", companyId=" + user.getCompanyId();
    }

    info += ", attachmentTypeId=" + request.getParameter("attachmentTypeId");
    try {
      info +=
        ", fileName="
        + ((StandardMultipartHttpServletRequest) ((ServletWebRequest) request).getRequest())
          .getFile("file")
          .getOriginalFilename();
    } catch (Exception e) {
      // noop
    }

    log.error("FILE UPLOAD: {}", info);
  }

  public record ErrorMessage(String message) {
  }

  public record FieldErrorMessage(String field, String message) {
  }
}
