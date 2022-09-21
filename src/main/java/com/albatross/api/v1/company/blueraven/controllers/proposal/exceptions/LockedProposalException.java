package com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions;

import com.albatross.api.exception.ApiException;

public class LockedProposalException extends ApiException {
  public LockedProposalException() {
    super("Unable to edit locked proposal");
  }
}
