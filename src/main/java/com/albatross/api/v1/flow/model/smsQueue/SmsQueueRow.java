package com.albatross.api.v1.flow.model.smsQueue;

import com.albatross.api.v1.flow.model.Owner;
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

  private Long id, sentToUserId, projectId, contactId, objectTypeId;
  private String contactName, projectName, sentToUserName, message, projectStatusType, sentByUserName;
  private Boolean messageRead;
  private Date created, twilioDelivered;
}
