package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.UUID;

@Data
public class PasswordResetRequest {
    private String usernameOrEmail, newPassword, newPasswordAgain;
    private UUID uuid;
    private Long userId;
}
