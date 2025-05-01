package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTag;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateObjectCategory;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping(
  value = "/api/v1/company/blueraven/proposal/template",
  produces = MediaType.APPLICATION_JSON_VALUE)
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccess('PROPOSALS')")
@RequiredArgsConstructor
public class ProposalTemplateController {
  private final ProposalTemplateService proposalTemplateService;

  @GetMapping
  public List<ProposalTemplate> getTemplates() {
    return proposalTemplateService.getTemplates();
  }

  @GetMapping(value = "/{templateId}")
  public Optional<ProposalTemplate> getTemplateDetailById(@PathVariable Long templateId) {
    return proposalTemplateService.getTemplateById(templateId);
  }

  @PostMapping(value = "/{templateId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public void updateTemplateById(@PathVariable Long templateId) {
    proposalTemplateService.updateTemplate(templateId);
  }

  @PostMapping(value = "/{templateId}/blocks")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalTemplateBlock> updateTemplateBlocks(
    @PathVariable Long templateId,
    @RequestBody UpdateTemplateBlockRequest update,
    @AuthenticationPrincipal UserAccountDetails details) {

    return proposalTemplateService.updateTemplateBlocks(
      templateId, update.blocks, details.getTrueUserId());
  }

  @PostMapping(value = "/{templateId}/blocks/duplicate/{blockId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalTemplateBlock> duplicateTemplateBlock(
          @PathVariable Long templateId,
          @PathVariable Integer blockId,
          @AuthenticationPrincipal UserAccountDetails details
  ) {
      return proposalTemplateService.duplicateTemplateBlock(templateId, blockId, details.getTrueUserId(), null);
  }

  @DeleteMapping(value = "/{templateId}/blocks/{blockId}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<Integer> archiveBlockFromTemplate(
    @PathVariable Long templateId,
    @PathVariable Integer blockId,
    @AuthenticationPrincipal UserAccountDetails details
  ) {
    return proposalTemplateService.archiveBlockFromTemplate(templateId, blockId, details.getTrueUserId());
  }

  @GetMapping(value = "/{templateId}/tags")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalTag> getTemplateTags(@PathVariable Long templateId) {
    return proposalTemplateService.getAvailableTags(templateId);
  }

  @PostMapping(value = "/{templateId}/objectCategories")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public void updateObjectCategories(@PathVariable Long templateId, @RequestBody UpdateTemplateObjectCategories req, @AuthenticationPrincipal UserAccountDetails details) {
    proposalTemplateService.updateTemplateObjectCategories(templateId, req.objectCategoryIds(), details.getTrueUserId());
  }

  @GetMapping(value = "/objectCategories")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalTemplateObjectCategory> getObjectCategories() {
    return proposalTemplateService.getObjectCategories();
  }

  public record UpdateTemplateObjectCategories(List<Long> objectCategoryIds) {
  }

  public record UpdateTemplateBlockRequest(List<ProposalTemplateBlock> blocks) {
  }
}
