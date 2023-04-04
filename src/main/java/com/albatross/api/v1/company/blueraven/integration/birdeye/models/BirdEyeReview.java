package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeApi;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public
class BirdEyeReview {

  private String businessId;
  private String businessName;
  private String reviewId;
  private Integer rating;
  private String title;
  private String comments;
  private String status;

  @JsonFormat
    (shape = JsonFormat.Shape.STRING, pattern = "MMM dd, yyyy")
  private LocalDate reviewDate;

  private String uniqueReviewUrl;

  private BirdeyeReviewer reviewer;

  private String sourceType;

  @JsonFormat
    (shape = JsonFormat.Shape.STRING, pattern = "MMM dd, yyyy hh:mm a")
  private LocalDate responseDate;

  private String response;

  private Integer featured;

  private Boolean enableReply;

  private String customerId;

  @Data
  @JsonIgnoreProperties(ignoreUnknown = true)
  public static class BirdeyeReviewer {
    private String firstName, lastName, nickName, emailId, phone, city, state;
    private String thumbnailUrl;
  }
}
