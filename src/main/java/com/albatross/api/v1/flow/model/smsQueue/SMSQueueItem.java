package com.albatross.api.v1.flow.model.smsQueue;

import com.albatross.api.v1.flow.enums.RecipientType;
import com.albatross.api.v1.flow.model.Owner;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SMSQueueItem {

  private Long id, userId, recipientTypeId, projectId, messageSentByUserId, contactId, priorityLevel;
  private String firstName, lastName, fullName, email, message, searchExternalPhone, searchInternalPhone;
  private String messageGroup,
      messageSid,
      messageStatus,
      fromPhone,
      toPhone,
      errorMessage,
      projectStatus,
      sentByName;
  private List<String> mediaUrls;
  private boolean messageRead, inbound;
  private Owner owner;

  private Date dateCreated,
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
