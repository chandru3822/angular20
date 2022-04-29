package com.albatross.api.config;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder.EndpointConfiguration;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.annotation.PostConstruct;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.UUID;

@Slf4j
@Configuration
@RequiredArgsConstructor
public class BeansConfiguration {

  private final AwsProperties awsProperties;

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

  private FirebaseApp firebaseApp;

  @PostConstruct
  private void init() throws IOException {

    JSONObject firebaseCredentials = new JSONObject();
    firebaseCredentials.put("type", firebaseType);
    firebaseCredentials.put("project_id", firebaseProjectId);
    firebaseCredentials.put("private_key_id", firebasePrivateKeyId);
    firebaseCredentials.put("private_key", firebasePrivateKey);
    firebaseCredentials.put("client_email", firebaseClientEmail);
    firebaseCredentials.put("client_id", firebaseClientId);
    firebaseCredentials.put("auth_uri", firebaseAuthUri);
    firebaseCredentials.put("token_uri", firebaseTokenUri);
    firebaseCredentials.put("auth_provider_x509_cert_url", firebaseAuthProviderX509CertUrl);
    firebaseCredentials.put("client_x509_cert_url", firebaseClientX509CertUrl);

    FirebaseOptions firebaseOptions =
        FirebaseOptions.builder()
            .setCredentials(
                GoogleCredentials.fromStream(
                    new ByteArrayInputStream(firebaseCredentials.toString().getBytes())))
            .build();

    firebaseApp = FirebaseApp.initializeApp(firebaseOptions, UUID.randomUUID().toString());
  }

  @Bean
  @Primary
  public AmazonS3 s3Client() {
    var creds =
        new BasicAWSCredentials(awsProperties.getAccessKeyId(), awsProperties.getSecretKey());
    var builder =
        AmazonS3ClientBuilder.standard().withCredentials(new AWSStaticCredentialsProvider(creds));

    if (awsProperties.getServiceEndpoint() != null) {
      builder =
          builder.withEndpointConfiguration(
              new EndpointConfiguration(
                  awsProperties.getServiceEndpoint().toString(),
                  awsProperties.getRegion().getName()));
    } else {
      builder = builder.withRegion(awsProperties.getRegion());
    }
    return builder.build();
  }

  @Bean
  @Primary
  public FirebaseMessaging firebaseMessaging() {
    return FirebaseMessaging.getInstance(firebaseApp);
  }
}
