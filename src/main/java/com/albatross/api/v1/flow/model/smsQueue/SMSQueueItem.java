package com.albatross.api.v1.flow.model.smsQueue;

import com.albatross.api.v1.flow.enums.RecipientType;
import com.albatross.api.v1.flow.model.Owner;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
public class SMSQueueItem {

  private Long id, userId, recipientTypeId, projectId, messageSentByUserId, contactId;
  private String firstName, lastName, fullName, email, message;
  private String messageGroup,
      messageSid,
      messageStatus,
      fromPhone,
      toPhone,
      errorMessage,
      projectStatus,
      sentByName;
  private List<String> mediaUrls;
  private boolean priority, messageRead;
  private Owner owner;

  private Date created,
      updated,
      twilioCreated,
      twilioSent,
      twilioDelivered,
      lastMessageSent,
      lastMessageReceived;

  public RecipientType getRecipientType() {
    return RecipientType.values()[recipientTypeId.intValue()];
  }
}
