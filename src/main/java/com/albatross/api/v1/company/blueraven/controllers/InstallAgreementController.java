package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementRequest;
import com.albatross.api.v1.company.blueraven.services.InstallAgreementService;
import com.albatross.api.v1.flow.model.Contact;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/install-agreement")
@RequiredArgsConstructor
public class InstallAgreementController {

  private final InstallAgreementService installAgreementRepository;

  @GetMapping(value = "/projects")
  public Page<InstallAgreementProject> getProjects(@RequestParam String query, @RequestParam Boolean showCancelled, Pageable pageable) {
    return installAgreementRepository.getProjects(query, pageable, showCancelled);
  }

  @PostMapping(value = "/create")
  public ResponseEntity<String> saveRequest(@RequestBody InstallAgreementRequest request) {
    JSONObject result = new JSONObject();
    try {
      String resultMsg = installAgreementRepository.saveRequest(request);
      if (resultMsg == null || resultMsg.equals(StringUtils.EMPTY)) {
        result.put("message", "Request successfully submitted");
        return ResponseEntity.ok(result.toString());
      } else {
        result.put("message", resultMsg);
        return ResponseEntity.badRequest().body(result.toString());
      }
    } catch (Exception e) {
      result.put("message", e.getMessage());
      return ResponseEntity.badRequest().body(result.toString());
    }
  }

  @GetMapping(value = "/getProposalNumbers/{projectId}")
  public List<InstallAgreementService.ProposalInfo> getProposalNumbers(
      @PathVariable Long projectId) {
    return installAgreementRepository.getProposalNumbers(projectId);
  }

  @GetMapping(value = "/generate/{projectId}/{proposalNbr}")
  public ResponseEntity<Object> generate(
      @PathVariable Long projectId,
      @PathVariable Long proposalNbr,
      @RequestParam(required = false) String sendVia)
      throws Exception {
    try {
      return ResponseEntity.ok(installAgreementRepository.generateLoanApplication(projectId, proposalNbr, sendVia));
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage(), new Exception());
    }
  }

  @PostMapping(value = "/updateSunpowerApp/{projectId}/{proposalNbr}")
  public ResponseEntity<Object> updateSunpowerApp(
      @PathVariable Long projectId, @PathVariable Long proposalNbr) {
    final Map<String, String> message = installAgreementRepository.updateSunpowerApplication(projectId, proposalNbr);
    return ResponseEntity.ok(message);
  }

  @PutMapping(value = "/updateEmailAddress/{projectId}")
  public void updateEmailAddress(@PathVariable Long projectId, @RequestBody Contact contact) {
    installAgreementRepository.updateEmailAddress(projectId, contact.getEmail());
  }

  @GetMapping(value = "/loanStatus/{projectId}/{proposalNbr}")
  public ResponseEntity<Object> getLoanStatus(
      @PathVariable Long projectId, @PathVariable Long proposalNbr) {
      final String loanStatus = installAgreementRepository.getLoanStatus(projectId, proposalNbr);
      return ResponseEntity.ok(loanStatus);
  }

  @Deprecated //  I believe this isn't used anywhere
  @GetMapping(value = "/loanStatus/{projectId}")
  public ResponseEntity<Object> getLoanStatus(@PathVariable Long projectId) {
    final String loanStatus = installAgreementRepository.getLoanStatus(projectId);
    return ResponseEntity.ok(loanStatus);
  }
}
