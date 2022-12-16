package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTag;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping(
    value = "/api/v1/company/blueraven/proposal/template",
    produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class ProposalTemplateController {
  private final ProposalTemplateService proposalTemplateService;

  @GetMapping(value = "/{templateId}")
  public Optional<ProposalTemplate> getTemplateDetailById(@PathVariable Long templateId) {
    return proposalTemplateService.getTemplateById(templateId);
  }

  @PostMapping(value = "/{templateId}")
  public void updateTemplateById(@PathVariable Long templateId) {
    proposalTemplateService.updateTemplate(templateId);
  }

  @PostMapping(value = "/{templateId}/blocks")
  public List<ProposalTemplateBlock> updateTemplateBlocks(
      @PathVariable Long templateId,
      @RequestBody UpdateTemplateBlockRequest update,
      @AuthenticationPrincipal UserAccountDetails details) {

    return proposalTemplateService.updateTemplateBlocks(
        templateId, update.blocks, details.getTrueUserId());
  }

  @GetMapping(value = "/tags")
  public List<ProposalTag> getTemplateTags() {
    return proposalTemplateService.getAvailableTags();
  }

  public record UpdateTemplateBlockRequest(List<ProposalTemplateBlock> blocks) {}
}
