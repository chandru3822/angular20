package com.albatross.api.pubsub.config;

import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.IEventMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.RedisSerializer;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class RealTimeEventMessageListener implements MessageListener {
  private final RedisTemplate<String, Object> redisTemplate;
  private final PubSubService pubSubService;

  @Override
  public void onMessage(Message message, byte[] pattern) {
    final RedisSerializer<?> valueSerializer = redisTemplate.getValueSerializer();
    final var eventMessage = (IEventMessage) valueSerializer.deserialize(message.getBody());
    final EventChannel eventChannel = EventChannel.findByName(new String(message.getChannel()));

    log.debug("Message Received={} on Channel={}", eventMessage, eventChannel);
    pubSubService.broadcast(eventChannel, eventMessage);
  }
}
