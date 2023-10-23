package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions.InvalidStateApiException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalGeneratedType;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalPostalCodeStatus;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalValueFilter;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.InstallAgreementService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.micrometer.core.annotation.Timed;
import io.swagger.v3.oas.annotations.Parameter;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import java.io.IOException;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

@Slf4j
@Validated
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/proposal", produces = MediaType.APPLICATION_JSON_VALUE)
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccess('PROPOSALS')")
public class BlueravenProposalController {

  private final BlueravenProposalService proposalService;
  private final ProposalVersionService proposalVersionService;
  private final InstallAgreementService installAgreementService;
  private final ObjectMapper objectMapper;

  @GetMapping(value = "/projects")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public Page<ProposalProject> getProposalProjects(@RequestParam String query, Pageable pageable) {
    return proposalService.getProposalProjects(query, pageable);
  }

  @GetMapping(value = "/projects/{projectId}/designs")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public List<ProposalDesign> getProposalDesigns(@PathVariable Long projectId) {
    return proposalService.getProposalDesigns(projectId);
  }

  @GetMapping(value = "/projects/{projectId}/designs/active")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public ProposalDesign getActiveDesign(@PathVariable Long projectId) {
    return proposalService.getActiveDesign(projectId).orElse(null);
  }

  @PostMapping(value = "/projects/{projectId}/designs")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public List<ProposalDesign> requestNewDesign(@PathVariable Long projectId,
                                               @Valid @ModelAttribute CreateNewDesignRequest request,
                                               @AuthenticationPrincipal UserAccountDetails details) throws IOException {
    return proposalService.requestNewDesign(projectId, request.description, request.dueDate, request.attachments, request.utilityBillAttachments, details);
  }

  @PostMapping(value = "/projects/{projectId}/postalCode")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public ProposalDesign requestPostalCodeApproval(@PathVariable Long projectId,
                                                  @Valid @RequestBody ProposalPostalApprovalRequest request,
                                                  @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.requestPostalCodeApproval(projectId, request.comments, details.getTrueUserId()).orElse(null);
  }

  @GetMapping(value = "/projects/{projectId}/postalCode")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public ProposalPostalCodeStatus checkPostalCodeApproval(@PathVariable Long projectId) {
    return proposalService.checkPostalCodeApproval(projectId);
  }

  @PostMapping
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Optional<Proposal> addProposal(@RequestBody Proposal proposal,
                                        @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.addProposal(proposal, details);
  }

  @GetMapping(value = "/{proposalId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public Optional<Proposal> getProposal(@PathVariable Long proposalId) {
    return proposalService.getProposal(proposalId);
  }

  @GetMapping(value = "/{proposalId}/commissionDetails")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public List<ProposalCommissionDetail> getProposalCommissionDetails(@PathVariable Long proposalId) {
    return proposalService.getProposalCommissionDetails(proposalId);
  }

  @PostMapping(value = "/{proposalId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Optional<Proposal> updateProposalCustomFieldValues(@PathVariable Long proposalId, @RequestBody @Size(min = 1) List<CustomFieldValue> cfvs) {
    return proposalService.updateProposalCustomFieldValues(proposalId, cfvs);
  }

  @DeleteMapping(value = "/{proposalId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public void archiveProposal(@PathVariable Long proposalId, @AuthenticationPrincipal UserAccountDetails details) {
    proposalService.archiveProposal(proposalId, details);
  }

  @PostMapping(value = "/{proposalId}/name")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Proposal updateProposalName(@PathVariable Long proposalId, @Valid @RequestBody ProposalNameUpdateRequest nameUpdateRequest, @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.setProposalName(proposalId, nameUpdateRequest.name(), details);
  }

  @PostMapping(value = "/{proposalId}/lock")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Optional<Proposal> lockProposal(@PathVariable Long proposalId, @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.lockProposal(proposalId, details);
  }

  @GetMapping(value = "/{proposalId}/loanApplication")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Optional<String> generateLoanApplication(@PathVariable Long proposalId, @AuthenticationPrincipal UserAccountDetails details) {
    return getLockedProposal(proposalId)
      .map(proposal -> {
        try {
          final String loanApplication = installAgreementService.generateLoanApplication(proposal.getProjectId(), proposal.getProposalNbr(), null);
          proposalService.setCreditCheckSubmitted(proposal.getId(), details);

          if (loanApplication.contains("applicationUrl")) {
            final LoanStatusUpdate loanStatusUpdate = objectMapper.convertValue(loanApplication, LoanStatusUpdate.class);
            return loanStatusUpdate.applicationUrl;
          }

          return loanApplication;
        } catch (Exception e) {
          throw new ApiException(e);
        }
      });
  }

