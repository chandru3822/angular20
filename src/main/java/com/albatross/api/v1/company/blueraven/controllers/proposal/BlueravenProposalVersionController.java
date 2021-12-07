package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.v1.company.blueraven.controllers.proposal.models.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/proposals")
@RequiredArgsConstructor
public class BlueravenProposalVersionController {
  private final ProposalVersionService proposalVersionService;

  @PostMapping
  public ResponseEntity<ProposalVersion> createProposalVersion() {
    return ResponseEntity.of(proposalVersionService.createProposalVersion());
  }

  @GetMapping
  public Page<ProposalVersion> getProposalVersions(Pageable pageable) {
    return proposalVersionService.getProposalVersions(pageable);
  }

  @GetMapping(value = "/{id}")
  public Optional<ProposalVersion> getProposalVersion(@PathVariable Long id) {
    return proposalVersionService.getProposalVersion(id);
  }

  @PostMapping(value = "/{id}/publish")
  public Optional<ProposalVersion> publishProposalVersion(@PathVariable Long id) {
    return proposalVersionService.publishProposalVersion(id);
  }

  @GetMapping(value = "/{id}/values/{objectCode}")
  public List<ProposalCustomValuesRow> getProposalCustomFieldsByObjectCode(
      @PathVariable Long id, @PathVariable String objectCode) {
    return proposalVersionService.getProposalCustomFieldValues(id, objectCode);
  }

  @PostMapping(value = "/{id}/values/{objectCode}")
  public Optional<ProposalCustomValuesRow> updateProposalCustomFieldsByObjectCode(
      @PathVariable Long id,
      @PathVariable String objectCode,
      @Valid @RequestBody final ProposalCustomGroup group) {
    return proposalVersionService.updateCustomFieldValue(id, objectCode, group);
  }

//  @PostMapping(value = "/{id}/values/{objectCode}/reset")
//  public void undoChangesToProposalObject(@PathVariable Long id, @PathVariable String objectCode){
//
//  }


  @DeleteMapping(value = "/{id}/values/{objectCode}/{groupUUID}")
  public Optional<ProposalCustomValuesRow> deleteCustomFieldGroup(
      @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    return proposalVersionService.deleteCustomFieldGroup(id, objectCode, groupUUID);
  }

  @PostMapping(value = "/{id}/values/{objectCode}/{groupUUID}/archive")
  public Optional<ProposalCustomValuesRow> archiveCustomFieldGroup(
    @PathVariable Long id, @PathVariable String objectCode, @PathVariable UUID groupUUID) {
    return proposalVersionService.archiveCustomFieldGroup(id, objectCode, groupUUID);
  }

  @GetMapping(value = "/types")
  public List<ProposalObjectType> getProposalObjectTypes() {
    return proposalVersionService.getProposalTypes();
  }

  @GetMapping(value = "/fields/{objectCode}")
  public List<ProposalFieldObjectType> getProposalCustomFieldsByObjectCode(
      @PathVariable(name = "objectCode") String objectCode) {
    return proposalVersionService.getProposalFieldsByObjectCode(objectCode);
  }
}
