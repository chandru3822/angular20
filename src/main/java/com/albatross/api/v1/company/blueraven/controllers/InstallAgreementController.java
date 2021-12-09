package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementRequest;
import com.albatross.api.v1.company.blueraven.repository.InstallAgreementRepository;
import com.albatross.api.v1.company.blueraven.services.GoodleapService;
import com.albatross.api.v1.company.blueraven.services.SunlightService;
import com.albatross.api.v1.flow.model.Contact;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@RestController
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/company/blueraven/install-agreement")
public class InstallAgreementController {

  private final InstallAgreementRepository installAgreementRepository;

  private final GoodleapService goodleapService;

  private final SunlightService sunlightService;

  @Autowired
  private SqlCache sqlCache;

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
  public ResponseEntity<Object> generate(@PathVariable Long projectId, @PathVariable Long proposalNbr, @RequestParam(required = false) String sendVia) throws Exception {
    try {
      return ResponseEntity.ok(installAgreementRepository.generateLoanApplication(projectId, proposalNbr, sendVia));
    } catch (Exception e) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, e.getMessage(), new Exception());
    }
  }

  @PutMapping(value = "/updateEmailAddress/{projectId}")
  public void updateEmailAddress(@PathVariable Long projectId, @RequestBody Contact contact) {
      installAgreementRepository.updateEmailAddress(projectId, contact.getEmail());
  }

  @GetMapping(value = "/loanStatus/{projectId}/{proposalNbr}")
  public ResponseEntity<Object> getLoanStatus(@PathVariable String projectId, @PathVariable String proposalNbr) {
    try {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", Long.valueOf(projectId));
      params.put("proposalNbr", Long.valueOf(proposalNbr));
      Optional<Object> loanType = sqlCache.get("installAgreement.getLoanType", params, new SingleColumnRowMapper<>(Object.class));

      if (loanType.isPresent()) {
        String loan = loanType.get().toString();
        if (loan.contains("LoanPal")) {
          JSONObject loanApp = goodleapService.getApplicationByProjectId(Long.parseLong(projectId));
          return ResponseEntity.ok(loanApp.toString());
        }
        else if (loan.contains("Sunlight")) {
          JSONObject sunlightApp = sunlightService.getApplicationByProjectId(Long.parseLong(projectId));
          return ResponseEntity.ok(sunlightApp.toString());
        }
      }
    } catch (Exception e) {
      log.warn("IARQ: Installation agreement: Failed to get loan status: {}", e.getMessage());
      if (e.getMessage().contains("locate")) {
        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Loan application was not found.", new Exception());
      }
      else {
        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown Error Occurred", new Exception());
      }
    }
    throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Loan application was not found.", new Exception());
  }

  @Deprecated //  I believe this isn't used anywhere
  @GetMapping(value = "/loanStatus/{projectId}")
  public ResponseEntity<Object> getLoanStatus(@PathVariable String projectId) {
      try {
        JSONObject loanApp = goodleapService.getApplicationByProjectId(Long.parseLong(projectId));
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
