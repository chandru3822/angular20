package com.albatross.api.v1.flow.services;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PushNotification {
  private Long id;
  private String title;
  private String message;
  private String webHyperlink;
  private Long sendToUserId;
  private String phoneNumber;
  private Boolean processed;
}


