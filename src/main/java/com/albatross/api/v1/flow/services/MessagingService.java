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
import com.albatross.api.v1.flow.model.smsTeam.SmsConversation;
import com.albatross.api.v1.flow.model.ProjectMessageOwner;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserMessageOwner;
import com.albatross.api.v1.flow.model.smsQueue.TwilioMessageRequest;
import com.albatross.api.v1.flow.model.smsTeam.SmsOwner;
import com.albatross.api.v1.flow.model.smsTeam.SmsProject;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeamUser;
import com.albatross.api.v1.flow.queries.MessagingQuery;
import com.albatross.api.v1.flow.queries.SmsServiceQuery;
import com.albatross.api.v1.flow.queries.SmsTeamQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
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
@RequiredArgsConstructor
public class MessagingService {

  private final SqlCache sqlCache;
  private final NotificationService notificationService;
  private final PubSubService pubSubService;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final NamedParameterJdbcTemplate jdbc;
  private final CacheManager cacheManager;

  public SmsConversation getProject(Long projectId, Long modifiedByUserId) {
    Optional<SmsConversation> conversationMessageProps =
      sqlCache.getBySql(
        MessagingQuery.getProject,
        Map.of("projectId", projectId),
        new MessagePropertiesMapper<>(SmsConversation.class, om));

    // The project conversation hasn't started yet, insert it
    if (conversationMessageProps.isEmpty()) {
      sqlCache.updateBySql(
        MessagingQuery.insertProject,
        Map.of("projectId", projectId, "createdById", modifiedByUserId));

      conversationMessageProps =
        sqlCache.getBySql(
          MessagingQuery.getProject,
          Map.of("projectId", projectId),
          new MessagePropertiesMapper<>(SmsConversation.class, om));
    }

    return conversationMessageProps.orElseThrow(() -> new NotFoundException("Project conversation not found"));
  }

  public SmsConversation getUser(Long userId, Long modifiedByUserId) {
    Optional<SmsConversation> userMessageProps =
      sqlCache.getBySql(
        MessagingQuery.getUser,
        Map.of("userId", userId),
        new MessagePropertiesMapper<>(SmsConversation.class, om));

    // The project conversation hasn't started yet, insert it
    if (userMessageProps.isEmpty()) {
      sqlCache.updateBySql(
        MessagingQuery.insertUser,
        Map.of("userId", userId, "createdById", modifiedByUserId));

      userMessageProps =
        sqlCache.getBySql(
          MessagingQuery.getUser,
          Map.of("userId", userId),
          new MessagePropertiesMapper<>(SmsConversation.class, om));
    }

    return userMessageProps.orElseThrow(() -> new NotFoundException("User conversation not found"));
  }

