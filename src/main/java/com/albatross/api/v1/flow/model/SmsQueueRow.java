package com.albatross.api.v1.flow.model;

import lombok.*;

import java.util.Date;

@EqualsAndHashCode
@Getter
@Setter
@NoArgsConstructor
public class SmsQueueRow {

  private Long id, userId;
  private String fullName, message, projectStatus, lastMessageSentBy;
  private boolean priority, messageRead;
  private Owner owner;
  private Long ownerUserPositionId;

  private Date lastMessageSent, lastMessageReceived;
}
