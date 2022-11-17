package com.albatross.api.v1.flow.model.smsQueue;

import com.fasterxml.jackson.core.JacksonException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class TwilioMessageRequestDeserializer extends StdDeserializer<TwilioMessageRequest> {

  public TwilioMessageRequestDeserializer() {
    this(null);
  }

  public TwilioMessageRequestDeserializer(Class<?> vc) {
    super(vc);
  }

  @Override
  public TwilioMessageRequest deserialize(JsonParser jsonParser, DeserializationContext deserializationContext) throws IOException, JacksonException {
    final JsonNode node = jsonParser.getCodec().readTree(jsonParser);

    final String numMedia = node.get("NumMedia").textValue();
    final int totalNumMedia = numMedia == null ? 0 : Integer.parseInt(numMedia);

    // why twilio, why?
    List<String> mediaUrls = new ArrayList<>();
    for (var i = 0; i < totalNumMedia; i++) {
      mediaUrls.add(node.get("MediaUrl%s".formatted(i)).textValue());
    }

    return TwilioMessageRequest.builder()
      .messageSid(node.get("MessageSid").textValue())
      .smsSid(node.get("SmsSid").textValue())
      .accountSid(node.get("AccountSid").textValue())
      .messagingServiceSid(node.get("MessagingServiceSid").textValue())
      .from(node.get("From").textValue())
      .to(node.get("To").textValue())
      .body(node.get("Body").textValue())
      .numMedia(totalNumMedia)
      .mediaUrls(mediaUrls)
      .build();
  }
}
