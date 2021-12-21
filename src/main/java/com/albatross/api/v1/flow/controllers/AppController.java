package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.AppType;
import com.albatross.api.v1.flow.enums.AttachmentType;
import com.albatross.api.v1.flow.model.AppAttachment;
import com.albatross.api.v1.flow.services.AppService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
    return appService.getAttachmentsByAttachmentType(AttachmentType.APP_DOWNLOAD.id);
  }

  @GetMapping(value="/ios", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AppAttachment> getIosApps() {
    return appService.getAttachmentsByAppAndAttachmentType(AppType.IOS.id, AttachmentType.APP_DOWNLOAD.id);
  }

  @GetMapping(value="/android", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<AppAttachment> getAndroidApps() {
    return appService.getAttachmentsByAppAndAttachmentType(AppType.ANDROID.id, AttachmentType.APP_DOWNLOAD.id);
  }

  @GetMapping(value="/{appTypeId}/minVersion", produces = MediaType.APPLICATION_JSON_VALUE)
  public Long getMinVersionForType(@PathVariable Long appTypeId) {
    //this endpoint actually returns the minimumRequiredBuildNumber, but the endpoint was named poorly (yes, by me)
    return appService.getMinVersionForType(appTypeId);
  }

  @GetMapping(value="/{appTypeId}/buildNumbers", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Long> getBuildNumbersForType(@PathVariable Long appTypeId) {
    return appService.getBuildNumbersForType(appTypeId);
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

    AppAttachment newRecord = appService.insertAttachmentRecord(appAttachment, null);

    return newRecord;
  }

  @RequestMapping(method = RequestMethod.POST, value = "/ios")
  public void uploadIosApp(@RequestParam String versionNumber,
                           @RequestParam Long buildNumber,
                           @RequestParam MultipartFile attachment,
                           @RequestParam MultipartFile secondaryAttachment) throws IOException {

    appService.uploadApp(versionNumber, buildNumber, AppType.IOS.id, attachment, secondaryAttachment);
  }

  @RequestMapping(method = RequestMethod.POST, value = "/android")
  public void uploadAndroidApp(@RequestParam String versionNumber,
                               @RequestParam Long buildNumber,
                               @RequestParam MultipartFile attachment) throws IOException {

    appService.uploadApp(versionNumber, buildNumber, AppType.ANDROID.id, attachment, null);
  }
}
