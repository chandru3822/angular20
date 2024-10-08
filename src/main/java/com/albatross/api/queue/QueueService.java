package com.albatross.api.queue;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.queue.model.Message;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class QueueService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public Message Enqueue(Message message) {
    var userId = securityService.getCurrentUser().trueUserId();
    if (message.getMessageId() != null) {
      Requeue(message);
      return message;
    } else {
      // enqueue
      Map<String, Object> params = new HashMap<>();
      params.put("topic", message.getTopic());
      params.put("payload", message.getPayload());
      params.put("createdBy", userId);
      var newMessage = sqlCache.getBySql(QueueQuery.enqueue, params, new MessageMapper<>(Message.class, om));
      if (newMessage.isPresent()) {
        return newMessage.get();
      } else {
        throw new RuntimeException("boom");
      }
    }
  }

  public Optional<Message> Dequeue(String topic) {
    return sqlCache.getBySql(QueueQuery.dequeue, Map.of("topic", topic), new MessageMapper<>(Message.class, om));
  }

  private Message Requeue(Message message) {
    var userId = securityService.getCurrentUser().trueUserId();

    message.setStatus("retry");

    Map<String, Object> params = new HashMap<>();
    params.put("messageId", message.getMessageId());
    params.put("topic", message.getTopic());
    params.put("payload", message.getPayload());
    params.put("createdBy", userId);
    params.put("status", message.getStatus());
    params.put("attempt", message.getAttempt());
    try {
      var updatedMessage = sqlCache.getBySql(QueueQuery.requeue, params, new MessageMapper<>(Message.class, om));
      if (updatedMessage.isEmpty()) {
        throw new RuntimeException("unable to re-add message to queue");
      }
      return message;
    } catch(DuplicateKeyException e) {
      message.setDateCreated(new Timestamp(new Date().getTime()));
      return message;
    } catch (Exception e) {
      throw new RuntimeException("unable to re-add message to queue");
    }
  }

  public static class MessageMapper<T> extends BeanPropertyRowMapper<T> {
    public final ObjectMapper objectMapper;


    public MessageMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Map<String, Object>> payloadRef = new TypeReference<>() {};
      bw.registerCustomEditor(Map.class, "payload", new JsonCollectionDeserializer(payloadRef, objectMapper));
    }
  }
}
