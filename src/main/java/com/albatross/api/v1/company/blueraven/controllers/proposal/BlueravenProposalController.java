package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.aurora.AuroraDesignWrappedDTO;
import com.albatross.api.aurora.ProposalAiRequestDTO;
import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions.InvalidStateApiException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.*;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.InstallAgreementService;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.micrometer.core.annotation.Timed;
import io.swagger.v3.oas.annotations.Parameter;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
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

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Optional;

@Slf4j
@Validated
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/proposal", produces = MediaType.APPLICATION_JSON_VALUE)
@PreAuthorize("hasFeatureAccess('PROPOSALS')")
public class BlueravenProposalController {

  private static final String CACHE_CONTROL_VALUE = "no-store, no-cache, must-revalidate, max-age=0";

  private final BlueravenProposalService proposalService;
  private final ProposalVersionService proposalVersionService;
  private final InstallAgreementService installAgreementService;
  private final ObjectMapper objectMapper;

  @GetMapping(value = "/projects")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public Page<ProposalProject> getProposalProjects(@RequestParam String query, Pageable pageable) {
    return proposalService.getProposalProjects(query, pageable);
  }


    @PostMapping(value = "/projects/{projectId}/ai")
    @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
    public AuroraDesignWrappedDTO doProposalAiRequest(@PathVariable Long projectId,
                                                      @RequestBody ProposalAiRequestDTO proposalAiRequestDTO) {
        //this is called to generate an initial aurora design
        return proposalService.doProposalAiRequest(projectId, proposalAiRequestDTO.getCustomFieldValuesList(), proposalAiRequestDTO.getMonthlyInputs());
    }


  @PostMapping(value = "/projects/{projectId}/ai/design/{designId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public void handleNewPpsForAuroraDesign(@PathVariable Long projectId,
                                  @PathVariable String designId,
                                  @RequestParam(required = false) Boolean designByAuroraValue,
                                  @RequestBody List<com.albatross.api.v1.flow.model.CustomFieldValue> values) {
    //this is only called after duplicating an aurora design
    proposalService.handleNewPpsForAuroraDesign(projectId, designId, values, null != designByAuroraValue ? designByAuroraValue : false);
  }


  @PostMapping(value = "/pps/{ppsId}/design/{designId}/{auroraProjectId}/sync")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public void syncDesign(@PathVariable Long ppsId,
                         @PathVariable String designId,
                         @PathVariable String auroraProjectId) {
    proposalService.syncDesign(ppsId, designId, auroraProjectId);
  }

  @GetMapping(value = "/projects/{projectId}/designs")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public List<ProposalDesign> getProposalDesigns(@PathVariable Long projectId) {
    return proposalService.getProposalDesigns(projectId);
  }

