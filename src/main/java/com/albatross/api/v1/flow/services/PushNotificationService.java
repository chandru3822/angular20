package com.albatross.api.v1.flow.services;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class PushNotificationService {

  private final FirebaseMessaging messaging;

  public void sendNotificationToTopic(String title, String body) throws FirebaseMessagingException {
    Message message = Message.builder()
      .putData("score", "854")
      .setTopic("test")
      .build();

//    FirebaseMessaging.getInstance(app).subscribeToTopic(List.of("123"), "test");
    String response = messaging.send(message);

    log.info("SENT MESSAGE: {}", response);
  }
}