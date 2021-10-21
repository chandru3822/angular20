package com.albatross.api.utils;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.catalina.connector.ClientAbortException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.ServletWebRequest;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.multipart.support.StandardMultipartHttpServletRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.io.IOException;

@Slf4j
@ControllerAdvice
@RequiredArgsConstructor
public class AlbatrossExceptionHandler extends ResponseEntityExceptionHandler {

  private final SecurityService securityService;

  @ExceptionHandler(value = ClientAbortException.class)
  protected void handleClientAbortException() {
    // client was impatient or cancelled a request and we don't currently care about it
  }

  @ExceptionHandler(value = MultipartException.class)
  protected void multiExHandler(MultipartException e, WebRequest request) {
    logFileUploadException(request);
    log.error(e.getMessage());
  }

  @ExceptionHandler(value = IOException.class)
  protected void ioExHandler(IOException e, WebRequest request) {
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
}
