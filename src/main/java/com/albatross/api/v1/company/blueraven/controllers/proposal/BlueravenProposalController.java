package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalValueFilter;
import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.company.blueraven.models.Proposal;
import com.albatross.api.v1.company.blueraven.models.ProposalDesign;
import com.albatross.api.v1.company.blueraven.models.ProposalProject;
import com.albatross.api.v1.flow.model.Attachment;
import freemarker.template.TemplateException;
import io.micrometer.core.annotation.Timed;
import io.swagger.v3.oas.annotations.Parameter;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(
    value = "/api/v1/company/blueraven/proposal",
    produces = MediaType.APPLICATION_JSON_VALUE)
public class BlueravenProposalController {

  private final BlueravenProposalService proposalService;
  private final ProposalTemplateService proposalTemplateService;
  private final ProposalVersionService proposalVersionService;

  @GetMapping(value = "/projects")
  public Page<ProposalProject> getProposalProjects(@RequestParam String query, Pageable pageable) {
    return proposalService.getProposalProjects(query, pageable);
  }

  @GetMapping(value = "/designs/{projectId}")
  public List<ProposalDesign> getProposalDesigns(@PathVariable Long projectId) {
    return proposalService.getProposalDesigns(projectId);
  }

  @GetMapping(value = "/design/{projectId}/active")
  public Optional<ProposalDesign> getActiveDesign(@PathVariable Long projectId) {
    return proposalService.getActiveDesign(projectId);
  }

  @PostMapping(value = "/design")
  public List<ProposalDesign> requestNewDesign(
      @RequestParam Long projectId,
      @RequestParam String description,
      @RequestParam String dueDate,
      @RequestParam(required = false) List<MultipartFile> attachments,
      @RequestParam(required = false) List<MultipartFile> utilityBillAttachments)
      throws IOException {
    return proposalService.requestNewDesign(
        projectId, description, dueDate, attachments, utilityBillAttachments);
  }

  @GetMapping(value = "/{proposalId}")
  public Optional<Proposal> getProposal(@PathVariable Long proposalId) {
    return proposalService.getProposal(proposalId);
  }

  @PostMapping(value = "/{proposalId}")
  public Optional<Proposal> updateProposalCustomFieldValues(
      @PathVariable Long proposalId, @RequestBody List<CustomFieldValue> cfvs) {
    return proposalService.updateProposal(proposalId, cfvs);
  }

  @GetMapping(value = "/{proposalId}/template")
  public ProposalTemplate getProposalTemplate(
      @PathVariable Long proposalId,
      @Parameter(hidden = true) @RequestParam(value = "templateId", defaultValue = "1")
          Long templateId) {
    final var context = proposalService.getCalculatedProposalValues(proposalId, false);
    return proposalTemplateService.getTemplateById(templateId, context);
  }

  @Timed
  @GetMapping(value = "/{proposalId}/pdf", produces = MediaType.APPLICATION_PDF_VALUE)
  public ResponseEntity<StreamingResponseBody> getProposalTemplatePdf(
      @PathVariable Long proposalId,
      @Parameter(hidden = true) @RequestParam(value = "templateId", defaultValue = "1")
          Long templateId,
      @RequestParam(value = "inline", defaultValue = "false") boolean inline,
      HttpServletResponse response) {

    final String contentDisposition =
        String.format("%s; filename=\"proposal.pdf\"", inline ? "inline" : "attachment");

    response.addHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PDF_VALUE);
    response.addHeader(HttpHeaders.CONTENT_DISPOSITION, contentDisposition);

    final StreamingResponseBody responseBody =
        outputStream -> {
          final var context = proposalService.getCalculatedProposalValues(proposalId, false);
          try {
            proposalTemplateService.generatePdf(
                templateId,
                context,
                outputStream,
                contentLength ->
                    response.addHeader(HttpHeaders.CONTENT_LENGTH, contentLength.toString()));
          } catch (TemplateException e) {
            log.error("[Proposal] Error generating PDF", e);
            throw new ApiException("Error generating PDF");
          }
        };

    return ResponseEntity.ok(responseBody);
  }

  @PostMapping(value = "")
  public Optional<Proposal> addProposal(@RequestBody Proposal proposal) {
    return proposalService.addProposal(proposal);
  }

  @GetMapping(value="/{proposalId}/filter")
  public ProposalFilterResponse getFilterableOptions(
      @PathVariable Long proposalId, ProposalValueFilter filter) {
    final Proposal proposal =
        proposalService.getProposal(proposalId).orElseThrow(NotFoundException::new);

    final List<Long> filterIds = proposalVersionService.getProposalValuesFilterIds(proposal.getProposalVersionId(), filter);
    return new ProposalFilterResponse(filterIds);
  }

  public record ProposalFilterResponse (List<Long> ids){ }

  @Data
  public static class DesignRequest {
    private Long projectId;
    private String description, dueDate;
    private List<Attachment> attachments;
  }
}
