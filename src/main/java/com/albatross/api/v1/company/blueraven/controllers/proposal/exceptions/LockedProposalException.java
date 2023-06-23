package com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions;

public class LockedProposalException extends InvalidStateApiException {
  public LockedProposalException() {
    super("Unable to edit locked proposal");
  }
}
