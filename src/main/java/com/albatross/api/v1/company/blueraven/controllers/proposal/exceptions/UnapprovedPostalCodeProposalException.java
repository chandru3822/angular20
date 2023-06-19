package com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions;

public class UnapprovedPostalCodeProposalException extends InvalidStateApiException {
  public UnapprovedPostalCodeProposalException() {
    super("Project requires postal code approval before requesting new design");
  }
}
