package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Proposal;
import com.albatross.api.v1.flow.services.ProposalService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/propTool/proposal")
public class ProposalController {

  private final ProposalService proposalService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Proposal> getProposalsForCompany() {
    return proposalService.getProposalsForCompany();
  }

  @GetMapping(value= "/{proposalId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Proposal> getProposal(@PathVariable Long proposalId) {
    return proposalService.getProposal(proposalId);
  }

  @GetMapping(value= "/search", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<Page<Proposal>> searchProjects(@RequestParam String query, Pageable pageable) {
    return new ResponseEntity<>(proposalService.searchProposals(query, pageable), HttpStatus.OK);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Proposal> generateProposal(@RequestBody Proposal prop) {
    return proposalService.generateProposal(prop);
  }

  @PostMapping(value = "/export", produces = "text/csv")
  public ResponseEntity exportProposalLog(@RequestBody Map<String, String> requestData) {
    return proposalService.exportProposalLog(requestData.get("startDate"), requestData.get("endDate"));
  }

}
