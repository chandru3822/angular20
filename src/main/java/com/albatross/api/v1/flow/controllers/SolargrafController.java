package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.services.SolargrafProjectRequest;
import com.albatross.api.v1.company.blueraven.services.SolargrafProjectResponse;
import com.albatross.api.v1.flow.services.SolargrafService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/flow/solargraf")
public class SolargrafController {

  @Autowired
  private SolargrafService solargrafService;

  @PostMapping("/projects")
  public ResponseEntity<SolargrafProjectResponse> createProject(@RequestBody SolargrafProjectRequest request) {
    SolargrafProjectResponse response = solargrafService.createProject(request);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/proposals/clone/{originalProposalId}")
  public ResponseEntity<SolargrafProjectResponse> cloneProposal(
    @PathVariable String originalProposalId,
    @RequestBody SolargrafProjectRequest newProjectData) {
    SolargrafProjectResponse response = solargrafService.cloneProposal(originalProposalId, newProjectData);
    return ResponseEntity.ok(response);
  }

  @PostMapping("/proposals/clone/by-project/{projectId}")
  public ResponseEntity<SolargrafProjectResponse> cloneProposalByProject(
    @PathVariable Long projectId,
    @RequestBody SolargrafProjectRequest newProjectData) {
    SolargrafProjectResponse response = solargrafService.cloneProposalFromCustomField(projectId, newProjectData);
    return ResponseEntity.ok(response);
  }
}
