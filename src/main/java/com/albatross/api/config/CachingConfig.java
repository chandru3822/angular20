package com.albatross.api.config;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.github.benmanes.caffeine.cache.Caffeine;
import com.github.benmanes.caffeine.cache.LoadingCache;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.cache.RedisCacheManagerBuilderCustomizer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;

import java.time.Duration;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

@Configuration
@EnableCaching
public class CachingConfig {
  public static final String PROPOSAL_TEMPLATE = "proposalTemplate";
  public static final String NOTIFICATION = "notification";
  public static final String ATTACHMENT = "attachment";

  @Bean
  public RedisCacheManagerBuilderCustomizer redisCacheManagerBuilderCustomizer() {
    return builder -> {
      builder
        .withCacheConfiguration(
          PROPOSAL_TEMPLATE,
          RedisCacheConfiguration.defaultCacheConfig()
            .serializeValuesWith(
              RedisSerializationContext.SerializationPair.fromSerializer(
                new GenericJackson2JsonRedisSerializer()))
            .entryTtl(Duration.ofMinutes(5L)))
        .withCacheConfiguration(
          NOTIFICATION,
          RedisCacheConfiguration.defaultCacheConfig()
            .serializeValuesWith(
              RedisSerializationContext.SerializationPair.fromSerializer(
                new GenericJackson2JsonRedisSerializer()))
            .entryTtl(Duration.ofMinutes(5L)))
        .withCacheConfiguration(
          ATTACHMENT,
          RedisCacheConfiguration.defaultCacheConfig()
            .serializeValuesWith(
              RedisSerializationContext.SerializationPair.fromSerializer(
                new GenericJackson2JsonRedisSerializer()))
            .entryTtl(Duration.ofHours(24L)));
    };
  }

  @Bean
  public LoadingCache<Object, Optional<UserAccountDetails>> caffeineCache(@Autowired final SecurityService securityService) {
    return Caffeine.newBuilder()
      .maximumSize(500)
      .expireAfterWrite(1, TimeUnit.MINUTES)
      .recordStats()
      .build(key -> securityService.getUserDetailsById((Long) key))
      ;
  }
}
