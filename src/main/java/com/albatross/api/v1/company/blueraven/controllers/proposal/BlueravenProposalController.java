package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.v1.company.blueraven.models.CustomFieldValue;
import com.albatross.api.v1.company.blueraven.models.Proposal;
import com.albatross.api.v1.company.blueraven.models.ProposalDesign;
import com.albatross.api.v1.company.blueraven.models.ProposalProject;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/proposal")
public class BlueravenProposalController {

  private final BlueravenProposalService proposalService;

  @GetMapping(value = "/projects", produces = MediaType.APPLICATION_JSON_VALUE)
  public Page<ProposalProject> getProposalProjects(@RequestParam String query, Pageable pageable) {
    return proposalService.getProposalProjects(query, pageable);
  }

  @GetMapping(value = "/designs/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProposalDesign> getProposalDesigns(@PathVariable Long projectId) {
    return proposalService.getProposalDesigns(projectId);
  }

  @GetMapping(value = "/{proposalId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Proposal> getProposal(@PathVariable Long proposalId) {
    return proposalService.getProposal(proposalId);
  }

  @PostMapping(value = "/{proposalId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Proposal> updateProposalCustomFieldValues(@PathVariable Long proposalId,
                                                            @RequestBody List<CustomFieldValue> cfvs) {
    return proposalService.updateProposal(proposalId, cfvs);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Proposal> addProposal(@RequestBody Proposal proposal) {
    return proposalService.addProposal(proposal);
  }

}
