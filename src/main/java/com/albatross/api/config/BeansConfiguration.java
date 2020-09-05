package com.albatross.api.config;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Slf4j
@Configuration
public class BeansConfiguration {
    @Value("${aws.accessKeyId}")
    private String accessKey;
    @Value("${aws.secretKey}")
    private String secretKey;

    @Bean
    @Primary
    public AmazonS3 s3Client() {
        AWSCredentials creds = new BasicAWSCredentials(accessKey, secretKey);
        AmazonS3 awsClientBuilder = AmazonS3ClientBuilder
                .standard()
                .withRegion(Regions.US_EAST_1)
                .withCredentials(new AWSStaticCredentialsProvider(creds))
                .build();
        return awsClientBuilder;
    }
}
