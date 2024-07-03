package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.queries.InstallAgreementQuery;
import com.albatross.api.v1.company.blueraven.services.queries.PandaDocQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.TimeoutException;

@Slf4j
@Service
@PreAuthorize("hasFeatureAccess('INSTALLATION_AGREEMENT') || isBrSystemUser()")
@RequiredArgsConstructor
public class InstallAgreementService {
  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final EnFinService enFinService;

  private final MosaicService mosaicService;

  private final SunlightService sunlightService;

  private final SunpowerService sunpowerService;

  private final PandaDocService pandaDocService;

  private final GoodleapService goodleapService;

  @Value(value = "${sunlight.api.portal}")
  private String sunlightPortalUrl;

  @Value(value = "${app.goodleap.newLoanUrl}")
  private String goodleapNewLoanUrl;

  @Value("${app.srec.host}")
  private String srecHost;

  @Value("${app.srec.token}")
  private String srecToken;

  public Page<InstallAgreementProject> getProjects(String query, Pageable pageable, Boolean showCancelled) {
    User user = securityService.getCurrentUser();
    Boolean viewAll =
      securityService.userHasFeatureAccessLevel(
        user.getId(),
        user.getCompanyId(),
        user.getHighestCompanyId(),
        "INSTALLATION_AGREEMENT",
        List.of("VIEW_ALL"));
    HashMap<String, Object> params = new HashMap<>();
    params.put("view_all", viewAll);
    params.put("user_id", user.getId());
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());
    params.put("showCancelled", showCancelled);

    List<InstallAgreementProject> results =
      sqlCache.queryBySql(InstallAgreementQuery.getProjects, params, InstallAgreementProject.class);
    Integer count =
      sqlCache.queryForObjectBySql(InstallAgreementQuery.getProjectsCount, params, Integer.class);

