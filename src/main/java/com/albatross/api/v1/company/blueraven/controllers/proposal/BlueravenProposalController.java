package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.company.blueraven.models.Proposal;
import com.albatross.api.v1.company.blueraven.models.ProposalDesign;
import com.albatross.api.v1.company.blueraven.models.ProposalProject;
import com.albatross.api.v1.flow.model.Attachment;
import com.google.common.net.HttpHeaders;
import freemarker.template.TemplateException;
import io.swagger.v3.oas.annotations.Parameter;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
      @RequestParam(required = false) List<MultipartFile> attachments)
      throws IOException {
    return proposalService.requestNewDesign(projectId, description, dueDate, attachments);
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

  @GetMapping(value = "/{proposalId}/pdf")
  public void getProposalTemplatePdf(
      @PathVariable Long proposalId,
      @Parameter(hidden = true) @RequestParam(value = "templateId", defaultValue = "1")
          Long templateId,
      @RequestParam(value = "inline", defaultValue = "false") boolean inline,
      HttpServletResponse response)
      throws IOException, TemplateException {

    response.addHeader(
        HttpHeaders.CONTENT_DISPOSITION,
        String.format("%s; filename=\"preview.pdf\"", inline ? "inline" : "attachment"));

    final var context = proposalService.getCalculatedProposalValues(proposalId, false);
    proposalTemplateService.generatePdf(templateId, context, response.getOutputStream());
  }

  @PostMapping(value = "")
  public Optional<Proposal> addProposal(@RequestBody Proposal proposal) {
    return proposalService.addProposal(proposal);
  }

  @Data
  public static class DesignRequest {
    private Long projectId;
    private String description, dueDate;
    private List<Attachment> attachments;
  }
}
