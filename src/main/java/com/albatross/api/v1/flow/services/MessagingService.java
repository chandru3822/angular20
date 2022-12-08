package com.albatross.api.v1.flow.services;

import com.albatross.api.config.CachingConfig;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@PreAuthorize("hasFeatureAccess('SMS_INBOX')")
@RequiredArgsConstructor
public class MessagingService {

  private final SqlCache sqlCache;
  private final NotificationService notificationService;
  private final PubSubService pubSubService;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final NamedParameterJdbcTemplate jdbc;
  private final CacheManager cacheManager;

  public ProjectMessageProperties getProject(Long projectId, Long modifiedByUserId) {
    Optional<ProjectMessageProperties> projectMessageProps =
        sqlCache.get(
            "messaging.getProject",
            Map.of("projectId", projectId),
            new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));

    // The project conversation hasn't started yet, insert it
    if (projectMessageProps.isEmpty()) {
      sqlCache.update(
          "messaging.insertProject",
          Map.of("projectId", projectId, "createdById",modifiedByUserId));

      projectMessageProps =
          sqlCache.get(
              "messaging.getProject",
              Map.of("projectId", projectId),
              new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));
    }

    return projectMessageProps.orElseThrow(()->new NotFoundException("Messaging project not found"));
  }

  public Page<ProjectMessageProperties> getProjects(String query, List<Long> ownerUserIds, List<Long> smsTeamIds, List<Long> notifProjectIds, Boolean showInbox, Pageable pageable) {
    boolean containsUnassigned = false;
    if (ownerUserIds.contains(-1L)) {
      containsUnassigned = true;
      ownerUserIds.remove(-1L);
    }

    final HashMap<String, Object> params = new HashMap<>();
    params.put("query", StringUtils.hasText(query) ? query: null );
    params.put("smsTeamIds", smsTeamIds);
    params.put("ownerIds", ownerUserIds);
    params.put("notifProjectIds", notifProjectIds);
    params.put("unassigned", containsUnassigned);
    params.put("showInbox", showInbox);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ProjectMessageProperties> projects = sqlCache.query(
        "messaging.getProjects",
        params,
        new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));

    int count = 0;
    if (!projects.isEmpty()) {
      List<Long> projectIds =
        sqlCache.query(
          "messaging.getProjectsCount",
          params,
          new SingleColumnRowMapper<>(Long.class));
      projects.get(0).setProjectIdsForFilter(projectIds);
      params.put("query", null);
      User user = securityService.getCurrentUser();
      List<SmsTeam> userSmsTeams = getTeamsForUser(user);
      List<Long> userSmsTeamIds =
        userSmsTeams.stream().map(SmsTeam::getId).toList();
      params.put("smsTeamIds", userSmsTeamIds);
      params.put("ownerIds", Arrays.asList(user.getId()));
      params.put("unassigned", true);
      params.put("showInbox", true);
      List<Long> projectIdsInbox =
        sqlCache.query(
          "messaging.getProjectsCount",
          params,
          new SingleColumnRowMapper<>(Long.class));
      params.put("showInbox", false);
      List<Long> projectIdsSent =
        sqlCache.query(
          "messaging.getProjectsCount",
          params,
          new SingleColumnRowMapper<>(Long.class));

      // Used for displaying the New and Sent notification badges on the SMS Inbox
      projects.get(0).setProjectIdsInbox(projectIdsInbox);
      projects.get(0).setProjectIdsSent(projectIdsSent);
      count = projectIds.size();
    }

    return new PageImpl<>(
      projects, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  private void updateProjectStatus(Long projectId, Boolean closed, @NonNull Long modifiedByUserId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", modifiedByUserId);

    sqlCache.update( closed ?"messaging.saveProjectStatusClosed" : "messaging.saveProjectStatusOpen", params);
  }

  public void addTeam(
    Long projectId, Long teamId, List<SmsTeamUser> ownersSelected, boolean defaultTeamAdded, Long modifiedByUserId) {

    boolean clearUnassignedNotifications = false;

    Optional<Long> existingTeamId =
        sqlCache.queryForObjectOptional(
            "messaging.getTeamId", Map.of("projectId", projectId, "teamId", teamId), Long.class);

    // If team is already associated with project, do not insert again
    if (existingTeamId.isEmpty()) {
      // Insert the SMS team to associate it with the project
      sqlCache.update(
          "messaging.insertTeam",
          Map.of("projectId", projectId, "teamId", teamId, "createdById", modifiedByUserId));
    }
    else {
      // Team has already been added and we are adding Owner(s)
      if (!ownersSelected.isEmpty()) {
        List<SmsTeam> smsTeams = getTeamsForProject(projectId);
        SmsTeam teamBeingAdded = smsTeams.stream()
          .filter(st -> st.getId().equals(teamId))
          .findFirst()
          .orElse(null);

        // Team exists and previously was unassigned
        if (teamBeingAdded != null && teamBeingAdded.getUsers().isEmpty()) {
          clearUnassignedNotifications = true;
        }
      }
    }


    List<Long> ownerUserIds = new ArrayList<>();
    List<Long> unassignedUserIds = new ArrayList<>();

    if (ownersSelected != null && !ownersSelected.isEmpty()) {
      // If a User joined via a previously Unassigned team - clear notifications for any user(s)
      // that receive unassigned notifications
      if (clearUnassignedNotifications) {
        final List<SmsTeam> unassignedSmsTeams = getTeamsUnassignedNotificationUsers(Arrays.asList(teamId));
        for (SmsTeam smsTeam: unassignedSmsTeams) {
          List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
          for (User user: usersToNotify) {
            List<Notification> notifications = notificationService.getUserNotifications(user.getId());
            List<Long> notificationIds = notifications.stream()
                                                       .filter(n -> (new Long ((Integer) n.getMetadata().get("projectId"))).equals(projectId))
                                                      .map(Notification::getId).toList();
            if (!notificationIds.isEmpty()) {
              try {
                notificationService.markUserNotificationsAsRead(user.getId(), notificationIds);
              } catch (SQLException e) {
                log.error("MESSAGE: sql exception when marking unassigned notifications as read: ", e);
              }
            }
          }
        }
      }

      final String insertOwnerSql = """
           insert into flow.project_message_owner
            (project_id, sms_team_id, user_id, created_by_id, date_created, modified_by_id, date_modified)
            values (?, ?, ?, ?, now(), ?, now())
      """;

      final DataSource dataSource = jdbc.getJdbcTemplate().getDataSource();
      if (dataSource != null){
        try (final Connection connection = dataSource.getConnection();
             final PreparedStatement ps = connection.prepareStatement(insertOwnerSql)) {

          // Insert each of the SMS Team's Users so they are associated with the project
          for (SmsTeamUser owner : ownersSelected) {
            if (ownerUserIds.contains(owner.getUserId())) {
              continue;
            }

            ownerUserIds.add(owner.getUserId());

            ps.setLong(1, projectId);
            ps.setLong(2, teamId);
            ps.setLong(3, owner.getUserId());
            ps.setLong(4, modifiedByUserId);
            ps.setLong(5, modifiedByUserId);

            ps.addBatch();
          }

          ps.executeBatch();

          } catch (SQLException e) {
          throw new RuntimeException(e);
        }
      }
    }
    else {
      final List<SmsTeam> smsTeams = getTeamsUnassignedNotificationUsers(Arrays.asList(teamId));
      for (SmsTeam smsTeam: smsTeams) {
        List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
        unassignedUserIds.addAll(usersToNotify.stream().map(User::getId).collect(Collectors.toSet()));
      }
    }

    final HashSet<Long> userIdsToNotify = new HashSet<>(ownerUserIds);
    userIdsToNotify.addAll(unassignedUserIds);
    //don't give a notification if the user added themselves to the group
    userIdsToNotify.remove(modifiedByUserId);

    addSmsReplyNotification(projectId, teamId, userIdsToNotify, modifiedByUserId);

    addSmsOwnershipNotification(projectId, modifiedByUserId);

    updateOwnerHistory(
        projectId, teamId, ownerUserIds.isEmpty() ? null : ownerUserIds, true, false, modifiedByUserId );

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
      updateProjectStatus(projectId, false, modifiedByUserId);
    }
  }

  public void removeTeam(Long projectId, Long smsTeamId, Long modifiedByUserId) {

    ProjectMessageProperties pmp = getProject(projectId, modifiedByUserId);
    // Insert the SMS team to associate it with the project
    sqlCache.update("messaging.removeTeam", Map.of("projectId", projectId, "smsTeamId", smsTeamId));
    sqlCache.update("messaging.removeTeamOwners", Map.of("projectId", projectId, "smsTeamId", smsTeamId));

    updateOwnerHistory(projectId, smsTeamId, null, false, true, modifiedByUserId);

    Optional<ProjectMessageProperties> projectMessageProps =
        sqlCache.get(
            "messaging.getProject",
            Map.of("projectId", projectId),
            new MessagePropertiesMapper<>(ProjectMessageProperties.class, om));

    try {
      markSmsNotificationsAsRead(null, projectId, smsTeamId, modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    // Check if Project is open and the final team was removed, if so close the project
    if (projectMessageProps.isPresent()) {
      ProjectMessageProperties projectMessage = projectMessageProps.get();
      if (projectMessage.getSmsTeamOwners().isEmpty() && !projectMessage.isClosed()) {
        updateProjectStatus(projectId, true, modifiedByUserId);
      }
    }

    addSmsOwnershipNotification(pmp, modifiedByUserId);
  }

  public String getHistory(Long projectId) {
    return jdbc.queryForObject(
        sqlCache.getByKey("messaging.getHistory"), Map.of("projectId", projectId), String.class);
  }

  public void setLastSent(Long projectId, Long modifiedByUserId) {
    sqlCache.update(
        "messaging.setLastSent", Map.of("projectId", projectId, "modifiedById", modifiedByUserId));
  }

  public void closeStaleProjects(Long modifiedByUserId) {
    List<Long> projectIds =
        sqlCache.query("messaging.getStaleProjects", null, new SingleColumnRowMapper<>(Long.class));
    for (Long projectId : projectIds) {
      ProjectMessageProperties pmp = getProject(projectId, modifiedByUserId);
      List<SmsTeam> smsTeams = pmp.getSmsTeamOwners();
      for (SmsTeam smsTeam : smsTeams) {
        removeTeam(projectId, smsTeam.getId(), modifiedByUserId );
      }
    }
  }

  @Transactional
  public void removeOwner(Long projectId, ProjectMessageOwner owner, Long modifiedByUserId) {
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
            modifiedByUserId));
    updateOwnerHistory(projectId, owner.getSmsTeamId(), List.of(owner.getUserId()), false, false, modifiedByUserId);

    try {
      markSmsNotificationsAsRead(owner.getUserId(), projectId, owner.getSmsTeamId(), modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    addSmsOwnershipNotification(projectId, modifiedByUserId);
  }

  private void updateOwnerHistory(
    Long projectId, Long smsTeamId, List<Long> userIds, boolean isAdd, boolean removeTeam, Long modifiedByUserId) {
    String sqlQuery =
        "SELECT * FROM flow.set_sms_project_owner_history(:projectId::bigint, :smsTeamId::bigint, array[ :userIds ]::bigint[], :modifiedById::bigint, :isAdd::boolean, :removeTeam::boolean)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("projectId", projectId);
    parameters.addValue("smsTeamId", smsTeamId);
    parameters.addValue("userIds", userIds);
    parameters.addValue("modifiedById", modifiedByUserId);
    parameters.addValue("isAdd", isAdd);
    parameters.addValue("removeTeam", removeTeam);

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  // Used to add notifications when a customer sends a SMS message to us
  @Async
  public void addNotifications(TwilioMessageRequest sms) {
    // database search col is looking for everything after the +1
    String cleanPhoneNumber = sms.getFrom().replaceAll("[^0-9]", "").substring(1);
    List<Long> projectIds =
        sqlCache.query(
            "sms.getProjects",
            Map.of("from", cleanPhoneNumber),
            new SingleColumnRowMapper<>(Long.class));

    // if there are no matching project ids then don't continue to process
    if (projectIds.isEmpty()){
      return;
    }

    // For any Project that is closed and has no teams assigned, open the project and assign the
    // default team
    addDefaultTeam(projectIds, SystemSettings.SYSTEM_USER.getId());

    // Reset the last sent message date, which is used to mark the conversation as stale after 3
    // days of no contact
    sqlCache.update(
      "messaging.clearLastSent",
      Map.of("projectIds", projectIds, "modifiedById", SystemSettings.SYSTEM_USER.getId()));

    for (Long projectId : projectIds) {

//      TODO: can we batch this call?
      // Get the list of the Users who are set to be notified for this project
      List<SmsTeamUser> ownerUsers =
          sqlCache.query(
              "messaging.getOwnersForProject", Map.of("projectId", projectId), SmsTeamUser.class);

      // If there are no owners, add unassigned notifications if applicable
      if (ownerUsers.isEmpty()) {
        ProjectMessageProperties pmp = getProject(projectId, SystemSettings.BR_SYSTEM_USER.getId());
        final List<Long> teamIds = pmp.getSmsTeamOwners().stream().map(SmsTeam::getId).toList();
        final List<SmsTeam> smsTeams = getTeamsUnassignedNotificationUsers(teamIds);
        for (SmsTeam smsTeam: smsTeams) {
          List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
          for (User user : usersToNotify) {
            addSmsReplyNotification(
              projectId, smsTeam.getId(), new HashSet<>(List.of(user.getId())), SystemSettings.SYSTEM_USER.getId());

            addSmsOwnershipNotification(projectId, SystemSettings.SYSTEM_USER.getId() );
          }
        }
      }
      else {
        for (SmsTeamUser smsTeamUser : ownerUsers) {
          addSmsReplyNotification(
            projectId, smsTeamUser.getSmsTeamId(), new HashSet<>(List.of(smsTeamUser.getUserId())), SystemSettings.SYSTEM_USER.getId());

          addSmsOwnershipNotification(projectId, SystemSettings.SYSTEM_USER.getId() );
        }
      }
    }
  }

  // Used for displaying a red dot notification on the SMS Inbox
  private void addSmsReplyNotification(Long projectId, Long smsTeamId, Set<Long> userIds, Long modifiedByUserId) {
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
        modifiedByUserId);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Project
  public void addSmsOwnershipNotification(Long projectId, Long modifiedByUserId) {
    ProjectMessageProperties pmp = getProject(projectId, modifiedByUserId);
    addSmsOwnershipNotification(pmp, modifiedByUserId);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Project
  private void addSmsOwnershipNotification(ProjectMessageProperties pmp, Long modifiedByUserId) {
    final List<Long> teamIds = pmp.getSmsTeamOwners().stream().map(SmsTeam::getId).toList();
    final List<SmsTeam> teamUsers = getTeamUsers(pmp.getCompanyId(), teamIds);

    for (SmsTeam smsTeamDetails : teamUsers) {

      List<Long> smsTeamUserIds =
        smsTeamDetails.getUsers().stream().map(SmsTeamUser::getUserId).toList();

      if (!smsTeamUserIds.isEmpty()) {
        addSmsOwnershipNotification(
          pmp.getProjectId(), smsTeamDetails.getId(), new HashSet<>(smsTeamUserIds), modifiedByUserId);
      }
    }
  }

  private void addSmsOwnershipNotification(Long projectId, Long smsTeamId, Set<Long> userIds, Long modifiedByUserId) {
    // Add notification for the current user so their data gets refreshed
    userIds.add(modifiedByUserId);

    for (Long userId : userIds) {
      pubSubService.publish(EventChannel.NOTIFICATION, new NotificationEventMessage()
        .setUserId(userId)
        .setTitle("Ownership has changed for this project")
        .setNotificationTopic(NotificationTopic.SMS_OWNERSHIP)
        .setBody("")
        .setPriority(1)
        .setMetadata(Map.of("projectId", projectId, "smsTeamId", smsTeamId))
      );
    }
  }

  public void addDefaultTeam(List<Long> projectIds, Long modifiedByUserId) {
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
          updateProjectStatus(projectId, false, modifiedByUserId);
          Optional<Long> teamId = getDefaultTeamId(projectMessage.getCompanyId());
          teamId.ifPresent(aLong -> addTeam(projectId, aLong, null, true, modifiedByUserId ));
        }
      } else {
        // If the project has not had a conversation, start it
        sqlCache.update(
            "messaging.insertProject",
            Map.of("projectId", projectId, "createdById", modifiedByUserId));
//        TODO: how do i know which company to use?
//        TODO: don't hardcode this to BR
        Optional<Long> teamId = getDefaultTeamId(SystemSettings.BR_SYSTEM_USER.getCompanyId());
        teamId.ifPresent(aLong -> addTeam(projectId, aLong, null, true, modifiedByUserId));
      }
    }
  }

  private Optional<Long> getDefaultTeamId(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);

    return sqlCache.get(
        "smsTeam.getDefaultTeamId", params, new SingleColumnRowMapper<>(Long.class));
  }

  private List<SmsTeam> getTeamsForUser(@NonNull User user) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.isParentCompany());
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

  public List<SmsTeam> getTeamsForProject(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    return sqlCache.query("messaging.getSmsTeamsForProject", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  @Transactional
  public void deleteConversation(Long projectId, Long modifiedByUserId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", modifiedByUserId);

    sqlCache.update("messaging.removeAllTeamOwners", params);
    sqlCache.update("messaging.removeAllTeams", params);
    sqlCache.update("messaging.deleteProjectConversation", params);

    try {
      markSmsNotificationsAsRead(null, projectId, null, modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }
  }

  private Optional<SmsTeam> getTeamDetails(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache
        .get("smsTeam.getDetails", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  private List<SmsTeam> getTeamUsers(Long companyId, List<Long> teamIds) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("ids", teamIds);

    if (teamIds == null || teamIds.isEmpty()){
      return List.of();
    }

    return sqlCache
        .query("smsTeam.getTeamUsers", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  private List<SmsTeam> getTeamsUnassignedNotificationUsers(List<Long> teamIds) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ids", teamIds);

    if (teamIds == null || teamIds.isEmpty()){
      return List.of();
    }

    return sqlCache
      .query("smsTeam.getTeamNotificationUsers", params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  private void markSmsNotificationsAsRead(Long userId, Long projectId, Long smsTeamId, @NonNull Long modifiedByUserId)
      throws SQLException {

    int updatedRecords;
    final Long SMS_REPLY_NOTIFICATION_TOPIC_ID = 2L;

    final Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", modifiedByUserId);
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

      Notification notification =
        new Notification()
          .setTopic(NotificationTopic.SMS_REPLY)
          .setTitle("Notification read")
          .setBody("")
          .setPriority(1)
          .setUserId(userId);

      pubSubService.publish(EventChannel.NOTIFICATION, NotificationEventMessage.from(notification));

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
