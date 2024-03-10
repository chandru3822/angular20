package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Announcement;
import com.albatross.api.v1.flow.services.AnnouncementService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/announcements", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class AnnouncementController {

  private final AnnouncementService announcementService;

//  note: /current actually returns current & future
  @GetMapping(value = "/current", produces = MediaType.APPLICATION_JSON_VALUE)
  public Page<Announcement> getCurrentAnnouncements(Pageable pageable) {
    return announcementService.getAnnouncements(true, pageable);
  }

  @GetMapping(value = "/active", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Announcement> getActiveAnnouncements(@RequestParam(required = false) Boolean mobile,
                                                   @RequestParam(required = false) Boolean doUpdate) {
    return announcementService.getActiveAnnouncements(mobile, doUpdate);
  }

  @GetMapping(value = "/past", produces = MediaType.APPLICATION_JSON_VALUE)
  public Page<Announcement> getPastAnnouncements(Pageable pageable) {
    return announcementService.getAnnouncements(false, pageable);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Announcement> saveAnnouncement(@RequestPart Announcement announcement,
                                                 @RequestPart(required = false) MultipartFile uploadFile) {
    return announcementService.saveAnnouncement(announcement, uploadFile);
  }

  @PostMapping(value = "/{id}/mark", produces = MediaType.APPLICATION_JSON_VALUE)
  public void markAnnouncementTime(@PathVariable Long id,
                                   @RequestParam(required = false) Boolean read,
                                   @RequestParam(required = false) Boolean seen,
                                   @RequestParam(required = false) Boolean alerted) {
    announcementService.markAnnouncementTime(id, read, seen, alerted);
  }

  @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Announcement> getAnnouncement(@PathVariable Long id) {
    return announcementService.getOneAnnouncement(id);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteAnnouncement(@PathVariable Long id) {
    announcementService.deleteAnnouncement(id);
  }
}
