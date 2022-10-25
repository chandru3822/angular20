package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.services.ProjectService;
import com.github.sonus21.rqueue.annotation.RqueueListener;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class ProposalRqueueListeners {

  private static final Long PROPOSAL_ATTACHMENT_TYPE = 37L;
  private final BlueravenProposalService proposalService;
  private final ProjectService projectService;
  private final SecurityService securityService;

  @RqueueListener(value = "proposal_job", numRetries = "2")
  public void doGenerateFinalPDF(ProposalJobMessage job) {
    // system needs to be aware of a user to access methods
    setBlueravenSystemUser();

    proposalService.getProposal(job.proposalId())
      .ifPresent(proposal -> {
        log.info("[Proposal] Generating final PDF for proposalId={}", job.proposalId());
        proposalService.generateProposalPDF(proposal.getId(), 1L, true)
          .ifPresent(baos -> {
            log.info("[Proposal] Saving attachment to projectId={}", proposal.getProjectId());

            projectService.addAttachment(
              proposal.getProjectId(),
              PROPOSAL_ATTACHMENT_TYPE,
              baos.getContentLength(),
              baos.getContentType(),
              proposal.getDisplayName(),
              baos.getInputStream(),
              proposal.getDisplayName());

            log.debug("[Proposal] Setting proposal as processed for projectId={}", proposal.getId());
            proposalService.setProposalAsProcessed(proposal.getId());
          });
      });
  }

  private void setBlueravenSystemUser() {
    log.debug("Setting BR System User");
    final SystemSettings brSystemUser = SystemSettings.BR_SYSTEM_USER;

    final User user = new User();
    user.setId(brSystemUser.getId());
    user.setCompanyId(brSystemUser.getCompanyId());
    user.setHighestCompanyId(brSystemUser.getCompanyId());
    user.setHighestParentCompanyId(brSystemUser.getCompanyId());

    final FeatureAccessControl featureAccessControl = new FeatureAccessControl();
    featureAccessControl.setEnabled(true);
    featureAccessControl.setFeatureCode("PROPOSALS");
    featureAccessControl.setAccessCode("ADMIN");

    final UserAccountDetails uad = new UserAccountDetails(user, List.of(featureAccessControl));

    securityService.setCurrentUserDetails(uad);
  }
}
