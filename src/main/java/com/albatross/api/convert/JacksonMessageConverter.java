package com.albatross.api.convert;

import com.github.sonus21.rqueue.converter.MessageConverterProvider;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.converter.MessageConverter;

public final class JacksonMessageConverter implements MessageConverterProvider {
  @Override
  public MessageConverter getConverter() {
    return new MappingJackson2MessageConverter();
  }
}
