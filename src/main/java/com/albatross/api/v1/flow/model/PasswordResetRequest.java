package com.albatross.api.v1.flow.model;

import lombok.Data;
import java.util.UUID;

@Data
public class PasswordResetRequest {
  private String usernameOrEmail;
  private String newPassword;
  private String newPasswordAgain;
  private UUID uuid;
  private Long userId;
  private String accessType;
  private String mobileVersion;
}
