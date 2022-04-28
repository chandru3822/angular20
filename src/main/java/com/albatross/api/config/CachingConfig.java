package com.albatross.api.config;

import org.springframework.boot.autoconfigure.cache.RedisCacheManagerBuilderCustomizer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.time.Duration;

@Configuration
@EnableCaching
public class CachingConfig {
  public static final String PROPOSAL_TEMPLATE = "proposalTemplate";

  @Bean
  public RedisCacheManagerBuilderCustomizer redisCacheManagerBuilderCustomizer() {
    return builder -> {
      builder.withCacheConfiguration(
          PROPOSAL_TEMPLATE,
          RedisCacheConfiguration.defaultCacheConfig()
              .serializeValuesWith(
                  RedisSerializationContext.SerializationPair.fromSerializer(
                      new GenericJackson2JsonRedisSerializer()))
              .entryTtl(Duration.ofMinutes(5L)));
    };
  }
}
