package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementRequest;
import com.albatross.api.v1.company.blueraven.repository.InstallAgreementRepository;

import com.albatross.api.v1.company.blueraven.services.LoanPalService;
import com.albatross.api.v1.flow.model.Contact;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@RestController
@Slf4j
@RequestMapping(value = "/api/v1/company/blueraven/install-agreement")
public class InstallAgreementController {

  @Autowired
  InstallAgreementRepository installAgreementRepository;

  @Autowired
  private LoanPalService loanPalService;

  @GetMapping(value = "/projects")
  public Page<InstallAgreementProject> getProjects(@RequestParam String query, Pageable pageable) {
    return installAgreementRepository.getProjects(query, pageable);
  }

  @PostMapping(value = "/create")
  public ResponseEntity<String> saveRequest(@RequestBody InstallAgreementRequest request) {
      JSONObject result = new JSONObject();
      try {
        String resultMsg = installAgreementRepository.saveRequest(request);
        if (resultMsg == null || resultMsg.equals(StringUtils.EMPTY)) {
            request.setRequest_successful(true);
            installAgreementRepository.setRequestStatus(request);
            result.put("message", "Request successfully submitted");
            return ResponseEntity.ok(result.toString());
        }
        else {
            request.setRequest_successful(false);
            installAgreementRepository.setRequestStatus(request);
            result.put("message", resultMsg);
            return ResponseEntity.badRequest().body(result.toString());
        }
    } catch (Exception e) {
        result.put("message", e.getMessage());
        return ResponseEntity.badRequest().body(result.toString());
    }
  }

  @GetMapping(value = "/getProposalNumbers/{projectId}")
  public List<InstallAgreementRepository.ProposalInfo> getProposalNumbers(@PathVariable Long projectId) {
      return installAgreementRepository.getProposalNumbers(projectId);
  }

  @GetMapping(value = "/generate/{projectId}/{proposalNbr}")
  public String generate(@PathVariable Long projectId, @PathVariable Long proposalNbr) {
      return installAgreementRepository.generateLoanPal(projectId, proposalNbr);
  }

  @PutMapping(value = "/updateEmailAddress/{projectId}")
  public void updateEmailAddress(@PathVariable Long projectId, @RequestBody Contact contact) {
          installAgreementRepository.updateEmailAddress(projectId, contact.getEmail());
  }

  @GetMapping(value = "/loanStatus/{projectId}")
  public ResponseEntity<Object> getLoanStatus(@PathVariable String projectId) {
      try {
          JSONObject loanApp = loanPalService.getApplicationByProjectId(projectId);
          return ResponseEntity.ok(loanApp.toString());
      } catch (Exception e) {
          log.warn("IARQ: Installation agreement: Failed to get loan status: {}", e.getMessage());
          if (e.getMessage().contains("locate")) {
              throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Loan application was not found.", new Exception());
          }
          else {
              throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown Error Occurred", new Exception());
          }
      }
  }
}
