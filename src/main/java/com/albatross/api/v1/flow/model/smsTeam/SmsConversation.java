package com.albatross.api.v1.flow.model.smsTeam;

import com.albatross.api.v1.flow.model.smsTeam.SmsOwner;
import com.albatross.api.v1.flow.model.smsTeam.SmsProject;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by John Berns on 2021-02-03.
 * !Describe Purpose!
 */
@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SmsConversation {

  private Long internalConversationId, externalConversationId, userId;
  private String lastMessageText, fullName;
  private Date lastSent;
  private boolean closed, showAssignedToMeButton = false;
  private List<SmsOwner> conversationOwners;
  private List<SmsProject> projects;
  private List<Long> projectIdsForFilter, projectIdsInbox, projectIdsSent, userIdsForFilter, userIdsInbox, userIdsSent;
}
