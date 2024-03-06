package com.albatross.api.v1.flow.model;

import lombok.Data;

@Data
public class BasicNotificationUser {
  private Long id;
  private String firstName, lastName;
  public String getFullName(){
    return "%s %s".formatted(firstName, lastName);
  }
}