    return new PageImpl<>(
      results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  private Optional<PropLogDetail> getProjectDetailsFromLog(@NonNull Long projectId, @NonNull Long proposalNbr) {
    final Map<String, Object> params = Map.of("projectId", projectId, "proposalNbr", proposalNbr);
    return sqlCache.getBySql(InstallAgreementQuery.getProjectDetailsFromLog, params, InstallAgreementService.PropLogDetail.class);
  }

  public String saveRequest(InstallAgreementRequest request) throws Exception {
    // first create disclosure doc through SREC
    var srecSuccessful = sendDisclosureDoc(request.getProjectId(), request.getProposalNbr());

    if (!srecSuccessful) {
      throw new RuntimeException("Unable to create disclosure document");
    }

    final String result = createRequest(request);
    if (result == null || result.trim().isEmpty()) {
      request.setRequest_successful(true);
    } else {
      request.setRequest_successful(false);
    }

    User user = securityService.getCurrentUser();
    setRequestStatus(request, user.getId());

    return result;
  }

  private boolean sendDisclosureDoc(Long projectId, Long proposalNumber) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNumber", proposalNumber);

    Srec srec = sqlCache.getBySql(InstallAgreementQuery.getSrec, params, Srec.class)
      .orElse(null);

    // create disclosure doc only if all the following are met:
    // - there is a proposal
    // - a disclosure form wasn't already created
    // - proposal is IL SREC
    // - project is in Illinois
    if (
      srec == null ||
      srec.getIlSrecDisclosureFormId() != null ||
      srec.getSrecValue() == null ||
      !Objects.equals(srec.getProjectStateAbbreviation(), "IL")) {
      return true;
    }

    boolean successfullySent = false;
    boolean isFinanced = !srec.getLoanType().toLowerCase().contains("cash");

    var body = new SrecDTO();
    body.setFormName(srec.getProposalNumber() + " " + srec.getContactName() + " " + srec.getProjectId());
    body.setCustomerName(srec.getProjectName());
    body.setCustomerAddressEmail(srec.getContactEmail());
    body.setCustomerAddressPhone(srec.getContactPhone());
    body.setCustomerAddress1(srec.getProjectStreet1());
    body.setCustomerAddressZip(srec.getProjectPostalCode());
    body.setCustomerAddressCity(srec.getProjectCity());
    body.setCustomerAddressState(srec.getProjectStateAbbreviation());

    body.setElectricUtility(srec.getUtilityCompanyName());

    //Naperville users qualify as municipal utility, which is what the external API accepts
    if (body.getElectricUtility().equalsIgnoreCase("Naperville Electric Utility")) {
      body.setElectricUtility("Municipal Utility");
    }

    body.setDepositOwed(srec.getTotalCost());
    body.setReferenceNumber(srec.getProjectId().toString());

    var systemSizeKw = new BigDecimal(srec.getSystemSize()).divide(new BigDecimal(1000));
    var systemSizeAcKw = new BigDecimal(srec.getSystemSizeAc()).divide(new BigDecimal(1000));

    body.setProjectSizeKwDc(systemSizeKw.toString());
    body.setProjectSizeKwAc(systemSizeAcKw.toString());
    body.setGrossElectricProduction(srec.getYearOneKwhOutput());

    var srecValue = new BigDecimal(srec.getSrecValue().toString()).divide(new BigDecimal("0.9"), 2, RoundingMode.HALF_UP);

    body.setExpectedRecValue(srecValue.toString());
    body.setRecCustomerPayment(srec.getSrecValue().toString());

    if (isFinanced) {
      body.setFinalAmountOwed("0");
      body.setFinalPaymentDue("N/A");
      body.setInstallationOwed("0");
      body.setInitialDepositOwed(srec.getTotalCost());
    } else {
      Long halfTotalCost = Long.parseLong(srec.getTotalCost()) / 2;

      body.setFinalAmountOwed(halfTotalCost.toString());
      body.setFinalPaymentDue("Upon Substantial Completion");
      body.setInstallationOwed(halfTotalCost.toString());
      body.setInitialDepositOwed("0");
    }

    try {
      WebClient client = WebClient.create(srecHost);
      ResponseEntity<String> res = client
        .post()
        .uri("/create_disclosure_dg/")
        .header("Authorization", "Token " + srecToken)
        .body(Mono.just(body), SrecDTO.class)
        .retrieve()
        .toEntity(String.class)
        .timeout(Duration.ofSeconds(30))
        .onErrorMap(TimeoutException.class, e -> new HttpTimeoutException("HIC (SREC): Timeout issue: " + e.getMessage()))
        .block();

      JSONObject resultBody = new JSONObject(res.getBody());
      String formId = resultBody.getString("FormID");
      params.put("formId", formId);
      sqlCache.updateBySql(InstallAgreementQuery.setDisclosureId, params);

      successfullySent = true;
    } catch (WebClientResponseException e) {
      log.error("HIC (SREC): Error generating disclosure doc (" + projectId + ", " + proposalNumber + "): " + e.getMessage() + ": " + e.getResponseBodyAsString());
    } catch (Exception e) {
      log.error("HIC (SREC) (" + projectId + ", " + proposalNumber + "): " + e.getMessage());
    }

    return successfullySent;
  }

