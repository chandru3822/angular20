package com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions;

import com.albatross.api.exception.ApiException;

public class UnapprovedPostalCodeProposalException extends ApiException {
  public UnapprovedPostalCodeProposalException() {
    super("Project requires postal code approval before requesting new design");
  }
}
