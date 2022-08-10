package com.albatross.api.config;

import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.client.builder.AwsClientBuilder.EndpointConfiguration;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Slf4j
@Configuration
@RequiredArgsConstructor
public class AwsClientConfig {

  private final AwsProperties awsProperties;

  @Bean
  @Primary
  public AmazonS3 s3Client() {
    var creds =
        new BasicAWSCredentials(awsProperties.getAccessKeyId(), awsProperties.getSecretKey());
    var builder =
        AmazonS3ClientBuilder.standard().withCredentials(new AWSStaticCredentialsProvider(creds));

    if (awsProperties.getServiceEndpoint() != null) {
      builder =
          builder
              .withEndpointConfiguration(
                  new EndpointConfiguration(
                      awsProperties.getServiceEndpoint().toString(),
                      awsProperties.getRegion().getName()))
              .withPathStyleAccessEnabled(true);
    } else {
      builder = builder.withRegion(awsProperties.getRegion());
    }
    return builder.build();
  }
}
