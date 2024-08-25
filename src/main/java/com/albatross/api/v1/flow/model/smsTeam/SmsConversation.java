package com.albatross.api.v1.flow.model.smsTeam;

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

  private Long id, parentId, userId, recipientTypeId, companyId;
  private String message, fullName, stateAbbreviation, internalPhone, externalPhone, searchInternalPhone, searchExternalPhone;
  private Date dateCreated;
  private boolean closed, showAssignedToMeButton = false, external;
  private List<SmsOwner> conversationOwners;
  private List<SmsTeam> smsTeamOwners;

  private List<SmsSource> sources;
  private List<Long> projectIdsForFilter, projectIdsInbox, projectIdsSent, userIdsForFilter, userIdsInbox, userIdsSent;
}
