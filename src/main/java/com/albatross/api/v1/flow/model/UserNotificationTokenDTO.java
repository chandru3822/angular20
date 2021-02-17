package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserNotificationTokenDTO {

  private Long id, userId;

  private String token;
}
