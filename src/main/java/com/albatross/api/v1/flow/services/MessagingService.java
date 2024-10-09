package com.albatross.api.v1.flow.services;

import com.albatross.api.config.CachingConfig;
import com.albatross.api.config.PropertiesConfiguration;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.convert.JsonObjectDeserializer;
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
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.smsTeam.SmsConversation;
import com.albatross.api.v1.flow.model.smsQueue.TwilioMessageRequest;
import com.albatross.api.v1.flow.model.smsTeam.SmsOwner;
import com.albatross.api.v1.flow.model.smsTeam.SmsSource;
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
  private final PropertiesConfiguration properties;
  private final SqlArrayService sqlArrayService;

  public Long getThreadId(Long projectId, Long userId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("userId", userId);

    String fromPhone = projectId != null
      ? properties.getTwilioPhoneNumber() : properties.getTwilioInternalPhoneNumber();
    params.put("fromPhoneNumber", fromPhone);

    Long threadId = sqlCache.queryForObjectBySql(SmsServiceQuery.getThreadId, params, Long.class);
    return threadId;
  }

  public SmsConversation getThread(Long smsThreadId, Long projectId, Long userId, Long modifiedByUserId) {
    Long threadId = smsThreadId;

    if(threadId == null) {
      //you should never get projectId AND userId so this should work
      threadId = getThreadId(projectId, userId);
    }

    Optional<SmsConversation> conversationMessageProps =
      sqlCache.getBySql(
        MessagingQuery.getThread,
        Map.of("smsThreadId", threadId),
        new MessagePropertiesMapper<>(SmsConversation.class, om));

    // The project conversation hasn't started yet, insert it
//    todo: figure this out from the project screen
//    if (conversationMessageProps.isEmpty()) {
//      sqlCache.updateBySql(
//        MessagingQuery.insertProject,
//        Map.of("projectId", projectId, "createdById", modifiedByUserId));
//
//      conversationMessageProps =
//        sqlCache.getBySql(
//          MessagingQuery.getProject,
//          Map.of("projectId", projectId),
//          new MessagePropertiesMapper<>(SmsConversation.class, om));
//    }

    return conversationMessageProps.orElseThrow(() -> new NotFoundException("Thread conversation not found"));
  }

  public Page<SmsConversation> getConversations(String query, Set<Long> ownerUserIds, Set<Long> smsTeamIds, Set<Long> notifThreadIds,
                                                Boolean showExternal, Boolean showInternal, Boolean showInbox, Boolean sortAscending, Pageable pageable) {
    String cleanedQuery = query;
    if (cleanedQuery != null) {
      cleanedQuery = cleanedQuery.replaceAll("[*,.&]", "")
        .toLowerCase()
        .trim();
    }

    boolean containsUnassigned = false;
    if (ownerUserIds.contains(-1L)) {
      containsUnassigned = true;
      ownerUserIds.remove(-1L);
    }

    final HashMap<String, Object> params = new HashMap<>();
    params.put("query", StringUtils.hasText(cleanedQuery) ? cleanedQuery : null);
    params.put("smsTeamIds", smsTeamIds);
    params.put("ownerIds", ownerUserIds);
    params.put("notifThreadIds", notifThreadIds);
    params.put("unassigned", containsUnassigned);
    params.put("showInbox", showInbox);
    params.put("showInternal", showInternal);
    params.put("showExternal", showExternal);
    params.put("sortAscending", sortAscending);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<SmsConversation> conversations = sqlCache.queryBySql(
      MessagingQuery.getConversations,
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

    int count = 0;
    return new PageImpl<>(
      conversations, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  @Data
  static class ProjectCounter {
    private Long projectId;
    private boolean outboundMessage;
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

  private void updateThreadClosedValue(Long threadId, Boolean closed, @NonNull Long modifiedByUserId) {
    Map<String, Object> params = new HashMap<>();
    params.put("smsThreadId", threadId);
    params.put("closed", closed);

    sqlCache.updateBySql(MessagingQuery.updateThreadClosedValue, params);
  }

  @Data
  public static class TeamCreationData {
    private Boolean clearUnassigned;
    private List<Integer> newlySelectedUserIds;
  }

  public void addSmsTeam(
    Long smsThreadId, Long projectId, Long userId, Long teamId, List<SmsTeamUser> ownersSelected, boolean defaultTeamAdded, Long modifiedByUserId){

    Long threadId;
    if(smsThreadId == null) {
      threadId = getThreadId(projectId, userId);
    } else {
      threadId = smsThreadId;
    }

    List<Long> selectedUserIds = new ArrayList<>();
    if(null != ownersSelected && !ownersSelected.isEmpty()) {
      selectedUserIds = ownersSelected.stream()
        .map(SmsTeamUser::getUserId)
        .collect(Collectors.toList());
    }

    Map<String, Object> params = new HashMap<>();
    params.put("threadId", threadId);
    params.put("teamId", teamId);
    params.put("currentUserId", modifiedByUserId);
    try {
      params.put("selectedUserIds", sqlArrayService.createSqlArrayOfType("bigint", selectedUserIds));
    } catch (SQLException e) {
      throw new RuntimeException(e);
    }

    //try and do all the stuff this java function used to do for team creation but in a db function
    TeamCreationData teamCreationData = sqlCache.getBySql(MessagingQuery.handleSmsTeamCreation, params,  new TeamCreationDataMapper<>(TeamCreationData.class, om)).get();

    List<Long> ownerUserIds = new ArrayList<>();
    List<Long> unassignedUserIds = new ArrayList<>();

    if (teamCreationData.newlySelectedUserIds != null && !teamCreationData.newlySelectedUserIds.isEmpty()) {
      // If a User joined via a previously Unassigned team - clear notifications for any user(s)
      // that receive unassigned notifications
      if (teamCreationData.clearUnassigned) {
        final List<SmsTeam> unassignedSmsTeams = getTeamsUnassignedNotificationUsers(List.of(teamId));
        for (SmsTeam smsTeam : unassignedSmsTeams) {
          List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
          for (User user : usersToNotify) {
            List<Notification> notifications = notificationService.getThreadNotificationsForUser(user.getId());
            List<Long> notificationIds = notifications.stream()
              .filter(n -> (Long.valueOf((Integer) n.getMetadata().get("threadId"))).equals(threadId))
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
             insert into flow.sms_thread_owner
              (sms_thread_id, sms_team_id, user_id, created_by_id, date_created, modified_by_id, date_modified)
              values (?, ?, ?, ?, now(), ?, now())
        """;

      final DataSource dataSource = jdbc.getJdbcTemplate().getDataSource();
      if (dataSource != null) {
        try (final Connection connection = dataSource.getConnection();
             final PreparedStatement ps = connection.prepareStatement(insertOwnerSql)) {

          // Insert each of the SMS Team's Users so they are associated with the thread
          for (Integer ownerUserId : teamCreationData.newlySelectedUserIds) {
            if (ownerUserIds.contains(ownerUserId.longValue())) {
              //prevent double add
              continue;
            }

            ownerUserIds.add(ownerUserId.longValue());

            ps.setLong(1, threadId);
            ps.setLong(2, teamId);
            ps.setLong(3, ownerUserId.longValue());
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

    //dont add thread notifications when a user joins a thread. we treat all current messages as "Read" and only anything that comes in after the user is already on the team will affect the red notification badge count
//    addSmsThreadReplyNotification(threadId, teamId, userIdsToNotify, modifiedByUserId);

    addSmsThreadOwnershipNotificationForUserList(threadId, teamId, userIdsToNotify, modifiedByUserId);

    SmsConversation conversationMessageProps = getThread(threadId, null,null, modifiedByUserId);

    // Check if Project is closed, if so open it - unless the default team is being added
    // automatically
    if (!defaultTeamAdded
        && conversationMessageProps.isClosed()) {
      updateThreadClosedValue(threadId, false, modifiedByUserId);
    }
  }

  public void removeThreadTeam(Long smsThreadId, Long projectId, Long userId, Long smsTeamId, Long modifiedByUserId) {
    Long threadId = smsThreadId;

    if(threadId == null) {
      //you should never get projectId AND userId so this should work
      threadId = getThreadId(projectId, userId);
    }

    // Insert the SMS team to associate it with the project
    Map<String, Object> params = new HashMap<>();
    params.put("threadId", threadId);
    params.put("smsTeamId", smsTeamId);
    params.put("modifiedById", modifiedByUserId);

    sqlCache.updateBySql(MessagingQuery.removeEntireThreadTeam, params);

    try {
      markSmsThreadNotificationsAsRead(threadId, null, projectId, smsTeamId, modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    SmsConversation cmp = getThread(threadId, null, null, modifiedByUserId);
    // Check if Thread is open and the final team was removed, if so close the project
    if (cmp.getSmsTeamOwners().isEmpty() && !cmp.isClosed()) {
      updateThreadClosedValue(threadId, true, modifiedByUserId);
    }

    addSmsThreadOwnershipNotification(cmp, modifiedByUserId);
  }

  public String getThreadHistory(Long smsThreadId, Long projectId, Long userId) {
    Long threadId = smsThreadId;

    if(threadId == null) {
      //you should never get projectId AND userId so this should work
      threadId = getThreadId(projectId, userId);
    }

    return jdbc.queryForObject(MessagingQuery.getThreadHistory, Map.of("threadId", threadId), String.class);
  }

  public void closeStaleThreads(Long modifiedByUserId) {
    List<Long> parentThreadIds =
      sqlCache.queryBySql(MessagingQuery.getStaleThreads, null, new SingleColumnRowMapper<>(Long.class));

    for (Long threadId : parentThreadIds) {
      removeAllTeamsFromThread(threadId, null, null, modifiedByUserId);
    }
  }

  public void removeAllTeamsFromThread(Long smsThreadId, Long projectId, Long userId, Long modifiedByUserId) {
    Long threadId = smsThreadId;

    if(threadId == null) {
      //you should never get projectId AND userId so this should work
      threadId = getThreadId(projectId, userId);
    }

    Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", modifiedByUserId);
    params.put("threadId", threadId);
    sqlCache.updateBySql(MessagingQuery.removeAllThreadTeams, params);
  }

  @Transactional
  public void removeThreadOwner(Long smsThreadId, Long projectId, Long userId, SmsThreadOwner owner, Long modifiedByUserId) {
    Long threadId = smsThreadId;

    if(threadId == null) {
      //you should never get projectId AND userId so this should work
      threadId = getThreadId(projectId, userId);
    }

    Map<String, Object> params = new HashMap<>();
    params.put("threadId", threadId);
    params.put("userId", owner.getUserId());
    params.put("smsTeamId", owner.getSmsTeamId());
    params.put("modifiedById", modifiedByUserId);


    sqlCache.updateBySql(MessagingQuery.removeThreadOwner, params);

    try {
      markSmsThreadNotificationsAsRead(threadId, owner.getUserId(), projectId, owner.getSmsTeamId(), modifiedByUserId);
    } catch (SQLException e) {
      log.error("MESSAGE: Error marking SMS notifications as read {}", e.getMessage());
    }

    addSmsThreadOwnershipNotification(threadId, null, null, modifiedByUserId);
  }

  private void updateThreadOwnerHistory(
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
    String cleanExternalPhoneNumber = sms.getFrom().replaceAll("[^0-9]", "");
    if(cleanExternalPhoneNumber.startsWith("1")) {
      cleanExternalPhoneNumber = cleanExternalPhoneNumber.substring(1);
    }

    String cleanInternalPhoneNumber = sms.getTo().replaceAll("[^0-9]", "");
    if(cleanInternalPhoneNumber.startsWith("1")) {
      cleanInternalPhoneNumber = cleanInternalPhoneNumber.substring(1);
    }

    List<Long> threadIds =
      sqlCache.queryBySql(
        SmsServiceQuery.getThreads,
        Map.of("externalPhoneNumber", cleanExternalPhoneNumber, "internalPhoneNumber", cleanInternalPhoneNumber),
        new SingleColumnRowMapper<>(Long.class));

    if (!threadIds.isEmpty()) {
      // For any Project that is closed and has no teams assigned, open the project and assign the
      // default team
      addThreadDefaultTeam(threadIds, SystemSettings.SYSTEM_USER.getId());

      for (Long threadId : threadIds) {

//      TODO: can we batch this call?
        // Get the list of the Users who are set to be notified for this project
        List<SmsTeamUser> ownerUsers =
          sqlCache.queryBySql(
            MessagingQuery.getOwnerUsersForThread, Map.of("threadId", threadId), SmsTeamUser.class);

        // If there are no owners, add unassigned notifications if applicable
        if (ownerUsers.isEmpty()) {
          SmsConversation cmp = getThread(threadId, null, null, SystemSettings.BR_SYSTEM_USER.getId());
          //      todo sms solve this
          final List<Long> teamIds = cmp.getSmsTeamOwners().stream().map(SmsTeam::getId).toList();
          final List<SmsTeam> smsTeams = getTeamsUnassignedNotificationUsers(teamIds);
          for (SmsTeam smsTeam : smsTeams) {
            List<User> usersToNotify = smsTeam.getUnassignedNotificationUsers();
            for (User user : usersToNotify) {
              addSmsThreadReplyNotification(
                threadId, smsTeam.getId(), new HashSet<>(List.of(user.getId())), SystemSettings.SYSTEM_USER.getId());

              addSmsThreadOwnershipNotification(threadId, null, null, SystemSettings.SYSTEM_USER.getId());
            }
          }
        } else {
          for (SmsTeamUser smsTeamUser : ownerUsers) {
            addSmsThreadReplyNotification(
              threadId, smsTeamUser.getSmsTeamId(), null != smsTeamUser.getUserId() ? new HashSet<>(List.of(smsTeamUser.getUserId())) : new HashSet<>(), SystemSettings.SYSTEM_USER.getId());

            addSmsThreadOwnershipNotification(threadId, null, null, SystemSettings.SYSTEM_USER.getId());
          }
        }
      }
    }
  }

  // Used for displaying a red dot notification on the SMS Inbox
  private void addSmsThreadReplyNotification(Long threadId, Long smsTeamId, Set<Long> userIds, Long modifiedByUserId) {
    if (userIds.isEmpty()) {
      return;
    }



    notificationService.createNotification(
      new CreateNotificationDto()
        .setTopic(NotificationTopic.SMS_REPLY)
        .setTitle("New SMS message from customer")
        .setBody("")
        .setPriority(1)
        .setMetadata(Map.of("threadId", threadId, "smsTeamId", smsTeamId)),
      userIds,
      modifiedByUserId);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Thread
  public void addSmsThreadOwnershipNotification(Long smsThreadId, Long projectId, Long userId, Long modifiedByUserId) {
    Long threadId = smsThreadId;

    if(threadId == null) {
      //you should never get projectId AND userId so this should work
      threadId = getThreadId(projectId, userId);
    }

    SmsConversation cmp = getThread(threadId, null, null, modifiedByUserId);
    addSmsThreadOwnershipNotification(cmp, modifiedByUserId);
  }

  // Used for triggering a data refresh on the SMS Inbox screen for all owners of a Thread
  private void addSmsThreadOwnershipNotification(SmsConversation cmp, Long modifiedByUserId) {
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

  private void addSmsThreadOwnershipNotificationForUserList(Long threadId, Long smsTeamId, Set<Long> userIds, Long modifiedByUserId) {
    // Add notification for the current user so their data gets refreshed
    userIds.add(modifiedByUserId);

    for (Long userId : userIds) {
      pubSubService.publish(EventChannel.NOTIFICATION, new NotificationEventMessage()
        .setUserId(userId)
        .setTitle("Ownership has changed for this thread")
        .setNotificationTopic(NotificationTopic.SMS_OWNERSHIP)
        .setBody("")
        .setPriority(1)
        .setMetadata(Map.of("threadId", threadId, "smsTeamId", smsTeamId))
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
    SmsConversation ump = getThread(null, null, userId, modifiedByUserId);
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

  public void addThreadDefaultTeam(List<Long> threadIds, Long modifiedByUserId) {
    for (Long threadId : threadIds) {
      Optional<SmsConversation> conversationMessageProps =
        sqlCache.getBySql(
          MessagingQuery.getThread,
          Map.of("smsThreadId", threadId),
          new MessagePropertiesMapper<>(SmsConversation.class, om));

      // Check if Thread exists
      if (conversationMessageProps.isPresent()) {
        SmsConversation thread = conversationMessageProps.get();
        // Check is the thread has any sms owners
        if (thread.getSmsTeamOwners().isEmpty()) {
          updateThreadClosedValue(threadId, false, modifiedByUserId);
          //todo sms figure out if sms can even work for multiple companies, then un-hardcode this
          Long companyId = 3L;
          Optional<Long> teamId = getDefaultTeamId(companyId);
          teamId.ifPresent(aLong -> addSmsTeam(threadId, null, null, aLong, null, true, modifiedByUserId));
        }
      }
    }
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

  @Transactional
  public void closeThreadConversation(Long smsThreadId, Long projectId, Long userId, Long modifiedByUserId) {
    Long threadId = smsThreadId;

    if(threadId == null) {
      //you should never get projectId AND userId so this should work
      threadId = getThreadId(projectId, userId);
    }

    Map<String, Object> params = new HashMap<>();
    params.put("threadId", threadId);
    params.put("modifiedById", modifiedByUserId);

    removeAllTeamsFromThread(threadId, null, null, modifiedByUserId);
    sqlCache.updateBySql(MessagingQuery.closeThread, params);

    try {
      markSmsThreadNotificationsAsRead(threadId, null, null, null, modifiedByUserId);
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

  public void markSmsThreadNotificationsAsRead(Long threadId, Long userId, Long projectId, Long smsTeamId, @NonNull Long modifiedByUserId)
    throws SQLException {

    int updatedRecords;
    final Long SMS_REPLY_NOTIFICATION_TOPIC_ID = 2L;

    final Map<String, Object> params = new HashMap<>();
    params.put("modifiedById", modifiedByUserId);
    params.put("threadId", threadId);
    params.put("notificationTopicId", SMS_REPLY_NOTIFICATION_TOPIC_ID);
    params.put("userId", userId);
    params.put("smsTeamId", smsTeamId);

    List<Long> userIds;

    if (userId != null) {
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markThreadSmsAsReadForUser, params);
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
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markThreadSmsAsReadForTeam, params);

      userIds =
        sqlCache.queryBySql(
          MessagingQuery.findUserByForThreadTeam, params, new SingleColumnRowMapper<>(Long.class));

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
      updatedRecords = sqlCache.updateBySql(MessagingQuery.markSmsAsReadForThread, params);

      userIds =
        sqlCache.queryBySql(
          MessagingQuery.findUserByForThread, params, new SingleColumnRowMapper<>(Long.class));

      log.debug(
        "[Messaging] Marked {} records as read for threadId={}", updatedRecords, threadId);
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

  public static class TeamCreationDataMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public TeamCreationDataMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Integer>> newlySelectedUserIdsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "newlySelectedUserIds",
        new JsonObjectDeserializer<>(newlySelectedUserIdsRef, objectMapper));
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
      TypeReference<List<SmsSource>> sourcesRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "sources",
        new JsonCollectionDeserializer(sourcesRef, objectMapper));

      TypeReference<List<SmsOwner>> ownerRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class, "conversationOwners", new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<List<SmsTeam>> teamRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class, "smsTeamOwners", new JsonCollectionDeserializer(teamRef, objectMapper));
    }
  }
}