  private String createRequest(InstallAgreementRequest request) throws Exception {
    Long projectId = request.getProjectId();
    Boolean sendLoanDocs = request.getSendLoanDocs();

    // TODO: Remove when Mobile supports sendLoanDocs parameter
    if (request.getSendLoanpalDocs() != null) {
      sendLoanDocs = request.getSendLoanpalDocs();
    }

    request.validateNewRequest();
    String financier = getFinancierFromProposalLog(projectId, request.getProposalNbr());
    String resultMsg = "";

    if (sendLoanDocs && isSunlightProject(financier)) {
      // If credit is approved, send loan docs
      try {
        if (sunlightService.getCreditStatus(projectId).equals("Credit Approved")) {
          sunlightService.sendLoanDocs(projectId);
        }
      } catch (JSONException ex) {
        log.error("IARQ: Error sending finance docs via Sunlight, error={}", ex.getMessage());
        resultMsg = "Error sending finance docs through Sunlight";
      }
    } else if (sendLoanDocs && isSunpowerProject(financier)) {
      // If credit is approved, send loan docs
      try {
        sunpowerService.sendLoanDocs(projectId);
      } catch (Exception ex) {
        log.error("IARQ: Error sending finance docs via Sunpower, error={}", ex.getMessage());
        resultMsg = "Error sending finance docs through Sunpower: " + ex.getMessage();
      }
    } else if (sendLoanDocs && isGoodLeapProject(financier)) {
      Optional<InstallAgreementService.PropLogDetail> propLogDetail = getProjectDetailsFromLog(projectId, request.getProposalNbr());

      JSONObject loanApplication =
        goodleapService.getApplicationByProjectId(request.getProjectId());
      if (loanApplication != null) {
        try {
          String goodLeapId = loanApplication.getString("id");

          if (propLogDetail.isPresent()) {
            final BigDecimal propLogAmount =
              new BigDecimal(propLogDetail.get().getLoanAmount()).setScale(0, RoundingMode.DOWN);
            final BigDecimal currentAmount =
              loanApplication
                .getJSONObject("amount")
                .getBigDecimal("value")
                .setScale(0, RoundingMode.DOWN);

            if (!propLogAmount.equals(currentAmount)) {
              goodleapService.updateLoanAmount(goodLeapId, propLogDetail.get().getLoanAmount());
            }
          }

          if (loanApplication.getString("status").equals("Approved")) {
            log.debug("IARQ: sending GoodLeap Docs");
            try {
              goodleapService.sendDocs(goodLeapId);
            } catch (Exception e) {
              // @TODO: Handle failed send
            }
          }
        } catch (JSONException ex) {
          log.error("IARQ: JSON object not found, error={}", ex.getMessage());
        }
      }
    }
    else if (iEnFinProject(financier) && request.getIsSpanish()) {
      throw new RuntimeException("EnFin does not currently allow Spanish HICs. Please send an English HIC or switch financiers.");
    } else if (sendLoanDocs && isMosaicProject(financier)) {
      Optional<InstallAgreementService.PropLogDetail> propLogDetail = getProjectDetailsFromLog(projectId, request.getProposalNbr());
      mosaicService.sendLoanDocs(projectId, request.getProposalNbr(), propLogDetail.get());
    }

    Boolean createPandaDoc = true;
    try {
      if (isGoodLeapProject(financier)) {
        log.debug("IARQ: processing goodleap project {}", request);
        createPandaDoc = goodleapService.shouldCreatePandaDocs(projectId);
      }

      log.debug("IARQ: create PandaDoc? {}; project {}", createPandaDoc, projectId);
      if (createPandaDoc && (request.getSendInstallationAgreement() || request.getIsSpanish())) {
        pandaDocService.createDocument(projectId, request.getProposalNbr(), request.getIsSpanish());
      } else if (!createPandaDoc) {
        throw new RuntimeException("Loan Application Not Found. Installation Agreement not sent.");
      }
    } catch (Exception e) {
      if (e.getMessage().contains("locate")) {
        log.warn(
          "IARQ: Unable to locate goodleap application for project ID: %s".formatted(projectId));
        throw new RuntimeException(e);
      } else {
        if (!resultMsg.isEmpty()) {
          resultMsg += ". ";
        }
        resultMsg += e.getMessage();
      }
    }

    return resultMsg;
  }