  public Page<SmsConversation> getConversations(String query, Set<Long> ownerUserIds, Set<Long> smsTeamIds, Set<Long> notifConversationIds,
                                                Set<Long> notifUserIds, Boolean showExternal, Boolean showInternal, Boolean showInbox, Pageable pageable) {


    String cleanedQuery = query;
    if (cleanedQuery != null) {
      cleanedQuery = cleanedQuery.replaceAll("[*,.&]", "")
        .toLowerCase()
        .trim();
    }

    List<SmsConversation> conversations = new ArrayList<>();
    int count = 0;
    if (showExternal) {
      List<SmsConversation> externalConversations =
        getExternalConversations(
          cleanedQuery,
          ownerUserIds,
          smsTeamIds,
          notifConversationIds,
          showInbox,
          pageable);

      if (!externalConversations.isEmpty()) {
        //      todo solve this
//        count = projects.getFirst().getProjectIdsForFilter().size();
        conversations.addAll(externalConversations);
      }
    }

    if (showInternal) {
      List<SmsConversation> users =
        getUsers(
          cleanedQuery,
          ownerUserIds,
          smsTeamIds,
          notifUserIds,
          showInbox,
          pageable);

      if (!users.isEmpty()) {
        count += users.getFirst().getUserIdsForFilter().size();
        conversations.addAll(users);
        if (showExternal) {
          conversations.getFirst().setUserIdsForFilter(users.getFirst().getUserIdsForFilter());
          conversations.getFirst().setUserIdsInbox(users.getFirst().getUserIdsInbox());
          conversations.getFirst().setUserIdsSent(users.getFirst().getUserIdsSent());
        }
      }
    }

    return new PageImpl<>(
      conversations, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  public List<SmsConversation> getExternalConversations(String query, Set<Long> ownerUserIds, Set<Long> smsTeamIds, Set<Long> notifConversationIds, Boolean showInbox, Pageable pageable) {
    boolean containsUnassigned = false;
    if (ownerUserIds.contains(-1L)) {
      containsUnassigned = true;
      ownerUserIds.remove(-1L);
    }

    final HashMap<String, Object> params = new HashMap<>();
    params.put("query", StringUtils.hasText(query) ? query : null);
    params.put("smsTeamIds", smsTeamIds);
    params.put("ownerIds", ownerUserIds);
    params.put("notifConversationIds", notifConversationIds);
    params.put("unassigned", containsUnassigned);
    params.put("showInbox", showInbox);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<SmsConversation> externalConversations = sqlCache.queryBySql(
      MessagingQuery.getExternalConversations,
      params,
      new MessagePropertiesMapper<>(SmsConversation.class, om));

//      todo: figure this out
//    if (!projectConversations.isEmpty()) {
//      List<Long> projectIds = getProjectsCount(params);
//      ConversationMessageProperties first = projectConversations.getFirst();
//
//      User user = securityService.getCurrentUser();
//      List<SmsTeam> userSmsTeams = getTeamsForUser(user);
//      List<Long> userSmsTeamIds =
//        userSmsTeams.stream().map(SmsTeam::getId).toList();
//
//      Map<String, Object> combinedProps = new HashMap<>();
//      combinedProps.put("smsTeamIds", userSmsTeamIds);
//      combinedProps.put("ownerIds", List.of(user.getId()));
//      combinedProps.put("notifConversationIds", notifConversationIds);
//
//      Map<Boolean, List<ProjectCounter>> counters = getProjectsCombinedCount(combinedProps).stream()
//        .collect(Collectors.partitioningBy(ProjectCounter::isOutboundMessage));
//
////      params.put("showInbox", true);
//      List<Long> projectIdsInbox = counters.get(false).stream().map(ProjectCounter::getProjectId).toList();
////      params.put("showInbox", false);
//      List<Long> projectIdsSent = counters.get(true).stream().map(ProjectCounter::getProjectId).toList();
//
//      // Used for displaying the New and Sent notification badges on the SMS Inbox
//      first.setProjectIdsForFilter(projectIds);
//      first.setProjectIdsInbox(projectIdsInbox);
//      first.setProjectIdsSent(projectIdsSent);
//    }

    return externalConversations;
  }

  @Data
  static class ProjectCounter {
    private Long projectId;
    private boolean outboundMessage;
  }

  private List<ProjectCounter> getProjectsCombinedCount(Map<String, Object> params) {
    return sqlCache.queryBySql(
      MessagingQuery.getProjectCountCombined,
      params,
      new BeanPropertyRowMapper<>(ProjectCounter.class));
  }

  private List<Long> getProjectsCount(Map<String, Object> params) {
    return sqlCache.queryBySql(
      MessagingQuery.getProjectsCount,
      params,
      new SingleColumnRowMapper<>(Long.class));
  }

  public List<SmsConversation> getUsers(String query, Set<Long> ownerUserIds, Set<Long> smsTeamIds, Set<Long> notifUserIds, Boolean showInbox, Pageable pageable) {
    boolean containsUnassigned = false;
    if (ownerUserIds.contains(-1L)) {
      containsUnassigned = true;
      ownerUserIds.remove(-1L);
    }

    final HashMap<String, Object> params = new HashMap<>();
    params.put("query", StringUtils.hasText(query) ? query : null);
    params.put("smsTeamIds", smsTeamIds);
    params.put("ownerIds", ownerUserIds);
    params.put("notifUserIds", notifUserIds);
    params.put("unassigned", containsUnassigned);
    params.put("showInbox", showInbox);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<SmsConversation> users = sqlCache.queryBySql(
      MessagingQuery.getUsers,
      params,
      new MessagePropertiesMapper<>(SmsConversation.class, om));

    if (!users.isEmpty()) {
      List<Long> userIds = getUsersCount(params);
      SmsConversation first = users.getFirst();

      User user = securityService.getCurrentUser();
      List<SmsTeam> userSmsTeams = getTeamsForUser(user);
      List<Long> userSmsTeamIds =
        userSmsTeams.stream().map(SmsTeam::getId).toList();

      Map<String, Object> combinedProps = new HashMap<>();
      combinedProps.put("smsTeamIds", userSmsTeamIds);
      combinedProps.put("ownerIds", List.of(user.getId()));

      Map<Boolean, List<UserCounter>> counters = getUsersCountCombined(combinedProps).stream()
        .collect(Collectors.partitioningBy(UserCounter::isOutboundMessage));

//      params.put("showInbox", true);
      List<Long> userIdsInbox = counters.get(false).stream().map(UserCounter::getUserId).toList();

//      params.put("showInbox", false);
      List<Long> userIdsSent = counters.get(true).stream().map(UserCounter::getUserId).toList();

      // Used for displaying the New and Sent notification badges on the SMS Inbox
      first.setUserIdsForFilter(userIds);
      first.setUserIdsInbox(userIdsInbox);
      first.setUserIdsSent(userIdsSent);
    }

    return users;
  }

  @Data
  static class UserCounter {
    private Long userId;
    private boolean outboundMessage;
  }

  private List<UserCounter> getUsersCountCombined(Map<String, Object> params) {
    return sqlCache.queryBySql(
      MessagingQuery.getUsersCountCombined,
      params,
      new BeanPropertyRowMapper<>(UserCounter.class));
  }

  private List<Long> getUsersCount(Map<String, Object> params) {
    return sqlCache.queryBySql(
      MessagingQuery.getUsersCount,
      params,
      new SingleColumnRowMapper<>(Long.class));
  }

  private void updateProjectStatus(Long projectId, Boolean closed, @NonNull Long modifiedByUserId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", modifiedByUserId);

    String sql = closed ? MessagingQuery.saveProjectStatusClosed : MessagingQuery.saveProjectStatusOpen;
    sqlCache.updateBySql(sql, params);
  }

  private void updateUserStatus(Long userId, Boolean closed, @NonNull Long modifiedByUserId) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("modifiedById", modifiedByUserId);

    String sql = closed ? MessagingQuery.saveUserStatusClosed : MessagingQuery.saveUserStatusOpen;
    sqlCache.updateBySql(sql, params);
  }

  public void addTeamForProject(
    Long projectId, Long teamId, List<SmsTeamUser> ownersSelected, boolean defaultTeamAdded, Long modifiedByUserId) {

    boolean clearUnassignedNotifications = false;

    Optional<Long> existingTeamId =
      sqlCache.queryForObjectOptionalBySql(
        MessagingQuery.getProjectTeamId, Map.of("projectId", projectId, "teamId", teamId), Long.class);

    SmsTeam teamBeingAdded;
    if (existingTeamId.isEmpty()) {
      // Insert the SMS team to associate it with the project
      sqlCache.updateBySql(
        MessagingQuery.insertProjectTeam,
        Map.of("projectId", projectId, "teamId", teamId, "createdById", modifiedByUserId));
    } else {
      // Team has already been added and we are adding Owner(s)
      if (!ownersSelected.isEmpty()) {
        List<SmsTeam> existingSmsTeams = getTeamsForProject(projectId);
        teamBeingAdded = existingSmsTeams.stream()
          .filter(st -> st.getId().equals(teamId))
          .findFirst()
          .orElse(null);

        // Team exists and previously was unassigned
        if (teamBeingAdded != null && teamBeingAdded.getUsers().isEmpty()) {
          clearUnassignedNotifications = true;
        } else if (teamBeingAdded != null) {
          // Find any Owners that are attempting to be added but already are owners
          List<SmsTeamUser> ownersToSkipAdding = new ArrayList<>();
          for (SmsTeamUser userBeingAdded : ownersSelected) {
            SmsTeamUser userAlreadyExists = teamBeingAdded.getUsers().stream()
              .filter(u -> u.getUserId().equals(userBeingAdded.getUserId()))
              .findFirst()
              .orElse(null);

            if (userAlreadyExists != null) {
              ownersToSkipAdding.add(userBeingAdded);
            }
          }

          // Remove all selected users that are already owners
          ownersSelected.removeAll(ownersToSkipAdding);
          // If there are no new owners, return
          if (ownersSelected.isEmpty()) {
            return;
          }
        }
      }
    }


    List<Long> ownerUserIds = new ArrayList<>();
    List<Long> unassignedUserIds = new ArrayList<>();

    if (ownersSelected != null && !ownersSelected.isEmpty()) {
      // If a User joined via a previously Unassigned team - clear notifications for any user(s)
      // that receive unassigned notifications
      if (clearUnassignedNotifications) {
        final List<SmsTeam> unassignedSmsTeams = getTeamsUnassignedNotificationUsers(List.of(teamId));
        for (SmsTeam smsTeam : unassignedSmsTeams) {
          List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
          for (User user : usersToNotify) {
            List<Notification> notifications = notificationService.getProjectNotificationsForUser(user.getId());
            List<Long> notificationIds = notifications.stream()
              .filter(n -> (Long.valueOf((Integer) n.getMetadata().get("projectId"))).equals(projectId))
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
      if (dataSource != null) {
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
    } else {
      final List<SmsTeam> smsTeams = getTeamsUnassignedNotificationUsers(List.of(teamId));
      for (SmsTeam smsTeam : smsTeams) {
        List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
        unassignedUserIds.addAll(usersToNotify.stream().map(User::getId).collect(Collectors.toSet()));
      }
    }

    final HashSet<Long> userIdsToNotify = new HashSet<>(ownerUserIds);
    userIdsToNotify.addAll(unassignedUserIds);
    //don't give a notification if the user added themselves to the group
    userIdsToNotify.remove(modifiedByUserId);

    addSmsProjectReplyNotification(projectId, teamId, userIdsToNotify, modifiedByUserId);

    addSmsProjectOwnershipNotification(projectId, modifiedByUserId);

    updateProjectOwnerHistory(
      projectId, teamId, ownerUserIds.isEmpty() ? null : ownerUserIds, true, false, modifiedByUserId);

    Optional<SmsConversation> conversationMessageProps =
      sqlCache.getBySql(
        MessagingQuery.getProject,
        Map.of("projectId", projectId),
        new MessagePropertiesMapper<>(SmsConversation.class, om));

    // Check if Project is closed, if so open it - unless the default team is being added
    // automatically
    if (!defaultTeamAdded
        && conversationMessageProps.isPresent()
        && conversationMessageProps.get().isClosed()) {
      updateProjectStatus(projectId, false, modifiedByUserId);
    }
  }

  public void addTeamForUser(
    Long userId, Long teamId, List<SmsTeamUser> ownersSelected, boolean defaultTeamAdded, Long modifiedByUserId) {

    boolean clearUnassignedNotifications = false;

    Optional<Long> existingTeamId =
      sqlCache.queryForObjectOptionalBySql(
        MessagingQuery.getUserTeamId, Map.of("userId", userId, "teamId", teamId), Long.class);

    // If team is already associated with project, do not insert again
    if (existingTeamId.isEmpty()) {
      // Insert the SMS team to associate it with the User
      sqlCache.updateBySql(
        MessagingQuery.insertUserTeam,
        Map.of("userId", userId, "teamId", teamId, "createdById", modifiedByUserId));
    } else {
      // Team has already been added and we are adding Owner(s)
      if (!ownersSelected.isEmpty()) {
        List<SmsTeam> smsTeams = getTeamsForUserConversation(userId);
        SmsTeam teamBeingAdded = smsTeams.stream()
          .filter(st -> st.getId().equals(teamId))
          .findFirst()
          .orElse(null);

        // Team exists and previously was unassigned
        if (teamBeingAdded != null && teamBeingAdded.getUsers().isEmpty()) {
          clearUnassignedNotifications = true;
        } else if (teamBeingAdded != null) {
          // Find any Owners that are attempting to be added but already are owners
          List<SmsTeamUser> ownersToSkipAdding = new ArrayList<>();
          for (SmsTeamUser userBeingAdded : ownersSelected) {
            SmsTeamUser userAlreadyExists = teamBeingAdded.getUsers().stream()
              .filter(u -> u.getUserId().equals(userBeingAdded.getUserId()))
              .findFirst()
              .orElse(null);

            if (userAlreadyExists != null) {
              ownersToSkipAdding.add(userBeingAdded);
            }
          }

          // Remove all selected users that are already owners
          ownersSelected.removeAll(ownersToSkipAdding);
          // If there are no new owners, return
          if (ownersSelected.isEmpty()) {
            return;
          }
        }
      }
    }

    List<Long> ownerUserIds = new ArrayList<>();
    List<Long> unassignedUserIds = new ArrayList<>();

    if (ownersSelected != null && !ownersSelected.isEmpty()) {
      // If a User joined via a previously Unassigned team - clear notifications for any user(s)
      // that receive unassigned notifications
      if (clearUnassignedNotifications) {
        final List<SmsTeam> unassignedSmsTeams = getTeamsUnassignedNotificationUsers(List.of(teamId));
        for (SmsTeam smsTeam : unassignedSmsTeams) {
          List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
          for (User user : usersToNotify) {
            List<Notification> notifications = notificationService.getUserNotificationsForUser(user.getId());
            List<Long> notificationIds = notifications.stream()
              .filter(n -> (Long.valueOf((Integer) n.getMetadata().get("userId"))).equals(userId))
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
             insert into flow.user_message_owner
              (owner_user_id, sms_team_id, user_id, created_by_id, date_created, modified_by_id, date_modified)
              values (?, ?, ?, ?, now(), ?, now())
        """;

      final DataSource dataSource = jdbc.getJdbcTemplate().getDataSource();
      if (dataSource != null) {
        try (final Connection connection = dataSource.getConnection();
             final PreparedStatement ps = connection.prepareStatement(insertOwnerSql)) {

          // Insert each of the SMS Team's Users so they are associated with the project
          for (SmsTeamUser owner : ownersSelected) {
            if (ownerUserIds.contains(owner.getUserId())) {
              continue;
            }

            ownerUserIds.add(owner.getUserId());

            ps.setLong(1, userId);
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
    } else {
      final List<SmsTeam> smsTeams = getTeamsUnassignedNotificationUsers(List.of(teamId));
      for (SmsTeam smsTeam : smsTeams) {
        List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
        unassignedUserIds.addAll(usersToNotify.stream().map(User::getId).collect(Collectors.toSet()));
      }
    }

    final HashSet<Long> userIdsToNotify = new HashSet<>(ownerUserIds);
    userIdsToNotify.addAll(unassignedUserIds);
    //don't give a notification if the user added themselves to the group
    userIdsToNotify.remove(modifiedByUserId);

    addSmsUserReplyNotification(userId, teamId, userIdsToNotify, modifiedByUserId);

    addSmsUserOwnershipNotification(userId, modifiedByUserId);

    updateUserOwnerHistory(
      userId, teamId, ownerUserIds.isEmpty() ? null : ownerUserIds, true, false, modifiedByUserId);

    Optional<SmsConversation> userMessageProps =
      sqlCache.getBySql(
        MessagingQuery.getUser,
        Map.of("userId", userId),
        new MessagePropertiesMapper<>(SmsConversation.class, om));

    // Check if Project is closed, if so open it - unless the default team is being added
    // automatically
    if (!defaultTeamAdded
        && userMessageProps.isPresent()
        && userMessageProps.get().isClosed()) {
      updateUserStatus(userId, false, modifiedByUserId);
    }
  }

  public void removeProjectTeam(Long projectId, Long smsTeamId, Long modifiedByUserId) {

    SmsConversation cmp = getProject(projectId, modifiedByUserId);
    // Insert the SMS team to associate it with the project
    sqlCache.updateBySql(MessagingQuery.removeProjectTeam, Map.of("projectId", projectId, "smsTeamId", smsTeamId));
    sqlCache.updateBySql(MessagingQuery.removeProjectTeamOwners, Map.of("projectId", projectId, "smsTeamId", smsTeamId));

    updateProjectOwnerHistory(projectId, smsTeamId, null, false, true, modifiedByUserId);

    Optional<SmsConversation> conversationMessageProps =
      sqlCache.getBySql(
        MessagingQuery.getProject,
        Map.of("projectId", projectId),
        new MessagePropertiesMapper<>(SmsConversation.class, om));

    try {
      markSmsProjectNotificationsAsRead(null, projectId, smsTeamId, modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    // Check if Project is open and the final team was removed, if so close the project
    if (conversationMessageProps.isPresent()) {
      SmsConversation projectMessage = conversationMessageProps.get();
//      todo solve this
//      if (projectMessage.getSmsTeamOwners().isEmpty() && !projectMessage.isClosed()) {
//        updateProjectStatus(projectId, true, modifiedByUserId);
//      }
    }

    addSmsProjectOwnershipNotification(cmp, modifiedByUserId);
  }

  public void removeUserTeam(Long userId, Long smsTeamId, Long modifiedByUserId) {

    SmsConversation cmp = getUser(userId, modifiedByUserId);
    sqlCache.updateBySql(MessagingQuery.removeUserTeam, Map.of("userId", userId, "smsTeamId", smsTeamId));
    sqlCache.updateBySql(MessagingQuery.removeUserTeamOwners, Map.of("ownerUserId", userId, "smsTeamId", smsTeamId));

    updateUserOwnerHistory(userId, smsTeamId, null, false, true, modifiedByUserId);

    Optional<SmsConversation> convMessageProps =
      sqlCache.getBySql(
        MessagingQuery.getUser,
        Map.of("userId", userId),
        new MessagePropertiesMapper<>(SmsConversation.class, om));

    try {
      markSmsUserNotificationsAsRead(null, userId, smsTeamId, modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS User notifications as read {}", e.getMessage());
    }

    // Check if the conversation is open and the final team was removed, if so close it
    if (convMessageProps.isPresent()) {
      SmsConversation userMessage = convMessageProps.get();
      //      todo solve this
//      if (userMessage.getSmsTeamOwners().isEmpty() && !userMessage.isClosed()) {
//        updateUserStatus(userId, true, modifiedByUserId);
//      }
    }

    addSmsUserOwnershipNotification(cmp, modifiedByUserId);
  }

  public String getProjectHistory(Long projectId) {
    return jdbc.queryForObject(MessagingQuery.getProjectHistory, Map.of("projectId", projectId), String.class);
  }

  public String getUserHistory(Long userId) {
    return jdbc.queryForObject(MessagingQuery.getUserHistory, Map.of("userId", userId), String.class);
  }

  public void setLastSentForProject(Long projectId, Long modifiedByUserId) {
    sqlCache.updateBySql(
      MessagingQuery.setLastSentForProject, Map.of("projectId", projectId, "modifiedById", modifiedByUserId));
  }

  public void setLastSentForUser(Long userId, Long modifiedByUserId) {
    sqlCache.updateBySql(
      MessagingQuery.setLastSentForUser, Map.of("userId", userId, "modifiedById", modifiedByUserId));
  }

  public void closeStaleProjectConversations(Long modifiedByUserId) {
    List<Long> projectIds =
      sqlCache.queryBySql(MessagingQuery.getStaleProjects, null, new SingleColumnRowMapper<>(Long.class));
    for (Long projectId : projectIds) {
      SmsConversation cmp = getProject(projectId, modifiedByUserId);
      //      todo solve this
//      List<SmsTeam> smsTeams = cmp.getSmsTeamOwners();
//      for (SmsTeam smsTeam : smsTeams) {
//        removeProjectTeam(projectId, smsTeam.getId(), modifiedByUserId);
//      }
    }
  }

  public void closeStaleUserConversations(Long modifiedByUserId) {
    List<Long> userIds =
      sqlCache.queryBySql(MessagingQuery.getStaleUsers, null, new SingleColumnRowMapper<>(Long.class));
    for (Long userId : userIds) {
      removeTeamsFromUserConversation(userId, modifiedByUserId);
    }
  }

  public void removeTeamsFromUserConversation(Long userId, Long modifiedByUserId) {
    SmsConversation cmp = getUser(userId, modifiedByUserId);
    //      todo solve this
//    List<SmsTeam> smsTeams = cmp.getSmsTeamOwners();
//    for (SmsTeam smsTeam : smsTeams) {
//      removeUserTeam(userId, smsTeam.getId(), modifiedByUserId);
//    }
  }

  @Transactional
  public void removeProjectOwner(Long projectId, ProjectMessageOwner owner, Long modifiedByUserId) {
    sqlCache.updateBySql(
      MessagingQuery.removeProjectOwner,
      Map.of(
        "projectId",
        projectId,
        "userId",
        owner.getUserId(),
        "smsTeamId",
        owner.getSmsTeamId(),
        "modifiedById",
        modifiedByUserId));
    updateProjectOwnerHistory(projectId, owner.getSmsTeamId(), List.of(owner.getUserId()), false, false, modifiedByUserId);

    try {
      markSmsProjectNotificationsAsRead(owner.getUserId(), projectId, owner.getSmsTeamId(), modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    addSmsProjectOwnershipNotification(projectId, modifiedByUserId);
  }

  @Transactional
  public void removeUserOwner(Long userId, UserMessageOwner owner, Long modifiedByUserId) {
    sqlCache.updateBySql(
      MessagingQuery.removeUserOwner,
      Map.of(
        "ownerUserId",
        userId,
        "userId",
        owner.getUserId(),
        "smsTeamId",
        owner.getSmsTeamId(),
        "modifiedById",
        modifiedByUserId));
    updateUserOwnerHistory(userId, owner.getSmsTeamId(), List.of(owner.getUserId()), false, false, modifiedByUserId);

    try {
      markSmsUserNotificationsAsRead(owner.getUserId(), userId, owner.getSmsTeamId(), modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    addSmsUserOwnershipNotification(userId, modifiedByUserId);
  }

  private void updateProjectOwnerHistory(
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

  private void updateUserOwnerHistory(
    Long userId, Long smsTeamId, List<Long> userIds, boolean isAdd, boolean removeTeam, Long modifiedByUserId) {
    String sqlQuery =
      "SELECT * FROM flow.set_sms_user_owner_history(:userId::bigint, :smsTeamId::bigint, array[ :userIds ]::bigint[], :modifiedById::bigint, :isAdd::boolean, :removeTeam::boolean)";

    MapSqlParameterSource parameters = new MapSqlParameterSource();
    parameters.addValue("userId", userId);
    parameters.addValue("smsTeamId", smsTeamId);
    parameters.addValue("userIds", userIds);
    parameters.addValue("modifiedById", modifiedByUserId);
    parameters.addValue("isAdd", isAdd);
    parameters.addValue("removeTeam", removeTeam);

    jdbc.queryForObject(sqlQuery, parameters, String.class);
  }

  // Used to add notifications when a customer/user send an SMS message reply
  @Async
  public void addNotifications(TwilioMessageRequest sms) {
    // database search col is looking for everything after the +1
    String cleanPhoneNumber = sms.getFrom().replaceAll("[^0-9]", "").substring(1);
    List<Long> projectIds =
      sqlCache.queryBySql(
        SmsServiceQuery.getProjects,
        Map.of("from", cleanPhoneNumber),
        new SingleColumnRowMapper<>(Long.class));

    if (!projectIds.isEmpty()) {
      // For any Project that is closed and has no teams assigned, open the project and assign the
      // default team
      addProjectDefaultTeam(projectIds, SystemSettings.SYSTEM_USER.getId());

      // Reset the last sent message date, which is used to mark the conversation as stale after 3
      // days of no contact
      sqlCache.updateBySql(
        MessagingQuery.clearProjectLastSent,
        Map.of("projectIds", projectIds, "modifiedById", SystemSettings.SYSTEM_USER.getId()));

      for (Long projectId : projectIds) {

//      TODO: can we batch this call?
        // Get the list of the Users who are set to be notified for this project
        List<SmsTeamUser> ownerUsers =
          sqlCache.queryBySql(
            MessagingQuery.getOwnersForProject, Map.of("projectId", projectId), SmsTeamUser.class);

        // If there are no owners, add unassigned notifications if applicable
        if (ownerUsers.isEmpty()) {
          SmsConversation cmp = getProject(projectId, SystemSettings.BR_SYSTEM_USER.getId());
          //      todo solve this
//          final List<Long> teamIds = cmp.getSmsTeamOwners().stream().map(SmsTeam::getId).toList();
//          final List<SmsTeam> smsTeams = getTeamsUnassignedNotificationUsers(teamIds);
//          for (SmsTeam smsTeam : smsTeams) {
//            List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
//            for (User user : usersToNotify) {
//              addSmsProjectReplyNotification(
//                projectId, smsTeam.getId(), new HashSet<>(List.of(user.getId())), SystemSettings.SYSTEM_USER.getId());

//              addSmsProjectOwnershipNotification(projectId, SystemSettings.SYSTEM_USER.getId());
//            }
//          }
        } else {
          for (SmsTeamUser smsTeamUser : ownerUsers) {
            addSmsProjectReplyNotification(
              projectId, smsTeamUser.getSmsTeamId(), new HashSet<>(List.of(smsTeamUser.getUserId())), SystemSettings.SYSTEM_USER.getId());

            addSmsProjectOwnershipNotification(projectId, SystemSettings.SYSTEM_USER.getId());
          }
        }
      }
    }

    // Find User(s) that this phone number belongs to
    List<Long> userIds =
      sqlCache.queryBySql(
        SmsServiceQuery.getUsers,
        Map.of("from", cleanPhoneNumber),
        new SingleColumnRowMapper<>(Long.class));

    if (!userIds.isEmpty()) {
      // For any User conversation that is closed and has no teams assigned, open the User conversation and assign the
      // default team
      addUserDefaultTeam(userIds, SystemSettings.SYSTEM_USER.getId());

      // Reset the last sent message date, which is used to mark the conversation as stale after 3
      // days of no contact
      sqlCache.updateBySql(
        MessagingQuery.clearUserLastSent,
        Map.of("userIds", userIds, "modifiedById", SystemSettings.SYSTEM_USER.getId()));

      for (Long userId : userIds) {
//      TODO: can we batch this call?
        // Get the list of the Users who are set to be notified for this user conversation
        List<SmsTeamUser> ownerUsers =
          sqlCache.queryBySql(
            MessagingQuery.getOwnersForUser, Map.of("userId", userId), SmsTeamUser.class);

        // If there are no owners, add unassigned notifications if applicable
        if (ownerUsers.isEmpty()) {
          SmsConversation cmp = getUser(userId, SystemSettings.BR_SYSTEM_USER.getId());
          //      todo solve this
//          final List<Long> teamIds = cmp.getSmsTeamOwners().stream().map(SmsTeam::getId).toList();
//          final List<SmsTeam> smsTeams = getTeamsUnassignedNotificationUsers(teamIds);
//          for (SmsTeam smsTeam : smsTeams) {
//            List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
//            for (User user : usersToNotify) {
//              addSmsUserReplyNotification(
//                userId, smsTeam.getId(), new HashSet<>(List.of(user.getId())), SystemSettings.SYSTEM_USER.getId());
//
//              addSmsUserOwnershipNotification(userId, SystemSettings.SYSTEM_USER.getId());
//            }
//          }
        } else {
          for (SmsTeamUser smsTeamUser : ownerUsers) {
            addSmsUserReplyNotification(
              userId, smsTeamUser.getSmsTeamId(), new HashSet<>(List.of(smsTeamUser.getUserId())), SystemSettings.SYSTEM_USER.getId());

            addSmsUserOwnershipNotification(userId, SystemSettings.SYSTEM_USER.getId());
          }
        }
      }
    }
  }

  // Used for displaying a red dot notification on the SMS Inbox
  private void addSmsProjectReplyNotification(Long projectId, Long smsTeamId, Set<Long> userIds, Long modifiedByUserId) {
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
  public void addSmsProjectOwnershipNotification(Long projectId, Long modifiedByUserId) {
    SmsConversation cmp = getProject(projectId, modifiedByUserId);
    addSmsProjectOwnershipNotification(cmp, modifiedByUserId);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Project
  private void addSmsProjectOwnershipNotification(SmsConversation cmp, Long modifiedByUserId) {
    //      todo solve this
//    final List<Long> teamIds = cmp.getSmsTeamOwners().stream().map(SmsTeam::getId).toList();
//    final List<SmsTeam> teamUsers = getTeamUsers(cmp.getCompanyId(), teamIds);
//
//    for (SmsTeam smsTeamDetails : teamUsers) {
//
//      List<Long> smsTeamUserIds =
//        smsTeamDetails.getUsers().stream().map(SmsTeamUser::getUserId).toList();
//
//      if (!smsTeamUserIds.isEmpty()) {
//        addSmsProjectOwnershipNotification(
//          cmp.getProjectId(), smsTeamDetails.getId(), new HashSet<>(smsTeamUserIds), modifiedByUserId);
//      }
//    }
  }

  private void addSmsProjectOwnershipNotification(Long projectId, Long smsTeamId, Set<Long> userIds, Long modifiedByUserId) {
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

  // Used for displaying a red dot notification on the SMS Inbox
  private void addSmsUserReplyNotification(Long userId, Long smsTeamId, Set<Long> userIds, Long modifiedByUserId) {
    if (userIds.isEmpty()) {
      return;
    }

    notificationService.createNotification(
      new CreateNotificationDto()
        .setTopic(NotificationTopic.SMS_REPLY)
        .setTitle("New SMS message from user")
        .setBody("")
        .setPriority(1)
        .setMetadata(Map.of("userId", userId, "smsTeamId", smsTeamId)),
      userIds,
      modifiedByUserId);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a User conversation
  public void addSmsUserOwnershipNotification(Long userId, Long modifiedByUserId) {
    SmsConversation ump = getUser(userId, modifiedByUserId);
    addSmsUserOwnershipNotification(ump, modifiedByUserId);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a User conversation
  private void addSmsUserOwnershipNotification(SmsConversation ump, Long modifiedByUserId) {
    //      todo solve this
//    final List<Long> teamIds = ump.getSmsTeamOwners().stream().map(SmsTeam::getId).toList();
//    final List<SmsTeam> teamUsers = getTeamUsers(ump.getCompanyId(), teamIds);
//
//    for (SmsTeam smsTeamDetails : teamUsers) {
//      List<Long> smsTeamUserIds =
//        smsTeamDetails.getUsers().stream().map(SmsTeamUser::getUserId).toList();
//
//      if (!smsTeamUserIds.isEmpty()) {
//        addSmsUserOwnershipNotification(
//          ump.getUserId(), smsTeamDetails.getId(), new HashSet<>(smsTeamUserIds), modifiedByUserId);
//      }
//    }
  }

  private void addSmsUserOwnershipNotification(Long userId, Long smsTeamId, Set<Long> userIdsToNotify, Long modifiedByUserId) {
    // Add notification for the current user so their data gets refreshed
    userIdsToNotify.add(modifiedByUserId);

    for (Long userIdToNotify : userIdsToNotify) {
      pubSubService.publish(EventChannel.NOTIFICATION, new NotificationEventMessage()
        .setUserId(userIdToNotify)
        .setTitle("Ownership has changed for this user")
        .setNotificationTopic(NotificationTopic.SMS_OWNERSHIP)
        .setBody("")
        .setPriority(1)
        .setMetadata(Map.of("userId", userId, "smsTeamId", smsTeamId))
      );
    }
  }

  public void addProjectDefaultTeam(List<Long> projectIds, Long modifiedByUserId) {
    for (Long projectId : projectIds) {
      Optional<SmsConversation> conversationMessageProps =
        sqlCache.getBySql(
          MessagingQuery.getProject,
          Map.of("projectId", projectId),
          new MessagePropertiesMapper<>(SmsConversation.class, om));

      // Check if Project exists
      if (conversationMessageProps.isPresent()) {
        SmsConversation projectMessage = conversationMessageProps.get();
        // Check is the project has any sms owners
        //      todo solve this
//        if (projectMessage.getSmsTeamOwners().isEmpty()) {
//          updateProjectStatus(projectId, false, modifiedByUserId);
//          Optional<Long> teamId = getDefaultTeamId(projectMessage.getCompanyId());
//          teamId.ifPresent(aLong -> addTeamForProject(projectId, aLong, null, true, modifiedByUserId));
//        }
      } else {
        // If the project has not had a conversation, start it
        sqlCache.updateBySql(
          MessagingQuery.insertProject,
          Map.of("projectId", projectId, "createdById", modifiedByUserId));
//        TODO: how do i know which company to use?
//        TODO: don't hardcode this to BR
        Optional<Long> teamId = getDefaultTeamId(SystemSettings.BR_SYSTEM_USER.getCompanyId());
        teamId.ifPresent(aLong -> addTeamForProject(projectId, aLong, null, true, modifiedByUserId));
      }
    }
  }

  public void addUserDefaultTeam(List<Long> userIds, Long modifiedByUserId) {
    for (Long userId : userIds) {
      Optional<SmsConversation> userMessageProps =
        sqlCache.getBySql(
          MessagingQuery.getUser,
          Map.of("userId", userId),
          new MessagePropertiesMapper<>(SmsConversation.class, om));

      // Check if Project exists
      if (userMessageProps.isPresent()) {
        SmsConversation userMessage = userMessageProps.get();
        // Check is the project has any sms owners
        //      todo solve this
//        if (userMessage.getSmsTeamOwners().isEmpty()) {
//          updateUserStatus(userId, false, modifiedByUserId);
//          Optional<Long> teamId = getDefaultTeamId(userMessage.getCompanyId());
//          teamId.ifPresent(aLong -> addTeamForUser(userId, aLong, null, true, modifiedByUserId));
//        }
      } else {
        // If the User has not had a conversation, start it
        sqlCache.updateBySql(
          MessagingQuery.insertUser,
          Map.of("userId", userId, "createdById", modifiedByUserId));

        Long companyId = getUserCompanyId(userId);
        Optional<Long> teamId = getDefaultTeamId(companyId);
        teamId.ifPresent(aLong -> addTeamForUser(userId, aLong, null, true, modifiedByUserId));
      }
    }
  }

  private Long getUserCompanyId(Long userId) {
    return sqlCache.queryForObjectBySql(SmsTeamQuery.getUserCompany, Map.of("id", userId), Long.class);
  }

  private Optional<Long> getDefaultTeamId(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);

    return sqlCache.getBySql(
      SmsTeamQuery.getDefaultTeamId, params, new SingleColumnRowMapper<>(Long.class));
  }

  private List<SmsTeam> getTeamsForUser(@NonNull User user) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.isParentCompany());
    params.put("userId", user.getId());

    return sqlCache
      .queryBySql(
        SmsTeamQuery.getTeamsForUser,
        params,
        new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om))
      .stream()
      .filter(u -> !u.getUsers().isEmpty())
      .toList();
  }

  public List<SmsTeam> getTeamsForProject(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    return sqlCache.queryBySql(MessagingQuery.getSmsTeamsForProject, params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  public List<SmsTeam> getTeamsForUserConversation(Long userId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    return sqlCache.queryBySql(MessagingQuery.getSmsTeamsForUserConversation, params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  @Transactional
  public void deleteProjectConversation(Long projectId, Long modifiedByUserId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("modifiedById", modifiedByUserId);

    sqlCache.updateBySql(MessagingQuery.removeAllProjectTeamOwners, params);
    sqlCache.updateBySql(MessagingQuery.removeAllProjectTeams, params);
    sqlCache.updateBySql(MessagingQuery.deleteProjectConversation, params);

    try {
      markSmsProjectNotificationsAsRead(null, projectId, null, modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }
  }

  private List<SmsTeam> getTeamUsers(Long companyId, List<Long> teamIds) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("ids", teamIds);

    if (teamIds == null || teamIds.isEmpty()) {
      return List.of();
    }

    return sqlCache
      .queryBySql(SmsTeamQuery.getTeamUsers, params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  private List<SmsTeam> getTeamsUnassignedNotificationUsers(List<Long> teamIds) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ids", teamIds);

    if (teamIds == null || teamIds.isEmpty()) {
      return List.of();
    }

    return sqlCache
      .queryBySql(SmsTeamQuery.getTeamNotificationUsers, params, new SmsTeamService.SmsTeamMapper<>(SmsTeam.class, om));
  }

  private void markSmsProjectNotificationsAsRead(Long userId, Long projectId, Long smsTeamId, @NonNull Long modifiedByUserId)
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
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markProjectSmsAsReadForUser, params);
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
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markProjectSmsAsReadForTeam, params);

      userIds =
        sqlCache.queryBySql(
          MessagingQuery.findUserByForProjectTeam, params, new SingleColumnRowMapper<>(Long.class));

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
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markSmsAsReadForProject, params);

      userIds =
        sqlCache.queryBySql(
          MessagingQuery.findUserByForProject, params, new SingleColumnRowMapper<>(Long.class));

      log.debug(
        "[Messaging] Marked {} records as read for projectId={}", updatedRecords, projectId);
    }

    // make sure user notification cache is up-to-date
    clearUserCache(userIds);
  }

  private void markSmsUserNotificationsAsRead(Long ownerUserId, Long userId, Long smsTeamId, @NonNull Long modifiedByUserId)
    throws SQLException {

    int updatedRecords;
    final Long SMS_REPLY_NOTIFICATION_TOPIC_ID = 2L;

    final Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", modifiedByUserId);
    params.put("userId", userId);
    params.put("notificationTopicId", SMS_REPLY_NOTIFICATION_TOPIC_ID);
    params.put("ownerUserId", ownerUserId);
    params.put("smsTeamId", smsTeamId);

    List<Long> userIds;

    if (ownerUserId != null) {
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markUserSmsAsReadForUser, params);
      userIds = List.of(ownerUserId);

      Notification notification =
        new Notification()
          .setTopic(NotificationTopic.SMS_REPLY)
          .setTitle("Notification read")
          .setBody("")
          .setPriority(1)
          .setUserId(ownerUserId);

      pubSubService.publish(EventChannel.NOTIFICATION, NotificationEventMessage.from(notification));

      log.debug("[Messaging] Marked {} records as read for user={}", updatedRecords, ownerUserId);
    } else if (smsTeamId != null) {
      userIds =
        sqlCache.queryBySql(
          MessagingQuery.findUserByForUserTeam, params, new SingleColumnRowMapper<>(Long.class));

      updatedRecords = sqlCache.updateBySql(MessagingQuery.markUserSmsAsReadForTeam, params);

      for (Long removedUserId : userIds) {
        Notification notification =
          new Notification()
            .setTopic(NotificationTopic.SMS_REPLY)
            .setTitle("Notification read")
            .setBody("")
            .setPriority(1)
            .setUserId(removedUserId);

        pubSubService.publish(EventChannel.NOTIFICATION, NotificationEventMessage.from(notification));
      }

      log.debug(
        "[Messaging] Marked {} records as read for smsTeamId={}", updatedRecords, smsTeamId);
    } else {
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markSmsAsReadForUser, params);

      userIds =
        sqlCache.queryBySql(
          MessagingQuery.findUserByForUser, params, new SingleColumnRowMapper<>(Long.class));

      log.debug(
        "[Messaging] Marked {} records as read for userId={}", updatedRecords, userId);
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
      TypeReference<List<SmsProject>> projectsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "projects",
        new JsonCollectionDeserializer(projectsRef, objectMapper));

      TypeReference<List<SmsOwner>> ownerRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class, "conversationOwners", new JsonCollectionDeserializer(ownerRef, objectMapper));
    }
  }
}
