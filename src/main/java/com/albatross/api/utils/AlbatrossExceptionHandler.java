package com.albatross.api.utils;

import com.albatross.api.model.RequestError;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AlbatrossExceptionHandler extends ResponseEntityExceptionHandler {

  final private SecurityService securityService;

  @ExceptionHandler(value = MultipartException.class)
  protected ResponseEntity<RequestError> multiExHandler(MultipartException e, WebRequest request) {
      logFileUploadException(request);
    return new ResponseEntity<>(new RequestError(e.getMessage()), HttpStatus.UNPROCESSABLE_ENTITY);
  }

  @ExceptionHandler(value = IOException.class)
  protected ResponseEntity<RequestError> ioExHandler(IOException e, WebRequest request) {
    logFileUploadException(request);
    return new ResponseEntity<>(new RequestError(e.getMessage()), HttpStatus.UNPROCESSABLE_ENTITY);
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
      info += ", companyId=" + user.getCompanyId() ;
    }

    info += ", attachmentTypeId=" + request.getParameter("attachmentTypeId");
    try {
      info += ", fileName=" + ((StandardMultipartHttpServletRequest) ((ServletWebRequest) request).getRequest()).getFile("file").getOriginalFilename();
    } catch (Exception e) {
      // noop
    }

    log.error("FILE UPLOAD: {}", info);
  }
}