  public Boolean isCashProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("cash");
  }

  public Boolean isGoodLeapProject(String financier) {
    return financier != null && (financier.equalsIgnoreCase("loanpal") || financier.equalsIgnoreCase("goodleap"));
  }

  public Boolean iEnFinProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("enfin");
  }

  public Boolean isMosaicProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("mosaic");
  }

  public Boolean isSunlightProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("sunlight");
  }

  public Boolean isSunpowerProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("sunpower");
  }

  public String getFinancierFromProposalLog(Long projectId, Long proposalNbr) {
    String financier = null;

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);

    Optional<InstallAgreementRequest> req =
      sqlCache.getBySql(
        InstallAgreementQuery.getFinancierFromProposalLog, params, InstallAgreementRequest.class);

    if (req.isPresent()) {
      financier = req.get().getFinancier();
    }

    log.debug(
      "IARQ: financier from proposal log for project {} #{}: {}",
      projectId,
      proposalNbr,
      financier);
    return financier;
  }

  public String getUtilityFromProposalLog(Long projectId, Long proposalNbr) {
    String utility = null;

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);

    Optional<InstallAgreementRequest> req =
      sqlCache.getBySql(
        InstallAgreementQuery.getUtilityFromProposalLog, params, InstallAgreementRequest.class);

    if (req.isPresent()) {
      utility = req.get().getUtility_company();
    }

    log.debug(
      "IARQ: utility from proposal log for project {} #{}: {}", projectId, proposalNbr, utility);
    return utility;
  }

  private void setRequestStatus(InstallAgreementRequest request, Long userId) {
    Long projectId = request.getProjectId();
    Long proposalNbr = request.getProposalNbr();
    HashMap<String, Object> params = request.toHashMap();
    params.put("userId", userId);
    params.put("sendInstallationAgreement", request.getSendInstallationAgreement());
    params.put("sendFinanceDocs", request.getSendLoanDocs());
    params.put("isSpanish", request.getIsSpanish() != null ? request.getIsSpanish() : false);
    params.put(
      "success",
      request.getRequest_successful() != null ? request.getRequest_successful() : false);

    log.debug(
      "IARQ: setting status projectId={} proposalNbr={} userId={} success={} isSpanish={}",
      projectId,
      proposalNbr,
      userId,
      request.getRequest_successful(),
      request.getIsSpanish());
    sqlCache.updateBySql(InstallAgreementQuery.setRequestStatus, params);
  }

  public String generateLoanApplication(Long projectId, Long proposalNbr, String sendVia)
    throws Exception {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);

    Optional<PandaDocProjectDetails> deets =
      sqlCache.getBySql(PandaDocQuery.getProjectDetails, params, PandaDocProjectDetails.class);

    if (deets.isPresent()) {
      String goodleapUrl = null;
      PandaDocProjectDetails pd = deets.get();
      final String loanType = pd.getLoanType();

      if (loanType == null || loanType.trim().equals("")) {
        throw new ApiException("Loan Type required and not found");
      }

      if (loanType.toLowerCase().contains("enfin")) {
        Optional<InstallAgreementService.PropLogDetail> propLogDetail = getProjectDetailsFromLog(projectId, proposalNbr);
        return enFinService.saveLoanFields(propLogDetail.get(), projectId, proposalNbr);
      } else if (loanType.toLowerCase().contains("mosaic")) {
        Optional<InstallAgreementService.PropLogDetail> propLogDetail = getProjectDetailsFromLog(projectId, proposalNbr);
        return mosaicService.saveLoanFields(propLogDetail.get(), projectId, proposalNbr);
      } else if (loanType.toLowerCase().contains("sunlight")) {
        Optional<InstallAgreementService.PropLogDetail> propLogDetail = getProjectDetailsFromLog(projectId, proposalNbr);

        try {
          return sunlightService.saveLoanFields(propLogDetail.get(), projectId, proposalNbr);
        } catch (Exception e) {
          return sunlightPortalUrl + "salesdashboard";
        }
      } else if (loanType.toLowerCase().contains("sunpower")) {
        throw new Exception(
          "Sunpower Financial is no longer approving new credit applications as of April 15. Please make a new proposal with another financier.");
      } else if (loanType.toLowerCase().contains("loanpal") || loanType.toLowerCase().contains("goodleap")) {
        // Check if this project has already had a credit check via Sunlight, if so throw error
        Optional<Object> creditLastCheckedBy = sunlightService.getCreditLastCheckedBy(projectId);
        if (creditLastCheckedBy.isPresent()) {
          String creditor = (String) creditLastCheckedBy.get();
          if (creditor.equals("Sunlight")) {
            throw new Exception(
              "Unable to generate GoodLeap application due to existing Sunlight application.");
          }
        }

        try {
          goodleapUrl = goodleapService.generateApplication(pd);
        } catch (Exception e) {
          log.error("IARQ: Error generating GoodLeap loan application for project ID " + pd.getProjectId() + " error={}", e.getMessage());
          return goodleapNewLoanUrl;
        }
      }
      sunlightService.setCreditLastCheckedBy(projectId, "GoodLeap");
      return goodleapUrl == null ? goodleapNewLoanUrl : goodleapUrl;
    } else {
      throw new ApiException("Proposal Log not found");
    }
  }

  private String getFinanceOption(String loanType, String loanTerm, String interestRate, Long proposalLogHistoryId) {
    //if proposalLogHistoryId is not null then it will update the row in the db to save the value it finds
    HashMap<String, Object> params = new HashMap<>();
    params.put("loanType", loanType);
    params.put("loanTerm", loanTerm);
    params.put("interestRate", interestRate);
    params.put("proposalLogHistoryId", proposalLogHistoryId);
    String financeOption = sqlCache.queryForObjectBySql(InstallAgreementQuery.getFinancialOption, params, String.class);
    return financeOption;
  }

  public void updateEmailAddress(Long projectId, String emailAddress) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("emailAddress", emailAddress);
    sqlCache.updateBySql(InstallAgreementQuery.updateEmailAddress, params);
  }

  /**
   * Return the string form of the specified object, or an empty string if the specified object is
   * null.
   *
   * @param in
   * @return
   */
  private String s(Object in) {
    return in != null ? in.toString() : "";
  }

  public List<InstallAgreementService.ProposalInfo> getProposalNumbers(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    return sqlCache.queryBySql(InstallAgreementQuery.getProposalNumbers, params, ProposalInfo.class);
  }

  public String getLoanStatus(@NonNull Long projectId, @NonNull Long proposalNbr) {

    Optional<String> loanType =
      sqlCache.getBySql(
        InstallAgreementQuery.getLoanType, Map.of("projectId", projectId, "proposalNbr", proposalNbr), new SingleColumnRowMapper<>(String.class));

    if (loanType.isPresent()) {
      try {
        String loan = loanType.get();
        if (loan.toLowerCase().contains("loanpal") || loan.toLowerCase().contains("goodleap")) {
          JSONObject loanApp = goodleapService.getApplicationByProjectId(projectId);
          return loanApp.toString();
        } else if (loan.toLowerCase().contains("sunlight")) {
          JSONObject sunlightApp =
            sunlightService.getApplicationByProjectId(projectId);
          return sunlightApp.toString();
        } else if (loan.toLowerCase().contains("sunpower")) {
          JSONObject sunlightApp =
            sunpowerService.getApplicationDetails(projectId, proposalNbr);
          return sunlightApp.toString();
        } else if (loan.toLowerCase().contains("mosaic")) {
          JSONObject mosaicApp =
            mosaicService.getApplicationDetails(projectId, proposalNbr);
          return mosaicApp.toString();
        }
      } catch (Exception e) {
        log.debug("IARQ: Installation agreement: Failed to get loan status: {}", e.getMessage());
        if (e.getMessage().contains("locate")) {
          throw new NotFoundException("Loan application was not found.");
        } else {
          throw new ApiException("Unknown Error Occurred");
        }
      }
    }
    throw new NotFoundException("Loan application was not found.");
  }

  @Deprecated
  public String getLoanStatus(@NonNull Long projectId) {
    try {
      JSONObject loanApp = goodleapService.getApplicationByProjectId(projectId);
      return loanApp.toString();
    } catch (Exception e) {
      log.debug("IARQ: Installation agreement: Failed to get loan status: {}", e.getMessage());
      if (e.getMessage().contains("locate")) {
        throw new NotFoundException("Loan application was not found.");
      } else {
        throw new ApiException("Unknown Error Occurred");
      }
    }
  }

  public Map<String, String> updateSunpowerApplication(@NonNull Long projectId, @NonNull Long proposalNbr) {
    try {
      final var propLogDetail = getProjectDetailsFromLog(projectId, proposalNbr);
      if (propLogDetail.isPresent()) {
        sunpowerService.saveLoanFields(propLogDetail.get(), projectId, proposalNbr, null, true);
        return Map.of("message", "success");
      }
      return Map.of("message", "No proposal found");

    } catch (Exception e) {
      log.debug("IARQ: Installation agreement: Failed to update sunpower application, msg={}", e.getMessage());
      throw new ApiException(e.getMessage());
    }
  }

  @Data
  public static class PropLogDetail {
    Long projectId;
    private String loanAmount,
      loanTerm,
      interestRate,
      salesRepresentativeFirstName,
      salesRepresentativeLastName,
      salesRepresentativeEmail,
      firstName,
      lastName,
      email,
      address,
      city,
      state,
      zip,
      phone,
      fullName,
      storageSizeKwh,
      systemSize,
      projectStreet1,
      projectStreet2,
      projectCity,
      projectState,
      projectZipCode,
      inverterCustomGetting,
      panel,
      panelWattage,
      storageBrand,
      numberOfBatteries,
      allAncillaryCosts;
  }

  @Data
  public static class ProposalInfo {
    private Long proposalNbr;
    private String loanType;
  }
}
