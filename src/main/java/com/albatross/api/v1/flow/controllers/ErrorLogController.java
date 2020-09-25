package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ErrorLog;
import com.albatross.api.v1.flow.services.ErrorLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/errorLog")
public class ErrorLogController {

  private final ErrorLogService errorLogService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ErrorLog> getErrorLogsForCompany() {
    return errorLogService.getErrorLogsForCompany();
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteErrorLog(@PathVariable Long id) {
    errorLogService.deleteErrorLog(id);
  }

}
