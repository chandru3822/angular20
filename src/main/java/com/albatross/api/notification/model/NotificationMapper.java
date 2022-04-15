package com.albatross.api.notification.model;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.OffsetDateTime;

@Slf4j
@RequiredArgsConstructor
public class NotificationMapper implements RowMapper<Notification> {
  private final ObjectMapper objectMapper;

  @Override
  public Notification mapRow(ResultSet rs, int rowNum) throws SQLException {
    final Notification notification = new Notification();
    notification.setId(rs.getLong("id"));
    notification.setTitle(rs.getString("title"));
    notification.setBody(rs.getString("body"));
    notification.setPriority(rs.getInt("priority"));
    notification.setUserId(rs.getLong("user_id"));
    notification.setNotificationTopicId(rs.getInt("notification_topic_id"));

    final Timestamp rsTimestamp = rs.getTimestamp("message_read_tsz");
    if (rsTimestamp != null) {
      notification.setMessageReadTsz(OffsetDateTime.from(rsTimestamp.toInstant()));
    }

    final PGobject rsObject = rs.getObject("metadata", PGobject.class);
    if (!rsObject.isNull()) {
      try {
        notification.setMetadata(
            objectMapper.readValue(rsObject.getValue(), new TypeReference<>() {}));
      } catch (JsonProcessingException e) {
        log.error("Error processing json", e);
      }
    }

    return notification;
  }
}
