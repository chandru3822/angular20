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

import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "app.scheduled.blueraven", value = "enabled", havingValue = "true")
public class ProposalProcessor {

  private static final Long PROPOSAL_ATTACHMENT_TYPE = 37L;
  private final BlueravenProposalService proposalService;
  private final ProjectService projectService;
  private final SecurityService securityService;

  @Scheduled(fixedDelay = 1, timeUnit = TimeUnit.MINUTES)
  public void doGenerateFinalPDF() {
    // system needs to be aware of a user to access methods
    setBlueravenSystemUser();

    Instant startTime = Instant.now();

    AtomicInteger count = new AtomicInteger();

    proposalService.getLockedProposalsBatchForProcessing()
      .forEach(processProposalPDF(count));

    if (count.get() > 0) {
      Duration duration = Duration.between(startTime, Instant.now());
      log.info("[Proposal] Generating PDF batch took {}ms to generate {} files", duration.toMillis(), count.get());
    }
  }

  private Consumer<Long> processProposalPDF(AtomicInteger count) {
    return proposalId -> {
      log.debug("[Proposal] Generating final PDF for proposalId={}", proposalId);

      try {
        proposalService.generateProposalPDF(proposalId, 1L)
          .ifPresent(result -> {
            handleResult(result);
            count.getAndIncrement();
          });
      } catch (Exception e) {
        log.error("[Proposal] Error processing final PDF for proposalId={}", proposalId, e);
        proposalService.setProcessingErrorMessage(proposalId, e.getMessage(), SystemSettings.BR_SYSTEM_USER.getId());
      }
    };
  }

  private void handleResult(ProposalResource result) {
    try {
      Proposal proposal = result.proposal();
      log.debug("[Proposal] Saving attachment to projectId={}", proposal.getProjectId());

      String displayName = getDisplayName(result);
      String filename = "%s.pdf".formatted(displayName);

      Resource resource = result.resource();

      try (InputStream attachmentStream = resource.getInputStream()) {
        projectService.addAttachment(
          proposal.getProjectId(),
          PROPOSAL_ATTACHMENT_TYPE,
          resource.contentLength(),
          MediaType.APPLICATION_PDF_VALUE,
          filename,
          attachmentStream,
          displayName);
      }

      log.debug("[Proposal] Setting proposal as processed for projectId={}", proposal.getId());
      proposalService.setProposalAsProcessed(proposal.getId());

    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  private String getDisplayName(ProposalResource result) {
    Proposal proposal = result.proposal();
    Map<String, Object> context = result.context();

    Object financier = getDefaultValue(context, "financier", "");
    Object loanTerm = getDefaultValue(context, "loan_term", "");
    Object product = getDefaultValue(context, "product_name", "");

    return "%s %s %s %s".formatted(proposal.getDisplayName(), financier, loanTerm, product).trim();
  }

  private String getDefaultValue(Map<String, Object> context, String key, String defaultValue) {
    Object result = context.getOrDefault(key, defaultValue);
    if (result == null) {
      return defaultValue;
    }
    return result.toString();
  }

  private void setBlueravenSystemUser() {
    log.debug("Setting BR System User");
    final SystemSettings brSystemUser = SystemSettings.BR_SYSTEM_USER;

    final User user = new User();
    user.setId(brSystemUser.getId());
    user.setCompanyId(brSystemUser.getCompanyId());
    user.setHighestCompanyId(brSystemUser.getCompanyId());
    user.setHasAccess(true);
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
