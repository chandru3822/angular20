package com.albatross.api.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;

@Slf4j
public class FirebaseConfig {

  @Value("${firebase.type}")
  private String firebaseType;

  @Value("${firebase.projectId}")
  private String firebaseProjectId;

  @Value("${firebase.privateKeyId}")
  private String firebasePrivateKeyId;

  @Value("${firebase.privateKey}")
  private String firebasePrivateKey;

  @Value("${firebase.clientEmail}")
  private String firebaseClientEmail;

  @Value("${firebase.clientId}")
  private String firebaseClientId;

  @Value("${firebase.authUri}")
  private String firebaseAuthUri;

  @Value("${firebase.tokenUri}")
  private String firebaseTokenUri;

  @Value("${firebase.authProviderX509CertUrl}")
  private String firebaseAuthProviderX509CertUrl;

  @Value("${firebase.clientX509CertUrl}")
  private String firebaseClientX509CertUrl;

  //  private FirebaseApp firebaseApp;
  //
  //  @PostConstruct
  //  private void init() throws IOException {
  //
  //    JSONObject firebaseCredentials = new JSONObject();
  //    firebaseCredentials.put("type", firebaseType);
  //    firebaseCredentials.put("project_id", firebaseProjectId);
  //    firebaseCredentials.put("private_key_id", firebasePrivateKeyId);
  //    firebaseCredentials.put("private_key", firebasePrivateKey);
  //    firebaseCredentials.put("client_email", firebaseClientEmail);
  //    firebaseCredentials.put("client_id", firebaseClientId);
  //    firebaseCredentials.put("auth_uri", firebaseAuthUri);
  //    firebaseCredentials.put("token_uri", firebaseTokenUri);
  //    firebaseCredentials.put("auth_provider_x509_cert_url", firebaseAuthProviderX509CertUrl);
  //    firebaseCredentials.put("client_x509_cert_url", firebaseClientX509CertUrl);
  //
  //    FirebaseOptions firebaseOptions =
  //        FirebaseOptions.builder()
  //            .setCredentials(
  //                GoogleCredentials.fromStream(
  //                    new ByteArrayInputStream(firebaseCredentials.toString().getBytes())))
  //            .build();
  //
  //    firebaseApp = FirebaseApp.initializeApp(firebaseOptions, UUID.randomUUID().toString());
  //  }
  //
  //  @Bean
  //  @Primary
  //  public FirebaseMessaging firebaseMessaging() {
  //    return FirebaseMessaging.getInstance(firebaseApp);
  //  }
}
