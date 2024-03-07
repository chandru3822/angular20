package com.albatross.api.push;

import jakarta.validation.constraints.Size;
import lombok.NonNull;

import java.util.Set;

public interface PushNotificationService {
  void pushNotification(@NonNull Message message, @NonNull Long userId);
  void pushNotification(@NonNull Message message, @Size(min = 1) Set<Long> userIds);
  void pruneTokens();
}
