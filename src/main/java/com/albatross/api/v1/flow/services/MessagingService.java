package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.flow.model.smsQueue.SMSQueueItem;
import com.albatross.api.v1.flow.model.smsQueue.TwilioMessageRequest;
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
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamUser;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class MessagingService {

  private final SqlCache sqlCache;
  private final NotificationService notificationService;
  private final PubSubService pubSubService;
  private final SecurityService securityService;
  private final ObjectMapper om;

  @Autowired
  private NamedParameterJdbcTemplate jdbc;

  public ProjectMessageProperties getProject(Long projectId) {
    User user = securityService.getCurrentUser();
    Optional<ProjectMessageProperties> projectMessageProps = sqlCache.get(
      "messaging.getProject",
      Map.of("projectId", projectId),
      new MessagePropertiesMapper<>(ProjectMessageProperties.class, om)
    );

    // The project conversation hasn't started yet, insert it
    if (!projectMessageProps.isPresent()) {
      sqlCache.update("messaging.insertProject", Map.of("projectId", projectId, "createdById", user.trueUserId()));
      projectMessageProps = sqlCache.get(
        "messaging.getProject",
        Map.of("projectId", projectId),
        new MessagePropertiesMapper<>(ProjectMessageProperties.class, om)
      );
    }

    ProjectMessageProperties projectMessage = projectMessageProps.get();

    return projectMessage;
  }

  public List<ProjectMessageProperties> getProjects() {
    User user = securityService.getCurrentUser();
    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "SMS_INBOX", List.of("VIEW_ALL"));

    List<SmsTeam> userAssignedTeams = getTeamsForUser();
    List<Long> smsTeamIds = userAssignedTeams.stream()
      .map(SmsTeam::getId)
      .collect(Collectors.toList());

    Map<String, Object> params =
      Map.of(
        "smsTeamIds", smsTeamIds,
        "viewAll", viewAll);

    List<ProjectMessageProperties> projectMessagesList =
      sqlCache.query(
        "messaging.getProjects", params, new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));

    return projectMessagesList;
  }

  public void updateProjectStatus(Long projectId, Boolean closed) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", null != user ? user.trueUserId() : SystemSettings.CRON_USER.getId());

    if (closed) {
      sqlCache.update("messaging.saveProjectStatusClosed", params);
    }
    else {
      sqlCache.update("messaging.saveProjectStatusOpen", params);
    }
  }

  public void addTeam(Long projectId, Long teamId, List<SmsTeamUser> ownersSelected, boolean defaultTeamAdded) {
    User user = securityService.getCurrentUser();

    Optional<Long> existingTeamId = sqlCache.queryForObjectOptional("messaging.getTeamId", Map.of("projectId", projectId, "teamId", teamId), Long.class);
    // If team is already associated with project, do not insert again
    if (!existingTeamId.isPresent()) {
      // Insert the SMS team to associate it with the project
      sqlCache.update("messaging.insertTeam", Map.of("projectId", projectId, "teamId", teamId, "createdById", user.trueUserId()));
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

    addSmsReplyNotification(projectId, teamId, new HashSet<>() {
      {
        addAll(ownerUserIds);
      }
    });

    addSmsOwnershipNotification(projectId);

    updateOwnerHistory(projectId, teamId, ownerUserIds.isEmpty() ? null : ownerUserIds, true, false);
    Optional<ProjectMessageProperties> projectMessageProps = sqlCache.get(
      "messaging.getProject",
      Map.of("projectId", projectId),
      new MessagePropertiesMapper<>(ProjectMessageProperties.class, om)
    );
    // Check if Project is closed, if so open it - unless the default team is being added automatically
    if (!defaultTeamAdded && projectMessageProps.isPresent() && projectMessageProps.get().isClosed()) {
      updateProjectStatus(projectId, false);
    }
  }

  public void removeTeam(Long projectId, Long smsTeamId) {
    ProjectMessageProperties pmp = getProject(projectId);
    // Insert the SMS team to associate it with the project
    sqlCache.update("messaging.removeTeam", Map.of("projectId", projectId, "smsTeamId", smsTeamId));
    sqlCache.update("messaging.removeTeamOwners", Map.of("projectId", projectId, "smsTeamId", smsTeamId));
    updateOwnerHistory(projectId, smsTeamId, null, false, true);

    Optional<ProjectMessageProperties> projectMessageProps = sqlCache.get(
      "messaging.getProject",
      Map.of("projectId", projectId),
      new MessagePropertiesMapper<>(ProjectMessageProperties.class, om)
    );

    try {
      notificationService.markSmsNotificationsAsRead(null, projectId, smsTeamId);
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
    return jdbc.queryForObject(sqlCache.getByKey("messaging.getHistory"), Map.of("projectId", projectId), String.class);
  }

  public void setLastSent(Long projectId) {
    User user = securityService.getCurrentUser();
    sqlCache.update("messaging.setLastSent", Map.of("projectId", projectId, "modifiedById", user.trueUserId()));
  }

  public void clearLastSent(Long projectId) {
    User user = securityService.getCurrentUser();
    sqlCache.update("messaging.clearLastSent", Map.of("projectId", projectId, "modifiedById", user.trueUserId()));
  }

  public void closeStaleProjects() {
    List<Long> projectIds = sqlCache.query("messaging.getStaleProjects", null, new SingleColumnRowMapper<>(Long.class));
    for (Long projectId: projectIds) {
      ProjectMessageProperties pmp = getProject(projectId);
      List<SmsTeam> smsTeams = pmp.getSmsTeamOwners();
      for (SmsTeam smsTeam: smsTeams) {
        removeTeam(projectId, smsTeam.getId());
      }
    }
  }

  public void removeOwner(Long projectId, ProjectMessageOwner owner) {
    User user = securityService.getCurrentUser();
    sqlCache.update("messaging.removeOwner", Map.of("projectId", projectId, "userId", owner.getUserId(), "smsTeamId", owner.getSmsTeamId(), "modifiedById", user.trueUserId()));
    updateOwnerHistory(projectId, owner.getSmsTeamId(), Arrays.asList(owner.getUserId()), false, false);

    try {
      notificationService.markSmsNotificationsAsRead(owner.getUserId(), projectId, owner.getSmsTeamId());
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    addSmsOwnershipNotification(projectId);
  }

  private void updateOwnerHistory(Long projectId, Long smsTeamId, List<Long> userIds, boolean isAdd, boolean removeTeam) {
    User user = securityService.getCurrentUser();
    String sqlQuery = "SELECT * FROM flow.set_sms_project_owner_history(:projectId::integer, :smsTeamId::integer, array[ :userIds ]::integer[], :modifiedById::integer, :isAdd::boolean, :removeTeam::boolean)";

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
    List<Long> projectIds = sqlCache.query("sms.getProjects", Map.of("from", cleanPhoneNumber), new SingleColumnRowMapper<>(Long.class));
    // For any Project that is closed and has no teams assigned, open the project and assign the default team
    addDefaultTeam(projectIds);
    for (Long projectId: projectIds) {
      // Reset the last sent message date, which is used to mark the conversation as stale after 3 days of no contact
      clearLastSent(projectId);
      // Get the list of the Users who are set to be notified for this project
      List<SmsTeamUser> ownerUsers = sqlCache.query("messaging.getOwnersForProject", Map.of("projectId", projectId),  SmsTeamUser.class);
      for (SmsTeamUser smsTeamUser: ownerUsers) {
        addSmsReplyNotification(projectId, smsTeamUser.getSmsTeamId(), new HashSet<>() {
          {
            add(smsTeamUser.getUserId());
          }
        });

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
      user.trueUserId()
    );
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Project
  public void addSmsOwnershipNotification(Long projectId) {
    ProjectMessageProperties pmp = getProject(projectId);
    for (SmsTeam smsTeam: pmp.getSmsTeamOwners()) {
      SmsTeam smsTeamDetails = getTeamUsers(smsTeam.getId());
      List<Long> smsTeamUserIds = smsTeamDetails.getUsers().stream()
        .map(SmsTeamUser::getUserId)
        .collect(Collectors.toList());

      if (!smsTeamUserIds.isEmpty()) {
        User user = securityService.getCurrentUser();
        // Remove the logged in User so their screen does not refresh after sending an SMS message
        smsTeamUserIds.remove(user.getId());
        addSmsOwnershipNotification(projectId, smsTeam.getId(), new HashSet<>() {
          {
            addAll(smsTeamUserIds);
          }
        });
      }
    }
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Project
  private void addSmsOwnershipNotification(ProjectMessageProperties pmp) {
    for (SmsTeam smsTeam: pmp.getSmsTeamOwners()) {
      SmsTeam smsTeamDetails = getTeamDetails(smsTeam.getId());
      List<Long> smsTeamUserIds = smsTeamDetails.getUsers().stream()
        .map(SmsTeamUser::getUserId)
        .collect(Collectors.toList());

      if (!smsTeamUserIds.isEmpty()) {
        addSmsOwnershipNotification(pmp.getProjectId(), smsTeam.getId(), new HashSet<>() {
          {
            addAll(smsTeamUserIds);
          }
        });
      }
    }
  }

  private void addSmsOwnershipNotification(Long projectId, Long smsTeamId, Set<Long> userIds) {
    User user = securityService.getCurrentUser();
    // Add notification for the current user so their data gets refreshed
    userIds.add(user.getId());

    for (Long userId: userIds) {
      Notification notification = new Notification();
      notification.setTopic(NotificationTopic.SMS_OWNERSHIP);
      notification.setTitle("Ownership has changed for this project");
      notification.setBody("");
      notification.setPriority(1);
      notification.setMetadata(Map.of("projectId", projectId, "smsTeamId", smsTeamId));
      notification.setUserId(userId);
      pubSubService.publish(EventChannel.NOTIFICATION, NotificationEventMessage.from(notification));
    }
  }

  public void addDefaultTeam(List<Long> projectIds) {
    User user = securityService.getCurrentUser();
    for (Long projectId: projectIds) {
      Optional<ProjectMessageProperties> projectMessageProps = sqlCache.get(
        "messaging.getProject",
        Map.of("projectId", projectId),
        new MessagePropertiesMapper<>(ProjectMessageProperties.class, om)
      );

      // Check if Project exists
      if (projectMessageProps.isPresent()) {
        ProjectMessageProperties projectMessage = projectMessageProps.get();
        // Check is the project has any sms owners
        if (projectMessage.getSmsTeamOwners().isEmpty()) {
          updateProjectStatus(projectId, false);
          Optional<Long> teamId = getDefaultTeamId();
          if (teamId.isPresent()) {
            addTeam(projectId, teamId.get(), null, true);
          }
        }
      }
      else {
        // If the project has not had a conversation, start it
        sqlCache.update("messaging.insertProject", Map.of("projectId", projectId, "createdById", user.trueUserId()));
        Optional<Long> teamId = getDefaultTeamId();
        if (teamId.isPresent()) {
          addTeam(projectId, teamId.get(), null, true);
        }
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

    Optional<Long> result = sqlCache.get("smsTeam.getDefaultTeamId", params, new SingleColumnRowMapper<>(Long.class));
    return result;
  }

  private List<SmsTeam> getTeamsForUser() {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("userId", user.getId());

    List<SmsTeam> teamsAssociatedToUser = sqlCache.query("smsTeam.getTeamsForUser", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
    teamsAssociatedToUser = teamsAssociatedToUser.stream().filter(u -> !u.getUsers().isEmpty()).collect(Collectors.toList());
    return teamsAssociatedToUser;
  }

  public void deleteConversation(Long projectId) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", null != user ? user.trueUserId() : SystemSettings.CRON_USER.getId());

    sqlCache.update("messaging.removeAllTeamOwners", params);
    sqlCache.update("messaging.removeAllTeams", params);
    sqlCache.update("messaging.deleteProjectConversation", params);

    try {
      notificationService.markSmsNotificationsAsRead(null, projectId, null);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }
  }

  private SmsTeam getTeamDetails(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<SmsTeam> result = sqlCache.get("smsTeam.getDetails", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
    return result.orElse(null);
  }

  public SmsTeam getTeamUsers(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);
    Optional<SmsTeam> result = sqlCache.get("smsTeam.getTeamUsers", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
    return result.orElse(null);
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
      bw.registerCustomEditor(List.class, "messageHistory",
        new JsonCollectionDeserializer(messageHistoryRef, objectMapper));
      TypeReference<List<SmsTeam>> teamsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "smsTeamOwners",
        new JsonCollectionDeserializer(teamsRef, objectMapper));
      TypeReference<List<SmsTeamUser>> usersRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "users",
        new JsonCollectionDeserializer(usersRef, objectMapper));
    }
  }

}