  @GetMapping(value = "/projects/{projectId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public Optional<ProposalProjectDetails> getProposalProject(@PathVariable Long projectId) {
    return proposalService.getProposalProjectById(projectId);
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
  public Optional<Proposal> getProposal(@PathVariable Long proposalId,
                                        @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.getProposal(proposalId, details.getId());
  }

  @GetMapping(value = "/{proposalId}/commissionDetails")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public List<ProposalCommissionDetail> getProposalCommissionDetails(@PathVariable Long proposalId,
                                                                     @RequestParam Long financialProductId,
                                                                     @RequestParam Long brsProductId) {
    return proposalService.getProposalCommissionDetails(proposalId, financialProductId, brsProductId);
  }

  @PutMapping(value = "/{proposalId}/version/{versionId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN', 'PROPOSALS_MANAGE')")
  public void updateProposalVersion(@PathVariable Long proposalId,
                                    @PathVariable Long versionId,
                                    @AuthenticationPrincipal UserAccountDetails details) {
    proposalService.updateProposalVersion(proposalId, versionId, details);
  }

  @PostMapping(value = "/{proposalId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Optional<Proposal> updateProposalCustomFieldValues(@PathVariable Long proposalId,
                                                            @RequestBody @Size(min = 1) List<CustomFieldValue> cfvs,
                                                            @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.updateProposalCustomFieldValues(proposalId, cfvs, details);
  }

  @DeleteMapping(value = "/{proposalId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public void archiveProposal(@PathVariable Long proposalId, @AuthenticationPrincipal UserAccountDetails details) {
    proposalService.archiveProposal(proposalId, details);
  }

  @PostMapping(value = "/{proposalId}/name")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_EDIT', 'PROPOSALS_ADMIN')")
  public Proposal updateProposalName(@PathVariable Long proposalId,
                                     @Valid @RequestBody ProposalNameUpdateRequest nameUpdateRequest,
                                     @AuthenticationPrincipal UserAccountDetails details) {
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
  public Optional<DocRequestResponse> sendDocs(@PathVariable Long proposalId,
                                               @Valid @RequestBody SendDocRequest docRequest,
                                               @AuthenticationPrincipal UserAccountDetails details) {

    return getLockedProposal(proposalId)
      .map(proposal -> {
        try {
          final InstallAgreementRequest request = getInstallAgreementRequest(docRequest, proposal);
          final String saveRequest = installAgreementService.saveRequest(request);

          if (saveRequest == null || saveRequest.trim().isEmpty()) {
            proposalService.setDocsAsSubmitted(proposalId, docRequest.docType, details);
            return new DocRequestResponse(true, "Request successfully submitted");
          }

          return new DocRequestResponse(false, saveRequest);
        } catch (Exception e) {
          throw new ApiException(e);
        }
      });
  }

  private InstallAgreementRequest getInstallAgreementRequest(SendDocRequest docRequest, Proposal proposal) {
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
    return request;
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
                                                        @Parameter(hidden = true) @RequestParam(value = "type", defaultValue = "MOBILE") ProposalGeneratedType proposalGeneratedType,
                                                        @Parameter(hidden = true) @RequestParam(value = "debug", defaultValue = "false") boolean isDebug) {
    return proposalService.getProposalTemplate(proposalId, proposalGeneratedType, isDebug);
  }

  @Timed
  @GetMapping(value = "/{proposalId}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_ADMIN')")
  public ResponseEntity<StreamingResponseBody> getProposalTemplatePdf(@PathVariable Long proposalId,
                                                                      @RequestParam(defaultValue = "false") boolean inline,
                                                                      HttpServletResponse response) {
    final StreamingResponseBody responseBody = outputStream -> {
      try {
        ProposalResource result = proposalService.generateProposalPDF(proposalId)
          .orElseThrow(() -> new ApiException("Proposal not found"));

        Proposal proposal = result.proposal();
        final String contentDisposition = getContentDisposition(proposal, inline);

        response.addHeader(HttpHeaders.CACHE_CONTROL, CACHE_CONTROL_VALUE);
        response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE);
        response.addHeader(HttpHeaders.CONTENT_DISPOSITION, contentDisposition);
        response.addHeader(HttpHeaders.CONTENT_LENGTH, String.valueOf(result.resource().contentLength()));

        try (InputStream inputStream = result.resource().getInputStream()) {
          IOUtils.copy(inputStream, outputStream);
        }
      } catch (Exception e) {
        throw new ApiException(e);
      }
    };

    return ResponseEntity.ok(responseBody);
  }

  private String getContentDisposition(Proposal proposal, boolean inline) {
    String cleanedFilename = getCleanFilename(proposal);
    return
      "%s; filename=\"%s%sproposal.pdf\"".formatted(
        inline ? "inline" : "attachment",
        cleanedFilename,
        proposal.isLocked() ? "_" : "_DRAFT_");
  }

  private String getCleanFilename(Proposal proposal) {
    return proposal.getDisplayName().trim()
      .replaceAll("[^a-zA-Z0-9\\s]", "")
      .replace(" ", "_");
  }

  @GetMapping(value = "/{proposalId}/filter")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_VIEW', 'PROPOSALS_VIEW_ALL', 'PROPOSALS_EDIT', 'PROPOSALS_MANAGE', 'PROPOSALS_ADMIN')")
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

  public record ProposalErrorMessage(String message) {
  }
}
