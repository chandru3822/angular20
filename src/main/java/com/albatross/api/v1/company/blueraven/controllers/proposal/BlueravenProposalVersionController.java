package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.v1.company.blueraven.controllers.proposal.models.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


@Slf4j
@Validated
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/proposal/versions")
@RequiredArgsConstructor
@PreAuthorize("hasCompanyAccess(3)")
public class BlueravenProposalVersionController {
  private final ProposalVersionService proposalVersionService;

  @PostMapping
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public ResponseEntity<ProposalVersion> createProposalVersion() {
    return ResponseEntity.of(proposalVersionService.createProposalVersion());
  }

  @GetMapping
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN', 'PROPOSALS_MANAGE')")
  public Page<ProposalVersion> getProposalVersions(
    @RequestParam(name = "published", defaultValue = "false") Boolean publishedOnly,
    Pageable pageable) {
    return proposalVersionService.getProposalVersions(pageable, publishedOnly);
  }

  @GetMapping(value = "/{id}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public Optional<ProposalVersion> getProposalVersion(@PathVariable Long id) {
    return proposalVersionService.getProposalVersion(id);
  }

  @PostMapping(value = "/{id}/publish")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public Optional<ProposalVersion> publishProposalVersion(@PathVariable Long id, @Valid @RequestBody ProposalPublishRequest request) {
    return proposalVersionService.publishProposalVersion(id, request.message());
  }

  @GetMapping(value="/{id}/history")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public ProposalVersionHistoryChangeSet getProposalVersionHistory(@PathVariable Long id){
    return proposalVersionService.getChangeHistory(id);
  }

  public record ProposalPublishRequest(@NotEmpty String message) {
  }

  @GetMapping(value = "/{id}/values/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalCustomValuesRow> getProposalCustomFieldsByObjectCode(
    @PathVariable Long id, @PathVariable String objectCode) {
    return proposalVersionService.getProposalCustomFieldValues(id, objectCode);
  }

  @PostMapping(value = "/{id}/values/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public Optional<ProposalCustomValuesRow> updateProposalCustomFieldsByObjectCode(
    @PathVariable Long id,
    @PathVariable String objectCode,
    @Valid @RequestBody final ProposalCustomGroup group) {
    return proposalVersionService.updateCustomFieldValue(id, objectCode, group);
  }

  @PostMapping(value = "/{id}/values/{objectCode}/reset")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalCustomValuesRow> undoChangesToProposalObject(
    @PathVariable Long id, @PathVariable String objectCode) {
    return proposalVersionService.resetProposalVersionByCustomFieldByObjectCode(id, objectCode);
  }

  @DeleteMapping(value = "/{id}/values/{objectCode}/{groupUUID}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public ResponseEntity<?> deleteCustomFieldGroup(
    @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    Optional<ProposalCustomValuesRow> proposalCustomValuesRow = proposalVersionService.deleteCustomFieldGroup(id, objectCode, groupUUID);
    if (proposalCustomValuesRow.isPresent()) {
      return ResponseEntity.of(proposalCustomValuesRow);
    }
    return ResponseEntity.noContent().build();
  }

  @PostMapping(value = "/{id}/values/{objectCode}/{groupUUID}/archive")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public Optional<ProposalCustomValuesRow> archiveCustomFieldGroup(
    @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    return proposalVersionService.archiveCustomFieldGroup(id, objectCode, groupUUID);
  }

  @GetMapping(value = "/types")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalObjectType> getProposalObjectTypes() {
    return proposalVersionService.getProposalTypes();
  }

  @GetMapping(value = "/fields/{objectCode}")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalFieldObjectType> getProposalCustomFieldsByObjectCode(
    @PathVariable String objectCode) {
    return proposalVersionService.getProposalFieldsByObjectCode(objectCode);
  }
}
