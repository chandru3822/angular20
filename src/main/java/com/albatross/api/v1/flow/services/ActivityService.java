package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.ApiException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.NotificationType;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.SmsPriority;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActivityService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final CommunicationService communicationService;
  private final ContactService contactService;
  private final ProjectService projectService;
  private final UserService userService;

  @Value("${app.home_url}")
  private String homeUrl;

  public List<ActivityType> getActivityTopicsByObject(Long objectTypeId, Long sourceId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getActivityTopicsByProject :
      objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.getActivityTopicsByContact :
      objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.getActivityTopicsByOrg :
      objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.getActivityTopicsByUser : null;

    List<ActivityType> activityTypes = sqlCache.queryBySql(sql, params, new ActivityTypeMapper<>(ActivityType.class, om));
    for(ActivityType at : activityTypes) {
      //filter out any zero counts. should only be for 'uncategorized' cuz it would be too time consuming to count them in sql for a case statement
      at.setActivityTypeHashtags(at.getActivityTypeHashtags().stream().filter(ath -> ath.getActivities().size() > 0).collect(Collectors.toList()));
    }
    return activityTypes;
  }

  public List<Activity> getActivitiesByObject(Long objectTypeId, Long sourceId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivities :
      objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.getContactActivities :
      objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.getOrgActivities :
      objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.getUserActivities : null;

    return sqlCache.queryBySql(sql, params, new ActivityMapper<>(Activity.class, om));
  }

  public void deleteActivityById(Long objectTypeId, Long activityId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("activityId", activityId);
    params.put("userId", user.trueUserId());
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.archiveProjectActivity :
      objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.archiveContactActivity :
      objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.archiveOrgActivity :
      objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.archiveUserActivity : null;

    sqlCache.updateBySql(sql, params);
  }

  public Optional<Activity> getOneActivity(Long objectTypeId, Long activityId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", activityId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivity :
            objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.getContactActivity :
            objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.getOrgActivity :
            objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.getUserActivity : null;

    return sqlCache.getBySql(sql, params, new ActivityMapper<>(Activity.class, om));
  }

  public void pinActivity(Long objectTypeId, Long activityId, Boolean pinned) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("activityId", activityId);
    params.put("pinned", pinned);
    params.put("userId", user.trueUserId());
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.saveProjectActivityPinned :
      objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.saveContactActivityPinned :
      objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.saveOrgActivityPinned :
      objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.saveUserActivityPinned : null;

    sqlCache.updateBySql(sql, params);
  }

  public Optional<Activity> addActivityByObject(Long objectTypeId, Long sourceId, Activity newActivity) {
    User user = securityService.getCurrentUser();


    HashMap<String, Object> params = new HashMap<>();
    params.put("note", newActivity.getNote());
    params.put("sourceId", sourceId);
    params.put("linked", null != newActivity.getLinked() ? newActivity.getLinked() : false);
    params.put("linkedPpsId", newActivity.getLinkedPpsId());
    params.put("linkedPpseId", newActivity.getLinkedPpseId());
    params.put("userId", user.trueUserId());
    //parameterizing for future use
    params.put("activityTypeId", 2);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.addProjectActivity :
      objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.addContactActivity :
      objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.addOrgActivity :
      objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.addUserActivity : null;

    Long id = sqlCache.updateBySqlReturningId(sql, params, "id").longValue();
    //handle any activity hashtags
    updateActivityHashtag(objectTypeId, id, newActivity.getActivityHashtags(), true);

    Optional<Activity> savedActivity = getOneActivity(objectTypeId, id);

    //only notify @ users if project or contact cuz users dont usually have access to the other screens (org and user)
    if(savedActivity.isPresent() && (objectTypeId.equals(ObjectType.PROJECT.id) || objectTypeId.equals(ObjectType.CONTACT.id))) {
      notifyMentionedUsers(savedActivity.get(), objectTypeId, sourceId);
    }
    return savedActivity;
  }

  public void notifyMentionedUsers(Activity activity, Long typeId, Long sourceId) {
    User currentUser = securityService.getCurrentUser();

    try (InputStream inputStream =
           NoteService.class.getResourceAsStream(
             "/communication/templates/note-mention-email.ftl.html")) {

      // Match for firstName lastName (Email)
      Pattern mentionedNameRegex = Pattern.compile("\\B@([a-zA-Z-\\s*()]+)\\s(\\S+) \\(([^)]+)\\)");
      Matcher m = mentionedNameRegex.matcher(activity.getNote());

      if (inputStream == null) {
        throw new RuntimeException("[Note] Unable to find template");
      }
      String template = IOUtils.toString(inputStream, Charset.defaultCharset());

      // If mention(s) are found in the Note
      while (m.find()) {
        String firstName = m.group(1);
        String lastName = m.group(2);
        String emailAddress = m.group(3);

        String locationOfNote = "";
        String link = "";
        // Used to store the Contact name or Project name which contains the Note
        String noteRefName = "";
        if (null != typeId && typeId.equals(ObjectType.CONTACT.id)) {
          locationOfNote = "contact";
          link = homeUrl + "/contact/" + sourceId;
          Contact c = contactService.getContact(sourceId);
          noteRefName = c.getFirstName() + " " + c.getLastName() + " - " + c.getId();
        } else if (null != typeId && typeId.equals(ObjectType.PROJECT.id)) {
          locationOfNote = "project";
          link = homeUrl + "/project/" + sourceId + "/details";
          Optional<Project> p = projectService.getProject(sourceId);
          if (p.isPresent()) {
            noteRefName = p.get().getProjectName() + " - " + p.get().getId();
          }
        }

        User mentionedUser = userService.findByUsernameOrEmailIgnoreCase(emailAddress);
        if (mentionedUser != null) {
          if (NotificationType.EMAIL.id.equals(mentionedUser.getNotificationTypeId())) {
            Map<String, Object> context = new HashMap<>();
            context.put("firstName", firstName);
            context.put("lastName", lastName);
            context.put("locationOfNote", locationOfNote);
            context.put("link", link);
            context.put("noteContents", activity.getNote());
            String emailSubject =
              currentUser.getFirstName()
                + " "
                + currentUser.getLastName()
                + " mentioned you in a note on "
                + noteRefName;
            communicationService.sendEmail(
              emailSubject,
              emailAddress,
              template,
              context,
              "noreply@albatross.myblueraven.com",
              "Albatross",
              currentUser.trueUserId(),
              null);
          } else {
            String groupId = UUID.randomUUID().toString();
            String textMessage =
              "You were mentioned in an Albatross note. Click here: "
                + link
                + " to open the "
                + locationOfNote
                + ".";
            communicationService.queueTextMessages(
              groupId, mentionedUser, textMessage, null, currentUser.trueUserId(), SmsPriority.NOTE_MENTION.level);
          }
        } else {
          log.warn("NOTE: Unable to find user account associated to email={}", emailAddress);
        }
      }
    } catch (IOException e) {
      log.error("NOTE: Error sending user mention email", e);
    }
  }

  public Optional<Activity> editActivityByObject(Long objectTypeId, Long activityId, Activity activity) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("note", activity.getNote());
    params.put("activityId", activityId);
    params.put("linked", activity.getLinked());
    params.put("linkedPpsId", activity.getLinkedPpsId());
    params.put("linkedPpseId", activity.getLinkedPpseId());
    params.put("userId", user.trueUserId());
    //only update the date modified and the modified by id if the content of the note changed, see sql
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.editProjectActivity :
      objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.editContactActivity :
      objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.editOrgActivity :
      objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.editUserActivity : null;

    sqlCache.updateBySql(sql, params);

    //handle any activity hashtags
    updateActivityHashtag(objectTypeId, activityId, activity.getActivityHashtags(), false);

    return getOneActivity(objectTypeId, activityId);
  }

  public List<ActivityHashtag> updateActivityHashtag(Long objectTypeId, Long activityId, List<ActivityHashtag> activityHashtags, Boolean newActivity) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("activityId", activityId);

    if(null != activityHashtags && activityHashtags.size() > 0) {
      for(ActivityHashtag activityHashtag : activityHashtags) {
        if(null != activityHashtag.getArchived() && activityHashtag.getArchived()) {
          //archive hashtag
          params.put("id", activityHashtag.getId());
          String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.archiveProjectActivityHashtag :
            objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.archiveContactActivityHashtag :
            objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.archiveOrgActivityHashtag :
            objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.archiveUserActivityHashtag : null;
          sqlCache.updateBySql(sql, params);
        } else {
          //handle upsert here
          params.put("hashtagId", activityHashtag.getHashtagId());
          String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.upsertProjectActivityHashtag :
            objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.upsertContactActivityHashtag :
            objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.upsertOrgActivityHashtag :
              objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.upsertUserActivityHashtag : null;
          sqlCache.updateBySql(sql, params);
        }
      }
      //because at least one hashtag was changed, we set the "modified by id" on the activity because that is how BR wants it to work
      if(!newActivity) {
        String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.setProjectActivityModified :
          objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.setContactActivityModified :
            objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.setOrgActivityModified :
              objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.setUserActivityModified : null;
        sqlCache.updateBySql(sql, params);
      }
    }

    return getActivityHashtags(objectTypeId, activityId);
  }

  public List<ActivityHashtag> getActivityHashtags(Long objectTypeId, Long activityId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("activityId", activityId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivityHashtags :
      objectTypeId.equals(ObjectType.CONTACT.id) ? ContactActivityQuery.getContactActivityHashtags :
      objectTypeId.equals(ObjectType.ORGANIZATION.id) ? OrgActivityQuery.getOrgActivityHashtags :
      objectTypeId.equals(ObjectType.USER.id) ? UserActivityQuery.getUserActivityHashtags : null;

    return sqlCache.queryBySql(sql, params, ActivityHashtag.class);
  }


  public static class ActivityMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ActivityMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ActivityHashtag>> activityHashtagsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "activityHashtags",
        new JsonCollectionDeserializer(activityHashtagsRef, objectMapper));

    }
  }

  public static class ActivityTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ActivityTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ActivityTypeHashtag>> activityHashtagsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "activityTypeHashtags",
        new JsonCollectionDeserializer(activityHashtagsRef, objectMapper));

    }
  }
}
