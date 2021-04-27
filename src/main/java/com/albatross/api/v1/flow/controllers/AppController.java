package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.AttachmentType;
import com.albatross.api.v1.flow.model.AppAttachment;
import com.albatross.api.v1.flow.services.AppService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/app")
public class AppController {


  private final AppService appService;

  @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AppAttachment> getApps() {
    return appService.getAttachmentsByType(AttachmentType.APP_DOWNLOAD.id);
  }

  @GetMapping(value="/{appTypeId}/minVersion", produces = MediaType.APPLICATION_JSON_VALUE)
  public Long getMinVersionForType(@PathVariable Long appTypeId) {
    return appService.getMinVersionForType(appTypeId);
  }

  @PutMapping(value="/{appTypeId}/minVersion", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveMinVersionForType(@PathVariable Long appTypeId,
                                    @RequestParam Long minVersion) {
    appService.saveMinVersionForType(appTypeId, minVersion);
  }

  @GetMapping(value = "/latest/{appTypeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public AppAttachment getLastestBuild(@PathVariable Long appTypeId) {
    if (appTypeId == 2) {
      appTypeId = 1L;
    } else if (appTypeId == 4) {
      appTypeId = 3L;
    }
    return appService.getLatestAppByAppTypeIdAndType(appTypeId, AttachmentType.APP_DOWNLOAD.id);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteApp(@PathVariable Long id) {
    appService.delete(id);
  }

  @PutMapping(value = "/show", produces = MediaType.APPLICATION_JSON_VALUE)
  public void getApps(@RequestBody AppAttachment attachment) {
    appService.showOrHideAttachment(attachment);
  }

  @RequestMapping(method = RequestMethod.POST, value = "/addAttachmentRecord")
  public AppAttachment uploadDocument(@RequestBody AppAttachment appAttachment) throws IOException {

    AppAttachment newRecord = appService.insertAttachmentRecord(appAttachment);

    return newRecord;
  }
}
