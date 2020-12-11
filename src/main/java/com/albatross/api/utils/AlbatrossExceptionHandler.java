package com.albatross.api.utils;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.multipart.MultipartException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.io.IOException;

@Slf4j
@ControllerAdvice
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AlbatrossExceptionHandler extends ResponseEntityExceptionHandler {

  final private SecurityService securityService;

  @ExceptionHandler(value = MultipartException.class)
  protected void multiExHandler(MultipartException e, WebRequest request) throws MultipartException {
    logger(request);
    throw e;
  }

  @ExceptionHandler(value = IOException.class)
  protected void ioExHandler(IOException e, WebRequest request) throws IOException {
    logger(request);
    throw e;
  }

  private void logger(WebRequest request) {
    String info = request.getDescription(false);

    User user = securityService.getCurrentUser();
    if (user != null) {
      info += ", userId: " + user.getId() + ", ";
      info += "companyId: " + user.getCompanyId() + ", ";
    }
    log.error("ALBA LOGGER: {}", info);
  }
}
