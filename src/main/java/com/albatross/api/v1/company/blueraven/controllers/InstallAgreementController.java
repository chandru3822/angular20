package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementRequest;
import com.albatross.api.v1.company.blueraven.repository.InstallAgreementRepository;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/install-agreement")
public class InstallAgreementController {

  @Autowired
  InstallAgreementRepository installAgreementRepository;

  @GetMapping(value = "/projects")
  public Page<InstallAgreementProject> getProjects(@RequestParam String query, Pageable pageable) {
    return installAgreementRepository.getProjects(query, pageable);
  }

  @PostMapping(value = "/create")
  public ResponseEntity saveRequest(@RequestBody InstallAgreementRequest request) throws Exception {
    String resultMsg = installAgreementRepository.saveRequest(request);

    if (resultMsg == null || resultMsg.equals(StringUtils.EMPTY)) {
        request.setRequest_successful(true);
        installAgreementRepository.setRequestStatus(request);
        return ResponseEntity.ok("Request submitted");
    }
    else {
        request.setRequest_successful(false);
        installAgreementRepository.setRequestStatus(request);
        return ResponseEntity.badRequest().body(resultMsg);
    }
  }

  @GetMapping(value = "/getProposalNumbers/{projectId}")
  public List<InstallAgreementRepository.ProposalNumber> getProposalNumbers(@PathVariable Long projectId) {
      return installAgreementRepository.getProposalNumbers(projectId);
  }

  @GetMapping(value = "/generate/{projectId}/{proposalNbr}")
  public String generate(@PathVariable Long projectId, @PathVariable Long proposalNbr) {
      return installAgreementRepository.generateLoanPal(projectId, proposalNbr);
  }
}
