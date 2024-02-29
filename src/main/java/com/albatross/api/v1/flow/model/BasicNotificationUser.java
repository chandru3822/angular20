package com.albatross.api.v1.flow.model;

import lombok.Data;

@Data
public class BasicNotificationUser {
  private Long id;
  private String firstName, lastName, token;
}
