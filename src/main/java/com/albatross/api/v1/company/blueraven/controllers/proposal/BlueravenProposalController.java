package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalGeneratedType;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalValueFilter;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.InstallAgreementService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import io.micrometer.core.annotation.Timed;
import io.swagger.v3.oas.annotations.Parameter;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/company/blueraven/proposal", produces = MediaType.APPLICATION_JSON_VALUE)
public class BlueravenProposalController {

  private final BlueravenProposalService proposalService;
  private final ProposalVersionService proposalVersionService;
  private final InstallAgreementService installAgreementService;

  @GetMapping(value = "/projects")
  public Page<ProposalProject> getProposalProjects(@RequestParam String query, Pageable pageable) {
    return proposalService.getProposalProjects(query, pageable);
  }

  @GetMapping(value = "/designs/{projectId}")
  public List<ProposalDesign> getProposalDesigns(@PathVariable Long projectId) {
    return proposalService.getProposalDesigns(projectId);
  }

  @GetMapping(value = "/design/{projectId}/active")
  public ProposalDesign getActiveDesign(@PathVariable Long projectId) {
    return proposalService.getActiveDesign(projectId);
  }

  @PostMapping(value = "/design")
  public List<ProposalDesign> requestNewDesign(@RequestParam Long projectId, @RequestParam String description, @RequestParam String dueDate, @RequestParam(required = false) List<MultipartFile> attachments, @RequestParam(required = false) List<MultipartFile> utilityBillAttachments, @AuthenticationPrincipal UserAccountDetails details) throws IOException {
    return proposalService.requestNewDesign(projectId, description, dueDate, attachments, utilityBillAttachments, details);
  }

  @GetMapping(value = "/{proposalId}")
  public Optional<Proposal> getProposal(@PathVariable Long proposalId) {
    return proposalService.getProposal(proposalId);
  }

  @PostMapping(value = "/{proposalId}")
  public Optional<Proposal> updateProposalCustomFieldValues(@PathVariable Long proposalId, @RequestBody List<CustomFieldValue> cfvs) {
    return proposalService.updateProposalCustomFieldValues(proposalId, cfvs);
  }

  @PostMapping(value = "/{proposalId}/name")
  public Proposal updateProposalName(@PathVariable Long proposalId, @Valid @RequestBody ProposalNameUpdateRequest nameUpdateRequest, @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.setProposalName(proposalId, nameUpdateRequest.name(), details);
  }

  @PostMapping(value = "/{proposalId}/lock")
  public Optional<Proposal> lockProposal(@PathVariable Long proposalId, @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.lockProposal(proposalId, details);
  }

  @GetMapping(value = "/{proposalId}/loanApplication")
  public Optional<String> generateLoanApplication(@PathVariable Long proposalId, @AuthenticationPrincipal UserAccountDetails details) {
    return getLockedProposal(proposalId)
      .map(proposal -> {
        try {
          final String loanApplication = installAgreementService.generateLoanApplication(proposal.getProjectId(), proposal.getProposalNbr(), null);
          proposalService.setCreditCheckSubmitted(proposal.getId(), details);
          return loanApplication;
        } catch (Exception e) {
          throw new ApiException(e);
        }
      });
  }

  @PostMapping(value = "/{proposalId}/sendDocs")
  public Optional<DocRequestResponse> sendDocs(@PathVariable Long proposalId, @RequestBody SendDocRequest docRequest, @AuthenticationPrincipal UserAccountDetails details) {

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
  public Optional<String> checkLoanStatus(@PathVariable Long proposalId) {
    return getLockedProposal(proposalId)
      .map(proposal -> installAgreementService.getLoanStatus(proposal.getProjectId(), proposal.getProposalNbr()));
  }

  private Optional<Proposal> getLockedProposal(@NonNull Long proposalId) {
    return proposalService.getProposal(proposalId)
      .map(proposal -> {
        if (!proposal.isLocked()) {
          throw new ApiException("Proposal must be locked to continue");
        }
        return proposal;
      });
  }

  @GetMapping(value = "/{proposalId}/template")
  public Optional<ProposalTemplate> getProposalTemplate(@PathVariable Long proposalId, @Parameter(hidden = true) @RequestParam(value = "templateId", defaultValue = "1") Long templateId, @Parameter(hidden = true) @RequestParam(value = "type", defaultValue = "MOBILE") ProposalGeneratedType proposalGeneratedType, @Parameter(hidden = true) @RequestParam(value = "debug", defaultValue = "false") boolean isDebug) {
    return proposalService.getProposalTemplate(proposalId, templateId, proposalGeneratedType, isDebug);
  }

  @Timed
  @GetMapping(value = "/{proposalId}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
  public ResponseEntity<StreamingResponseBody> getProposalTemplatePdf(@PathVariable Long proposalId,
                                                                      @Parameter(hidden = true) @RequestParam(value = "templateId", defaultValue = "1") Long templateId,
                                                                      @RequestParam(value = "inline", defaultValue = "false") boolean inline,
                                                                      HttpServletResponse response) {

    final Proposal proposal = proposalService.getProposal(proposalId)
      .orElseThrow(() -> new NotFoundException("Proposal not found"));

    final String contentDisposition = String.format(
      "%s; filename=\"proposal_%s.pdf\"", inline ? "inline" : "attachment", proposal.getProposalNbr());

    response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE);
    response.addHeader(HttpHeaders.CONTENT_DISPOSITION, contentDisposition);

    final StreamingResponseBody responseBody = outputStream -> proposalService.generateProposalPDF(proposalId, templateId, false)
      .ifPresent(result -> {
        try {
          response.addHeader(HttpHeaders.CONTENT_LENGTH, result.getContentLength().toString());
          IOUtils.copy(result.getInputStream(), outputStream);
        } catch (IOException e) {
          throw new ApiException(e);
        }
      });

    return ResponseEntity.ok(responseBody);
  }

  @PostMapping
  public Optional<Proposal> addProposal(@RequestBody Proposal proposal, @AuthenticationPrincipal UserAccountDetails details) {
    return proposalService.addProposal(proposal, details);
  }

  @GetMapping(value = "/{proposalId}/filter")
  public ProposalFilterResponse getFilterableOptions(@PathVariable Long proposalId, ProposalValueFilter filter) {
    final Proposal proposal = proposalService.getProposal(proposalId).orElseThrow(NotFoundException::new);

    final List<Long> filterIds = proposalVersionService.getProposalValuesFilterIds(proposal.getProposalVersionId(), filter);
    return new ProposalFilterResponse(filterIds);
  }

  public record SendDocRequest(@NotNull LoanDocType docType, boolean isSpanish) {
  }

  public record ProposalFilterResponse(List<Long> ids) {
  }

  public record DocRequestResponse(boolean success, String message) {
  }

  public record ProposalNameUpdateRequest(@NotBlank String name) {
  }

  @Data
  public static class DesignRequest {
    private Long projectId;
    private String description, dueDate;
    private List<Attachment> attachments;
  }
}
