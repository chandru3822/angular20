package com.albatross.api.push;

import jakarta.validation.constraints.Size;
import lombok.NonNull;

import java.util.List;

public interface PushNotificationService {
  void pushNotification(@NonNull Message message, @NonNull Long userId);
  void pushNotification(@NonNull Message message, @Size(min = 1) List<Long> userIds);
}
