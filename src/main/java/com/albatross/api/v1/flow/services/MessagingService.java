package com.albatross.api.v1.flow.services;

import com.albatross.api.config.CachingConfig;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.notification.NotificationService;
import com.albatross.api.notification.model.CreateNotificationDto;
import com.albatross.api.notification.model.Notification;
import com.albatross.api.notification.model.NotificationEventMessage;
import com.albatross.api.notification.model.NotificationTopic;
import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.ProjectMessageOwner;
import com.albatross.api.v1.flow.model.ProjectMessageProperties;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.smsQueue.SMSQueueItem;
import com.albatross.api.v1.flow.model.smsQueue.TwilioMessageRequest;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamUser;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class MessagingService {

  private final SqlCache sqlCache;
  private final NotificationService notificationService;
  private final PubSubService pubSubService;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final NamedParameterJdbcTemplate jdbc;
  private final CacheManager cacheManager;

  public ProjectMessageProperties getProject(Long projectId) {
    Optional<ProjectMessageProperties> projectMessageProps =
        sqlCache.get(
            "messaging.getProject",
            Map.of("projectId", projectId),
            new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));

    // The project conversation hasn't started yet, insert it
    if (projectMessageProps.isEmpty()) {
      User user = securityService.getCurrentUser();
      sqlCache.update(
          "messaging.insertProject",
          Map.of("projectId", projectId, "createdById", user.trueUserId()));

      projectMessageProps =
          sqlCache.get(
              "messaging.getProject",
              Map.of("projectId", projectId),
              new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));
    }

    return projectMessageProps.get();
  }

  public List<ProjectMessageProperties> getProjects() {
    User user = securityService.getCurrentUser();

    Boolean viewAll =
        securityService.userHasFeatureAccessLevel(
            user.getId(),
            user.getCompanyId(),
            user.getHighestCompanyId(),
            "SMS_INBOX",
            List.of("VIEW_ALL"));

    List<SmsTeam> userAssignedTeams = getTeamsForUser(user);
    List<Long> smsTeamIds = userAssignedTeams.stream().map(SmsTeam::getId).toList();

    Map<String, Object> params =
        Map.of(
            "smsTeamIds", smsTeamIds,
            "viewAll", viewAll);

    return sqlCache.query(
        "messaging.getProjects",
        params,
        new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));
  }

  public void updateProjectStatus(Long projectId, Boolean closed) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", null != user ? user.trueUserId() : SystemSettings.CRON_USER.getId());

    if (closed) {
      sqlCache.update("messaging.saveProjectStatusClosed", params);
    } else {
      sqlCache.update("messaging.saveProjectStatusOpen", params);
    }
  }

  public void addTeam(
      Long projectId, Long teamId, List<SmsTeamUser> ownersSelected, boolean defaultTeamAdded) {
    User user = securityService.getCurrentUser();

    Optional<Long> existingTeamId =
        sqlCache.queryForObjectOptional(
            "messaging.getTeamId", Map.of("projectId", projectId, "teamId", teamId), Long.class);
    // If team is already associated with project, do not insert again
    if (existingTeamId.isEmpty()) {
      // Insert the SMS team to associate it with the project
      sqlCache.update(
          "messaging.insertTeam",
          Map.of("projectId", projectId, "teamId", teamId, "createdById", user.trueUserId()));
    }

    List<Long> ownerUserIds = new ArrayList<>();
    if (ownersSelected != null && !ownersSelected.isEmpty()) {
      // Insert each of the SMS Team's Users so they are associated with the project
      for (SmsTeamUser owner : ownersSelected) {
        Map<String, Object> params = new HashMap<>();
        params.put("teamId", teamId);
        params.put("projectId", projectId);
        params.put("userId", owner.getUserId());
        params.put("createdById", user.trueUserId());
        sqlCache.update("messaging.insertOwner", params);
        ownerUserIds.add(owner.getUserId());
      }
    }

    addSmsReplyNotification(projectId, teamId, new HashSet<>(ownerUserIds));

    addSmsOwnershipNotification(projectId);

    updateOwnerHistory(
        projectId, teamId, ownerUserIds.isEmpty() ? null : ownerUserIds, true, false);
    Optional<ProjectMessageProperties> projectMessageProps =
        sqlCache.get(
            "messaging.getProject",
            Map.of("projectId", projectId),
            new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));
    // Check if Project is closed, if so open it - unless the default team is being added
    // automatically
    if (!defaultTeamAdded
        && projectMessageProps.isPresent()
        && projectMessageProps.get().isClosed()) {
      updateProjectStatus(projectId, false);
    }
  }

  public void removeTeam(Long projectId, Long smsTeamId) {
    ProjectMessageProperties pmp = getProject(projectId);
    // Insert the SMS team to associate it with the project
    sqlCache.update("messaging.removeTeam", Map.of("projectId", projectId, "smsTeamId", smsTeamId));
    sqlCache.update(
        "messaging.removeTeamOwners", Map.of("projectId", projectId, "smsTeamId", smsTeamId));
    updateOwnerHistory(projectId, smsTeamId, null, false, true);

    Optional<ProjectMessageProperties> projectMessageProps =
        sqlCache.get(
            "messaging.getProject",
            Map.of("projectId", projectId),
            new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));

    try {
      markSmsNotificationsAsRead(null, projectId, smsTeamId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    // Check if Project is open and the final team was removed, if so close the project
    if (projectMessageProps.isPresent()) {
      ProjectMessageProperties projectMessage = projectMessageProps.get();
      if (projectMessage.getSmsTeamOwners().isEmpty() && !projectMessage.isClosed()) {
        updateProjectStatus(projectId, true);
      }
    }

    addSmsOwnershipNotification(pmp);
  }

  public String getHistory(Long projectId) {
    return jdbc.queryForObject(
        sqlCache.getByKey("messaging.getHistory"), Map.of("projectId", projectId), String.class);
  }

  public void setLastSent(Long projectId) {
    User user = securityService.getCurrentUser();
    sqlCache.update(
        "messaging.setLastSent", Map.of("projectId", projectId, "modifiedById", user.trueUserId()));
  }

  public void clearLastSent(Long projectId) {
    User user = securityService.getCurrentUser();
    sqlCache.update(
        "messaging.clearLastSent",
        Map.of("projectId", projectId, "modifiedById", user.trueUserId()));
  }

  public void closeStaleProjects() {
    List<Long> projectIds =
        sqlCache.query("messaging.getStaleProjects", null, new SingleColumnRowMapper<>(Long.class));
    for (Long projectId : projectIds) {
      ProjectMessageProperties pmp = getProject(projectId);
      List<SmsTeam> smsTeams = pmp.getSmsTeamOwners();
      for (SmsTeam smsTeam : smsTeams) {
        removeTeam(projectId, smsTeam.getId());
      }
    }
  }

  @Transactional
  public void removeOwner(Long projectId, ProjectMessageOwner owner) {
    User user = securityService.getCurrentUser();
    sqlCache.update(
        "messaging.removeOwner",
        Map.of(
            "projectId",
            projectId,
            "userId",
            owner.getUserId(),
            "smsTeamId",
            owner.getSmsTeamId(),
            "modifiedById",
            user.trueUserId()));
    updateOwnerHistory(projectId, owner.getSmsTeamId(), List.of(owner.getUserId()), false, false);

    try {
      markSmsNotificationsAsRead(owner.getUserId(), projectId, owner.getSmsTeamId());
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    addSmsOwnershipNotification(projectId);
  }

  private void updateOwnerHistory(
      Long projectId, Long smsTeamId, List<Long> userIds, boolean isAdd, boolean removeTeam) {
    User user = securityService.getCurrentUser();
    String sqlQuery =
        "SELECT * FROM flow.set_sms_project_owner_history(:projectId::integer, :smsTeamId::integer, array[ :userIds ]::integer[], :modifiedById::integer, :isAdd::boolean, :removeTeam::boolean)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", projectId);
    parameters.addValue("smsTeamId", smsTeamId);
    parameters.addValue("userIds", userIds);
    parameters.addValue("modifiedById", user.trueUserId());
    parameters.addValue("isAdd", isAdd);
    parameters.addValue("removeTeam", removeTeam);

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  // Used to add notifications when a customer sends a SMS message to us
  public void addNotifications(TwilioMessageRequest sms) {
    String cleanPhoneNumber = sms.getFrom().replaceAll("[^0-9]", "");
    List<Long> projectIds =
        sqlCache.query(
            "sms.getProjects",
            Map.of("from", cleanPhoneNumber),
            new SingleColumnRowMapper<>(Long.class));

    // For any Project that is closed and has no teams assigned, open the project and assign the default team
    addDefaultTeam(projectIds);

    for (Long projectId : projectIds) {
      // Reset the last sent message date, which is used to mark the conversation as stale after 3 days of no contact
      clearLastSent(projectId);

      // Get the list of the Users who are set to be notified for this project
      List<SmsTeamUser> ownerUsers =
          sqlCache.query(
              "messaging.getOwnersForProject", Map.of("projectId", projectId), SmsTeamUser.class);

      for (SmsTeamUser smsTeamUser : ownerUsers) {
        addSmsReplyNotification(
            projectId, smsTeamUser.getSmsTeamId(), new HashSet<>(List.of(smsTeamUser.getUserId())));

        addSmsOwnershipNotification(projectId);
      }
    }
  }

  // Used for displaying a red dot notification on the SMS Inbox
  private void addSmsReplyNotification(Long projectId, Long smsTeamId, Set<Long> userIds) {
    User user = securityService.getCurrentUser();
    // Users should not see a notification when they add themselves to a conversation
    userIds.remove(user.getId());

    if (userIds.isEmpty()) {
      return;
    }

    notificationService.createNotification(
        new CreateNotificationDto()
            .setTopic(NotificationTopic.SMS_REPLY)
            .setTitle("New SMS message from customer")
            .setBody("")
            .setPriority(1)
            .setMetadata(Map.of("projectId", projectId, "smsTeamId", smsTeamId)),
        userIds,
        user.trueUserId());
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Project
  public void addSmsOwnershipNotification(Long projectId) {
    ProjectMessageProperties pmp = getProject(projectId);
    addSmsOwnershipNotification(pmp);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Project
  private void addSmsOwnershipNotification(ProjectMessageProperties pmp) {
    for (SmsTeam smsTeam : pmp.getSmsTeamOwners()) {
      SmsTeam smsTeamDetails = getTeamUsers(smsTeam.getId());
      List<Long> smsTeamUserIds =
          smsTeamDetails.getUsers().stream().map(SmsTeamUser::getUserId).toList();

      if (!smsTeamUserIds.isEmpty()) {
        addSmsOwnershipNotification(
            pmp.getProjectId(), smsTeam.getId(), new HashSet<>(smsTeamUserIds));
      }
    }
  }

  private void addSmsOwnershipNotification(Long projectId, Long smsTeamId, Set<Long> userIds) {
    User user = securityService.getCurrentUser();
    // Add notification for the current user so their data gets refreshed
    userIds.add(user.getId());

    for (Long userId : userIds) {
      Notification notification =
          new Notification()
              .setTopic(NotificationTopic.SMS_OWNERSHIP)
              .setTitle("Ownership has changed for this project")
              .setBody("")
              .setPriority(1)
              .setMetadata(Map.of("projectId", projectId, "smsTeamId", smsTeamId))
              .setUserId(userId);
      pubSubService.publish(EventChannel.NOTIFICATION, NotificationEventMessage.from(notification));
    }
  }

  public void addDefaultTeam(List<Long> projectIds) {
    User user = securityService.getCurrentUser();
    for (Long projectId : projectIds) {
      Optional<ProjectMessageProperties> projectMessageProps =
          sqlCache.get(
              "messaging.getProject",
              Map.of("projectId", projectId),
              new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));

      // Check if Project exists
      if (projectMessageProps.isPresent()) {
        ProjectMessageProperties projectMessage = projectMessageProps.get();
        // Check is the project has any sms owners
        if (projectMessage.getSmsTeamOwners().isEmpty()) {
          updateProjectStatus(projectId, false);
          Optional<Long> teamId = getDefaultTeamId();
          teamId.ifPresent(aLong -> addTeam(projectId, aLong, null, true));
        }
      } else {
        // If the project has not had a conversation, start it
        sqlCache.update(
            "messaging.insertProject",
            Map.of("projectId", projectId, "createdById", user.trueUserId()));
        Optional<Long> teamId = getDefaultTeamId();
        teamId.ifPresent(aLong -> addTeam(projectId, aLong, null, true));
      }
    }
  }

  private Optional<Long> getDefaultTeamId() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);

    return sqlCache.get(
        "smsTeam.getDefaultTeamId", params, new SingleColumnRowMapper<>(Long.class));
  }

  private List<SmsTeam> getTeamsForUser(@NonNull User user) {
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("userId", user.getId());

    return sqlCache
        .query(
            "smsTeam.getTeamsForUser",
            params,
            new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om))
        .stream()
        .filter(u -> !u.getUsers().isEmpty())
        .toList();
  }

  @Transactional
  public void deleteConversation(Long projectId) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", null != user ? user.trueUserId() : SystemSettings.CRON_USER.getId());

    sqlCache.update("messaging.removeAllTeamOwners", params);
    sqlCache.update("messaging.removeAllTeams", params);
    sqlCache.update("messaging.deleteProjectConversation", params);

    try {
      markSmsNotificationsAsRead(null, projectId, null);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }
  }

  private SmsTeam getTeamDetails(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache
        .get("smsTeam.getDetails", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om))
        .orElse(null);
  }

  public SmsTeam getTeamUsers(Long teamId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", teamId);

    return sqlCache
        .get("smsTeam.getTeamUsers", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om))
        .orElse(null);
  }

  private void markSmsNotificationsAsRead(Long userId, Long projectId, Long smsTeamId)
      throws SQLException {
    User user = securityService.getCurrentUser();

    int updatedRecords;
    final Long SMS_REPLY_NOTIFICATION_TOPIC_ID = 2L;

    final Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("projectId", projectId);
    params.put("notificationTopicId", SMS_REPLY_NOTIFICATION_TOPIC_ID);
    params.put("userId", userId);
    params.put("smsTeamId", smsTeamId);

    List<Long> userIds;

    if (userId != null) {
      updatedRecords = sqlCache.update("messaging.markSmsAsReadForUser", params);
      userIds = List.of(userId);

      Notification notification =
          new Notification()
              .setTopic(NotificationTopic.SMS_REPLY)
              .setTitle("Notification read")
              .setBody("")
              .setPriority(1)
              .setUserId(userId);

      pubSubService.publish(EventChannel.NOTIFICATION, NotificationEventMessage.from(notification));

      log.debug("[Messaging] Marked {} records as read for user={}", updatedRecords, userId);
    } else if (smsTeamId != null) {
      updatedRecords = sqlCache.update("messaging.markSmsAsReadForTeam", params);

      userIds =
          sqlCache.query(
              "messaging.findUserByForTeam", params, new SingleColumnRowMapper<>(Long.class));

      log.debug(
          "[Messaging] Marked {} records as read for smsTeamId={}", updatedRecords, smsTeamId);
    } else {
      updatedRecords = sqlCache.update("messaging.markSmsAsReadForProject", params);

      userIds =
          sqlCache.query(
              "messaging.findUserByForProject", params, new SingleColumnRowMapper<>(Long.class));

      log.debug(
          "[Messaging] Marked {} records as read for projectId={}", updatedRecords, projectId);
    }

    // make sure user notification cache is up-to-date
    clearUserCache(userIds);
  }

  private void clearUserCache(List<Long> userIds) {
    final Cache cache = cacheManager.getCache(CachingConfig.NOTIFICATION);
    if (cache != null) {
      userIds.forEach(cache::evictIfPresent);
    }
  }

  public static class MessagePropertiesMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public MessagePropertiesMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<SMSQueueItem>> messageHistoryRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "messageHistory",
          new JsonCollectionDeserializer(messageHistoryRef, objectMapper));
      TypeReference<List<SmsTeam>> teamsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "smsTeamOwners", new JsonCollectionDeserializer(teamsRef, objectMapper));
      TypeReference<List<SmsTeamUser>> usersRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "users", new JsonCollectionDeserializer(usersRef, objectMapper));
    }
  }
}
