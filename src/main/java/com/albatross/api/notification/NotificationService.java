package com.albatross.api.notification;

import com.albatross.api.notification.model.CreateNotificationDto;
import com.albatross.api.notification.model.Notification;
import com.albatross.api.notification.model.NotificationEventMessage;
import com.albatross.api.notification.model.NotificationMapper;
import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.Subscriber;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.services.SqlArrayService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

  private final SqlCache sqlCache;
  private final PubSubService pubSubService;
  private final SqlArrayService sqlArrayService;
  private final NamedParameterJdbcTemplate jdbcTemplate;
  private final ObjectMapper objectMapper;

  /**
   * Creates a notification (i.e. stores a record in the database) and sends out a pubsub event in
   * case they are currently listening:
   *
   * <p>Usage:
   *
   * <pre>
   * notificationService.createNotification(
   *   new CreateNotificationDto()
   *      .setTopic(NotificationTopic.SMS_REPLY)
   *      .setTitle("Important Message")
   *      .setBody("This message contains something very important")
   *      .setPriority((int) (Math.random() * 100))
   *      .setMetadata(Map.of("id", 8675309L)),
   *      2417173L,
   *      2417173L
   * );
   *
   * </pre>
   *
   * @param notification
   * @return Notification
   */
  @Transactional
  public Notification createNotification(
      CreateNotificationDto notification, @NonNull Long userId, @NonNull Long createdById) {

    final List<Notification> notifications =
        createNotification(notification, Set.of(userId), createdById);
    return notifications.isEmpty() ? null : notifications.get(0);
  }

  /**
   * Usage:
   *
   * <pre>
   * notificationService.createNotification(
   *   new CreateNotificationDto()
   *      .setTopic(NotificationTopic.SMS_REPLY)
   *      .setTitle("Important Message")
   *      .setBody("This message contains something very important")
   *      .setPriority((int) (Math.random() * 100))
   *      .setMetadata(Map.of("id", 8675309L)),
   *      Set.of(2417173L, 2422383L, 2350555L, 2417164L, 2417170L),
   *      2417173L
   * );
   *
   * </pre>
   *
   * @param notification
   * @param userIds
   * @param createdById
   * @return
   */
  @Transactional
  public List<Notification> createNotification(
      CreateNotificationDto notification, Set<Long> userIds, @NonNull Long createdById) {

    // note: keeping sql here because we are using a prepared statement directly which requires ?
    // placeholders
    final String sql =
        "insert into flow.notification (user_id, notification_topic_id, title, body, priority, metadata, created_by_id, modified_by_id) values (?, ?, ?, ?, ?, ?, ?, ?)";

    final DataSource dataSource = jdbcTemplate.getJdbcTemplate().getDataSource();

    if (dataSource != null) {
      try (Connection connection = dataSource.getConnection();
          PreparedStatement ps =
              connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

        for (Long userId : userIds) {
          ps.setLong(1, userId);
          ps.setInt(2, notification.getNotificationTopicId());
          ps.setString(3, notification.getTitle());
          ps.setString(4, notification.getBody());
          ps.setInt(5, notification.getPriority());
          if (notification.getMetadata() != null) {
            final PGobject pgObject = new PGobject();
            pgObject.setType("jsonb");
            pgObject.setValue(objectMapper.writeValueAsString(notification.getMetadata()));

            ps.setObject(6, pgObject);
          } else {
            ps.setObject(6, null);
          }
          ps.setLong(7, createdById);
          ps.setLong(8, createdById);

          ps.addBatch();
        }

        ps.executeBatch();

        final ResultSet generatedKeys = ps.getGeneratedKeys();
        final ArrayList<Long> insertedIds = new ArrayList<>();

        while (generatedKeys.next()) {
          final long id = generatedKeys.getInt("id");
          insertedIds.add(id);
        }

        if (!insertedIds.isEmpty()) {
          final Array idsSqlArray = sqlArrayService.createSqlArrayOfType("bigint", insertedIds);
          final List<Notification> notifications =
              sqlCache.query(
                  "notification.findByIds",
                  Map.of("ids", idsSqlArray),
                  new NotificationMapper(this.objectMapper));

          notifications.stream()
              .map(NotificationEventMessage::from)
              .forEach(notify -> pubSubService.publish(EventChannel.NOTIFICATION, notify));

          return notifications;
        }
      } catch (SQLException | JsonProcessingException e) {
        log.error("[Notifications] Error while doing a bulk insert", e);
      }
    }

    return List.of();
  }

  public Page<Notification> getUserNotifications(@NonNull Long userId, Pageable pageable) {
    final Map<String, Object> params =
        Map.of("userId", userId, "limit", pageable.getPageSize(), "offset", pageable.getOffset());

    final List<Notification> notifications =
        sqlCache.query(
            "notification.getUnreadByUser", params, new NotificationMapper(this.objectMapper));

    final Long count =
        sqlCache
            .get(
                "notification.getUnreadByUser.count",
                params,
                new SingleColumnRowMapper<>(Long.class))
            .orElse((long) notifications.size());

    return new PageImpl<>(
        notifications, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  @Async
  public void sendUserCatchupNotifications(
      Subscriber subscriber, @NonNull Long userId, @NonNull Long afterId) {
    final List<Notification> catchupNotifications =
        sqlCache.query(
            "notification.getUnreadByUserAfterId",
            Map.of("userId", userId, "afterId", afterId),
            new NotificationMapper(this.objectMapper));

    log.debug("[Notifications] User is behind {} Notifications", catchupNotifications.size());

    catchupNotifications.stream()
        .map(NotificationEventMessage::from)
        .filter(subscriber::acceptsEventMessage)
        .forEach(notification -> pubSubService.notify(subscriber, notification));
  }

  @Transactional
  public void markUserNotificationsAsRead(@NonNull Long userId, List<Long> notificationIds)
      throws SQLException {
    if (notificationIds == null || notificationIds.isEmpty()) {
      return;
    }
    final Array ids = sqlArrayService.createSqlArrayOfType("bigint", notificationIds);
    final int updatedRecords =
        sqlCache.update(
            "notification.markAsRead",
            Map.of("userId", userId, "modifiedById", userId, "ids", ids));
    log.debug("[Notifications] Marked {} records as read for user={}", updatedRecords, userId);
  }
}
