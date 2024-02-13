package com.albatross.api.config;


import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

@Slf4j
@Configuration
@ConditionalOnProperty(prefix = "app.firebase", value = "credentials")
@RequiredArgsConstructor
public class FirebaseConfig {

  private final AppProperties appProperties;

  @Bean
  public FirebaseApp getFirebaseApp() {
    try (InputStream serviceAccount = new ByteArrayInputStream(appProperties.getFirebase().getCredentials().getBytes())) {
      FirebaseOptions firebaseOptions = FirebaseOptions.builder()
        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
        .build();
      return FirebaseApp.initializeApp(firebaseOptions);
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  @Bean
  public FirebaseMessaging getPushNotificationConfig(FirebaseApp firebaseApp) {
    return FirebaseMessaging.getInstance(firebaseApp);
  }
}
