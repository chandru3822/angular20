package com.albatross.api.pubsub.config;

import com.albatross.api.pubsub.model.EventChannel;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.listener.adapter.MessageListenerAdapter;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;

import java.util.Arrays;
import java.util.List;

@Configuration
public class RedisTemplateConfig {

  @Bean
  public RedisTemplate<String, Object> redisTemplate(
      RedisConnectionFactory redisConnectionFactory) {
    final var redisTemplate = new RedisTemplate<String, Object>();
    redisTemplate.setConnectionFactory(redisConnectionFactory);
    redisTemplate.setValueSerializer(new GenericJackson2JsonRedisSerializer());

    return redisTemplate;
  }

  @Bean
  public MessageListenerAdapter messageListenerAdapter(
      RealTimeEventMessageListener realTimeEventMessageListener) {
    return new MessageListenerAdapter(realTimeEventMessageListener);
  }

  @Bean
  public RedisMessageListenerContainer redisContainer(
      RedisConnectionFactory redisConnectionFactory,
      MessageListenerAdapter messageListenerAdapter) {
    final var container = new RedisMessageListenerContainer();
    container.setConnectionFactory(redisConnectionFactory);

    final List<ChannelTopic> channelTopics =
        Arrays.stream(EventChannel.values())
            .map(topic -> new ChannelTopic(topic.getName()))
            .toList();
    container.addMessageListener(messageListenerAdapter, channelTopics);
    return container;
  }
}
