package com.albatross.api.v1.flow.model;

import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@EqualsAndHashCode
@Getter
@Setter
@NoArgsConstructor
public class SmsQueueRow {

  private Long id, userId, projectId;
  private String fullName, message, projectStatus, lastMessageSentBy;
  private boolean priority, messageRead;
  private Owner owner;
  private Long ownerUserPositionId;

  private Date lastMessageSent, lastMessageReceived;
}
