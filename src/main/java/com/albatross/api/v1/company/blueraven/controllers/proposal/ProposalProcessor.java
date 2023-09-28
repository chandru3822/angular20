package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalResource;
import com.albatross.api.v1.company.blueraven.models.Proposal;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.services.ProjectService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "app.scheduled", value = "enabled")
public class ProposalProcessor {

  private static final Long PROPOSAL_ATTACHMENT_TYPE = 37L;
  private final BlueravenProposalService proposalService;
  private final ProjectService projectService;
  private final SecurityService securityService;

  @Transactional
  @Scheduled(fixedDelay = 1, timeUnit = TimeUnit.MINUTES)
  public void doGenerateFinalPDF() {
    // system needs to be aware of a user to access methods
    setBlueravenSystemUser();

    Instant startTime = Instant.now();

    AtomicInteger count = new AtomicInteger();

    proposalService.getLockedProposalsBatchForProcessing().stream()
      .map(proposalService::getProposal)
      .flatMap(Optional::stream)
      .forEach(proposal -> {
        log.info("[Proposal] Generating final PDF for proposalId={}", proposal.getId());

        try {
          proposalService.generateProposalPDF(proposal.getId(), 1L)
            .ifPresent(result -> {
              handleResult(result);
              count.getAndIncrement();
            });
        } catch (Exception e) {
          log.error("[Proposal] Error processing final PDF for proposalId={}", proposal.getId(), e);
          proposalService.setProcessingErrorMessage(proposal.getId(), e.getMessage(), SystemSettings.BR_SYSTEM_USER.getId());
        }
      });

    Instant endTime = Instant.now();
    if (count.get() > 0) {
      log.info("[Proposal] Generating PDF batch took {}ms to generate {} files",
        TimeUnit.MILLISECONDS.convert(
          endTime.toEpochMilli() - startTime.toEpochMilli(),
          TimeUnit.MILLISECONDS)
        , count.get());
    }
  }

  private void handleResult(ProposalResource result) {
    try {
      Proposal proposal = result.proposal();
      log.info("[Proposal] Saving attachment to projectId={}", proposal.getProjectId());

      Map<String, Object> context = result.context();

      String financier = context.getOrDefault("financier", "").toString();
      String loanTerm = context.getOrDefault("loan_term", "").toString();
      String product = context.getOrDefault("product_name", "").toString();

      String displayName = String.format("%s %s %s %s", proposal.getDisplayName(), financier, loanTerm, product).trim();
      String filename = String.format("%s.pdf", displayName);

      Resource resource = result.resource();

      projectService.addAttachment(
        proposal.getProjectId(),
        PROPOSAL_ATTACHMENT_TYPE,
        resource.contentLength(),
        MediaType.APPLICATION_PDF_VALUE,
        filename,
        resource.getInputStream(),
        displayName);

      log.debug("[Proposal] Setting proposal as processed for projectId={}", proposal.getId());
      proposalService.setProposalAsProcessed(proposal.getId());

    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  private void setBlueravenSystemUser() {
    log.debug("Setting BR System User");
    final SystemSettings brSystemUser = SystemSettings.BR_SYSTEM_USER;

    final User user = new User();
    user.setId(brSystemUser.getId());
    user.setCompanyId(brSystemUser.getCompanyId());
    user.setHighestCompanyId(brSystemUser.getCompanyId());
    user.setHighestParentCompanyId(brSystemUser.getCompanyId());

    final FeatureAccessControl proposalAdminFac = new FeatureAccessControl();
    proposalAdminFac.setEnabled(true);
    proposalAdminFac.setFeatureCode("PROPOSALS");
    proposalAdminFac.setAccessCode("ADMIN");

    final FeatureAccessControl projectAdminFac = new FeatureAccessControl();
    projectAdminFac.setEnabled(true);
    projectAdminFac.setFeatureCode("PROJECTS");
    projectAdminFac.setAccessCode("ADMIN");

    final UserAccountDetails uad = new UserAccountDetails(user, List.of(proposalAdminFac, projectAdminFac));

    securityService.setCurrentUserDetails(uad);
  }
}
