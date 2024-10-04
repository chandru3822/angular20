package com.albatross.api.v1.flow.services;

import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.AnnouncementMessage;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Announcement;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.AnnouncementQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.Instant;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class AnnouncementService {
  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final AttachmentService attachmentService;
  private final PubSubService pubSubService;

  public Page<Announcement> getAnnouncements(Boolean current, Pageable pageable) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("current", current);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<Announcement> results = sqlCache.queryBySql(AnnouncementQuery.get, params, Announcement.class);
    Integer count = sqlCache.queryForObjectBySql(AnnouncementQuery.getCount, params, Integer.class);

    return new PageImpl<>(
      results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  public List<Announcement> getActiveAnnouncements(Boolean mobile, Boolean doUpdate) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("mobile", mobile != null ? mobile : false);
    //dont use true user id here.
    params.put("userId", user.getId());

    List<Announcement> results = sqlCache.queryBySql(AnnouncementQuery.getActive, params, Announcement.class);

    if(doUpdate != null && doUpdate) {
      //only update any that are not already read, seen and alerted
      for(Announcement a : results.stream().filter(r -> !r.getRead() || !r.getSeen() || !r.getAlerted()).toList()) {
        params.put("announcementId", a.getId());
        sqlCache.updateBySql(AnnouncementQuery.markUnseenAndAlertedAndRead, params);
        a.setAlerted(true);
        a.setSeen(true);
        /* this behavior is a little funky. we dont set the `Read` value on the returned data
           because BR wants the user to still see the red dots on the first load here.
           but not the next time. this code should set it for the next time, but return the previous value on load
           ....like i said...its weird
        */
      }
    }

    return results;
  }

  public void markAnnouncementTime(Long id, Boolean read, Boolean seen, Boolean alerted) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("announcementId", id);
    //dont use true user id here.
    params.put("userId", user.getId());

    //this needs to be re-done. -randa. we kept adding stuff after the fact and i didn't want to fix it
    if(read != null && read) {
      sqlCache.updateBySql(AnnouncementQuery.markAsRead, params);
    }

    if(seen != null && seen) {
      sqlCache.updateBySql(AnnouncementQuery.markAsSeen, params);
    }

    if(alerted != null && alerted) {
      sqlCache.updateBySql(AnnouncementQuery.markAsAlerted, params);
    }
  }

  public Optional<Announcement> getOneAnnouncement(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<Announcement> result = sqlCache.getBySql(AnnouncementQuery.getOne, params, Announcement.class);

    Attachment attachment = attachmentService.getOneBySourceIdAndType(id, 990L);
    if(result.isPresent() && null != attachment) {
      attachmentService.setAttachmentPresignedUrl(attachment);
      result.get().setPresignedUrl(attachment.getPresignedUrl());
      result.get().setAttachmentId(attachment.getId());
    }


    return result;
  }

  public Optional<Announcement> saveAnnouncement(Announcement a, MultipartFile file) {
    User user = securityService.getCurrentUser();
    Long id;

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("title", a.getTitle());
    params.put("alertText", a.getAlertText());
    params.put("subtitle", a.getSubtitle());
    params.put("description", a.getDescription());
    params.put("hyperlink", a.getHyperlink());
    params.put("startTime", a.getStartTime());
    params.put("endTime", a.getEndTime());
    params.put("expandable", a.getExpandable() != null ? a.getExpandable() : false);
    params.put("showOnWeb", a.getShowOnWeb() != null ? a.getShowOnWeb() : false);
    params.put("showOnMobile", a.getShowOnMobile() != null ? a.getShowOnMobile() : false);
    params.put("companyId", user.getCompanyId());

    if(a.getId() != null) {
      id = a.getId();
      params.put("id", id);
      sqlCache.updateBySql(AnnouncementQuery.update, params);
    } else {
      id = sqlCache.updateBySqlReturningId(AnnouncementQuery.insert, params, "id").longValue();
      //they should only be able to upload a file and save at the same time if it was an insert
    }

    if(file != null && !file.isEmpty()) {
      try {
        attachmentService.create(file, id, 990L, file.getName(), false);
      } catch (IOException e) {
        throw new RuntimeException(e);
      }
    }

    Optional<Announcement> announcement = getOneAnnouncement(id);
    Instant now = Instant.now();

    //if the announcement is not published and should be, do that now.
    if(announcement.isPresent() && !announcement.get().getPublished()
     && now.isAfter(announcement.get().getStartTime().toInstant()) &&
      (null == announcement.get().getEndTime() || now.isBefore(announcement.get().getEndTime().toInstant()))) {
      publishOneAnnouncement(announcement.get());
      announcement.get().setPublished(true);
    }

    return announcement;
  }

  public void publishActiveAnnouncements() {
    //for now only show_on_web notifications work. will need to adjust the query when that changes
    List<Announcement> announcements = sqlCache.queryBySql(AnnouncementQuery.getUnpublishedActive, Collections.emptyMap(), Announcement.class);
    for(Announcement a : announcements) {
      publishOneAnnouncement(a);
    }
  }

  public void publishOneAnnouncement(Announcement a) {
    //notifications for announcements only work for web so check it is a web announcement
    if(a.getShowOnWeb()) {
      Map<String, Object> params = new HashMap<>();
      params.put("id", a.getId());

      AnnouncementMessage am = new AnnouncementMessage();
      am.setAnnouncement(a);
      //todo: return the entire announcement in here
      pubSubService.publish(EventChannel.NOTIFICATION, am);
      sqlCache.updateBySql(AnnouncementQuery.savePublished, params);
    }
  }

  public void deleteAnnouncement(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", user.trueUserId());

    sqlCache.updateBySql(AnnouncementQuery.delete, params);

  }

}