  @PostMapping(value = "/{proposalId}/sendDocs")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Optional<DocRequestResponse> sendDocs(@PathVariable Long proposalId, @Valid @RequestBody SendDocRequest docRequest, @AuthenticationPrincipal UserAccountDetails details) {

    return getLockedProposal(proposalId)
      .map(proposal -> {
        final InstallAgreementRequest request = new InstallAgreementRequest();
        request.setProjectId(proposal.getProjectId());
        request.setProposalNbr(proposal.getProposalNbr());
        request.setIsSpanish(docRequest.isSpanish());

        switch (docRequest.docType()) {
          case FINANCE_DOCS -> {
            request.setSendLoanDocs(true);
            request.setSendInstallationAgreement(false);
          }
          case INSTALLATION_AGREEMENT -> {
            request.setSendInstallationAgreement(true);
            request.setSendLoanDocs(false);
          }
        }

        try {
          final String saveRequest = installAgreementService.saveRequest(request);

          if (saveRequest == null || saveRequest.trim().equals("")) {
            proposalService.setDocsAsSubmitted(proposalId, docRequest.docType, details);
            return new DocRequestResponse(true, "Request successfully submitted");
          }

          return new DocRequestResponse(false, saveRequest);
        } catch (Exception e) {
          throw new ApiException(e);
        }
      });
  }

  @GetMapping(value = "/{proposalId}/loanStatus")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public Optional<String> checkLoanStatus(@PathVariable Long proposalId) {
    return getLockedProposal(proposalId)
      .map(proposal -> installAgreementService.getLoanStatus(proposal.getProjectId(), proposal.getProposalNbr()));
  }

  private Optional<Proposal> getLockedProposal(@NonNull Long proposalId) {
    return proposalService.getSimpleProposal(proposalId)
      .map(proposal -> {
        if (!proposal.isLocked()) {
          throw new InvalidStateApiException("Proposal must be locked to continue");
        }
        return proposal;
      });
  }

  @PostMapping(value = "/{proposalId}/duplicate")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Optional<Proposal> createProposalDuplicate(@PathVariable Long proposalId,
                                                    @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.createProposalDuplicate(proposalId, details.getTrueUserId());
  }

  @GetMapping(value = "/{proposalId}/template")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public Optional<ProposalTemplate> getProposalTemplate(@PathVariable Long proposalId,
                                                        @Parameter(hidden = true) @RequestParam(value = "templateId", defaultValue = "1") Long templateId,
                                                        @Parameter(hidden = true) @RequestParam(value = "type", defaultValue = "MOBILE") ProposalGeneratedType proposalGeneratedType,
                                                        @Parameter(hidden = true) @RequestParam(value = "debug", defaultValue = "false") boolean isDebug) {
    return proposalService.getProposalTemplate(proposalId, templateId, proposalGeneratedType, isDebug);
  }

  @Timed
  @GetMapping(value = "/{proposalId}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public ResponseEntity<StreamingResponseBody> getProposalTemplatePdf(@PathVariable Long proposalId,
                                                                      @Parameter(hidden = true) @RequestParam(value = "templateId", defaultValue = "1") Long templateId,
                                                                      @RequestParam(value = "inline", defaultValue = "false") boolean inline,
                                                                      HttpServletResponse response) {

    final StreamingResponseBody responseBody = outputStream -> {
      try {
        proposalService.generateProposalPDF(proposalId, templateId)
          .ifPresent(result -> {
            try {
              final String contentDisposition = String.format(
                "%s; filename=\"proposal_%s_%s.pdf\"", inline ? "inline" : "attachment", result.proposal().getProposalNbr(), OffsetDateTime.now().format(DateTimeFormatter.ofPattern("ddMMyyyyHHmmssSSSS")));

              response.addHeader(HttpHeaders.CACHE_CONTROL, "no-store, no-cache, must-revalidate, max-age=0");
              response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE);
              response.addHeader(HttpHeaders.CONTENT_DISPOSITION, contentDisposition);

              response.addHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(result.resource().contentLength()));
              IOUtils.copy(result.resource().getInputStream(), outputStream);
            } catch (IOException e) {
              throw new ApiException(e);
            }
          });
      } catch (Exception e) {
        throw new ApiException(e);
      }
    };

    return ResponseEntity.ok(responseBody);
  }

  @GetMapping(value = "/{proposalId}/filter")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public ProposalFilterResponse getFilterableOptions(@PathVariable Long proposalId,
                                                     ProposalValueFilter filter) {
    final Long proposalVersionId = proposalService.getProposalVersionByProposalId(proposalId).orElseThrow(NotFoundException::new);
    final List<Long> filterIds = proposalVersionService.getProposalValuesFilterIds(proposalVersionId, filter);
    return new ProposalFilterResponse(filterIds);
  }

  @ExceptionHandler({InvalidStateApiException.class})
  protected ResponseEntity<ProposalErrorMessage> handleInvalidStateApiException(InvalidStateApiException ex) {
    final Throwable rootCause = ExceptionUtils.getRootCause(ex);
    return ResponseEntity.badRequest().body(new ProposalErrorMessage(rootCause.getMessage()));
  }

  public record CreateNewDesignRequest(@NotEmpty String description,
                                       String dueDate,
                                       List<MultipartFile> attachments,
                                       List<MultipartFile> utilityBillAttachments) {
  }

  public record SendDocRequest(@NotNull LoanDocType docType, boolean isSpanish) {
  }

  public record ProposalFilterResponse(List<Long> ids) {
  }

  public record DocRequestResponse(boolean success, String message) {
  }

  public record ProposalNameUpdateRequest(@NotBlank String name) {
  }

  public record ProposalPostalApprovalRequest(String comments) {
  }

  public record LoanStatusUpdate(String applicationUrl, String type) {
  }

  record ProposalErrorMessage(String message) {
  }


  @Data
  public static class DesignRequest {
    private Long projectId;
    private String description, dueDate;
    private List<Attachment> attachments;
  }
}
