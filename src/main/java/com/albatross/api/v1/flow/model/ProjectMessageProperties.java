package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.model.smsQueue.SMSQueueItem;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import lombok.Getter;
import lombok.Setter;

import java.util.*;

/**
 * Created by John Berns on 2021-02-03.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProjectMessageProperties {

  private Long projectId, messageStatusId, ownerUserId;
  private String projectName, fullName, orgName, displayedOwner, state, createdBy;
  private Date lastMessageSentAt;
  private boolean closed, showAssignedToMeButton = false;
  private List<SMSQueueItem> messageHistory;
  private List<SmsTeam> smsTeamOwners;
}
