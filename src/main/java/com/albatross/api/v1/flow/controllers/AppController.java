package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.AppType;
import com.albatross.api.v1.flow.enums.AttachmentType;
import com.albatross.api.v1.flow.model.AppAttachment;
import com.albatross.api.v1.flow.services.AppService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/app", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class AppController {

  private final AppService appService;

  @Value(value = "${app.env}")
  private String environment;

  @GetMapping
  public List<AppAttachment> getApps() {
    return appService.getAttachmentsByAttachmentType(AttachmentType.APP_DOWNLOAD.id);
  }

  @GetMapping(value = "/ios")
  public List<AppAttachment> getIosApps() {
    return appService.getAttachmentsByAppAndAttachmentType(
        AppType.IOS.id, AttachmentType.APP_DOWNLOAD.id);
  }

  @GetMapping(value = "/android")
  public List<AppAttachment> getAndroidApps() {
    return appService.getAttachmentsByAppAndAttachmentType(
        AppType.ANDROID.id, AttachmentType.APP_DOWNLOAD.id);
  }

  @GetMapping(value = "/{appTypeId}/minVersion")
  public Long getMinVersionForType(@PathVariable Long appTypeId) {
    // this endpoint actually returns the minimumRequiredBuildNumber, but the endpoint was named
    // poorly (yes, by me)
    return appService.getMinVersionForType(appTypeId);
  }

  @GetMapping(value = "/{appTypeId}/buildNumbers")
  public List<Long> getBuildNumbersForType(@PathVariable Long appTypeId) {
    return appService.getBuildNumbersForType(appTypeId);
  }

  @PutMapping(value = "/{appTypeId}/minVersion")
  public void saveMinVersionForType(@PathVariable Long appTypeId, @RequestParam Long minVersion) {
    appService.saveMinVersionForType(appTypeId, minVersion);
  }

  @GetMapping(value = "/latest/{appTypeId}")
  public AppAttachment getLastestBuild(@PathVariable Long appTypeId) {
    if (appTypeId == 2) {
      appTypeId = 1L;
    } else if (appTypeId == 4) {
      appTypeId = 3L;
    }
    return appService.getLatestAppByAppTypeIdAndType(appTypeId, AttachmentType.APP_DOWNLOAD.id);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteApp(@PathVariable Long id) {
    appService.delete(id);
  }

  @PutMapping(value = "/show")
  public void showOrHideApps(@RequestBody AppAttachment attachment) {
    appService.showOrHideAttachment(attachment);
  }

  @PutMapping(value = "/beta")
  public void toggleBetaForApps(@RequestBody AppAttachment attachment) {
    appService.toggleBetaForAttachment(attachment);
  }

  @PostMapping(value = "/addAttachmentRecord")
  public AppAttachment uploadDocument(@RequestBody AppAttachment appAttachment) throws IOException {
    return appService.insertAttachmentRecord(appAttachment, null);
  }

  @PostMapping(value = "/ios")
  public void uploadIosApp(
      @RequestParam String versionNumber,
      @RequestParam Long buildNumber,
      @RequestParam MultipartFile attachment,
      @RequestParam MultipartFile secondaryAttachment)
      throws IOException {

    appService.uploadApp(
        versionNumber, buildNumber, AppType.IOS.id, attachment, secondaryAttachment);
  }

  @PostMapping(value = "/android")
  public void uploadAndroidApp(
      @RequestParam String versionNumber,
      @RequestParam Long buildNumber,
      @RequestParam MultipartFile attachment)
      throws IOException {

    appService.uploadApp(versionNumber, buildNumber, AppType.ANDROID.id, attachment, null);
  }

  // this endpoint is to help mobile with stage builds after a data dump from prod and we dropped
  // the entire schema and lost everything from flow.app_attachment
  @PreAuthorize("hasRootLevelAccess()")
  @PostMapping(value = "/fixData")
  public void fixMissingAppData(@RequestParam(required = false) Integer limit) {
    if (null != environment && (environment.equals("stage") || environment.equals("flux"))) {
      appService.fixMissingAppData(limit);
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Not available.", new Exception());
    }
  }
}
