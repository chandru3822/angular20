package com.albatross.api.v1.company.blueraven.repository;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementRequest;
import com.albatross.api.v1.company.blueraven.models.PandaDocProjectDetails;
import com.albatross.api.v1.company.blueraven.services.LoanPalService;
import com.albatross.api.v1.company.blueraven.services.PandaDocService;
import com.albatross.api.v1.company.blueraven.services.SunlightService;
import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.client.utils.URIBuilder;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Repository
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class InstallAgreementRepository {
  private final SqlCache sqlCache;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private LoanPalService loanPalService;

  @Autowired
  private SunlightService sunlightService;

  @Autowired
  private PandaDocService pandaDocService;

  @Value(value = "${loanpal.api.baseUrl}")
  private String loanPalBaseUrl;

  @Value(value = "${sunlight.api.portal}")
  private String sunlightPortalUrl;

  public Page<InstallAgreementProject> getProjects(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "INSTALLATION_AGREEMENT", List.of("VIEW_ALL"));
    HashMap<String, Object> params = new HashMap<>();
    params.put("view_all", viewAll);
    params.put("user_id", user.getId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<InstallAgreementProject> results = sqlCache.query("installAgreement.getProjects", params, InstallAgreementProject.class);
    Integer count = sqlCache.queryForObject("installAgreement.getProjectsCount", params, Integer.class);

    Page<InstallAgreementProject> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  @Data
  public static class PropLogDetail {
    private String loanAmount, loanTerm, interestRate, salesRepresentativeFirstName, salesRepresentativeLastName,
      salesRepresentativeEmail, firstName, lastName, email, address, city, state, zip, phone, fullName;

    Long projectId;
  }

  public String saveRequest(InstallAgreementRequest request) throws Exception {
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
      } catch (JSONException ex){
        log.error("IARQ: Error sending loan docs via Sunlight", ex.getMessage());
        resultMsg = "Error sending loan docs through Sunlight";
      }
    }
    else if (sendLoanDocs && isLoanPalProject(financier)) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      params.put("proposalNbr", request.getProposalNbr());
      Optional<PropLogDetail> propLogDetail = sqlCache.get("installAgreement.getProjectDetailsFromLog", params, PropLogDetail.class);

      JSONObject loanApplication = loanPalService.getApplicationByProjectId(request.getProjectId().toString());
      if (loanApplication != null) {
        try {
          JSONObject outcome = loanApplication.getJSONObject("outcome");
          String loanStatus = outcome.getString("status");
          String loanPalId = loanApplication.getString("loanPalId");

          JSONObject loanOptions = outcome.getJSONObject("loanOptions");
          String selectedLoanOption = null != loanOptions ? loanOptions.getString("id") : null;

          if (propLogDetail.isPresent() && null != selectedLoanOption) {
            loanPalService.saveLoanFields(loanPalId, propLogDetail.get().getLoanAmount(), selectedLoanOption);
          }

          if (loanStatus.equals("Approved")) {
            log.info("LOANPAL: sending LoanPal Docs");
            String uri = "/applications/" + loanPalId + "/sendLoanDocs";
            loanPalService.POST(uri, null);
          }
        } catch (JSONException ex){
          log.error("IARQ: JSON object not found", ex.getMessage());
        }
      }
    }

    Boolean createPandaDoc = true;
    try {
        if (isLoanPalProject(financier)) {
          log.info("IARQ: processing loanpal project {}", request);
          createPandaDoc = loanPalService.processProject(projectId);
        }

        log.info("IARQ: create PandaDoc? {}; project {}", createPandaDoc, projectId);
        if (createPandaDoc && (request.getSendInstallationAgreement() || request.getIsSpanish())) {
            pandaDocService.createDocument(projectId, request.getProposalNbr(), request.getIsSpanish());
        }
    } catch (Exception e) {
        resultMsg = e.getMessage();
    }

    return resultMsg;
  }

  public Boolean isCashProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("cash");
  }

  public Boolean isLoanPalProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("loanpal");
  }

  public Boolean isSunlightProject(String financier) {
    return financier != null && financier.equalsIgnoreCase("sunlight");
  }

  public String getFinancierFromProposalLog(Long projectId, Long proposalNbr) {
    String financier = null;

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);

    Optional<InstallAgreementRequest> req = sqlCache.get(
      "installAgreement.getFinancierFromProposalLog",
      params,
      InstallAgreementRequest.class
    );

    if (req.isPresent()) {
      financier = req.get().getFinancier();
    }

    log.info("IARQ: financier from proposal log for project {} #{}: {}", projectId, proposalNbr, financier);
    return financier;
  }

    public String getUtilityFromProposalLog(Long projectId, Long proposalNbr) {
        String utility = null;

        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);
        params.put("proposalNbr", proposalNbr);

        Optional<InstallAgreementRequest> req = sqlCache.get(
            "installAgreement.getUtilityFromProposalLog",
            params,
            InstallAgreementRequest.class
        );

        if (req.isPresent()) {
            utility = req.get().getUtility_company();
        }

        log.info("IARQ: utility from proposal log for project {} #{}: {}", projectId, proposalNbr, utility);
        return utility;
    }

  public void setRequestStatus(InstallAgreementRequest request) {
    User user = securityService.getCurrentUser();
    setRequestStatus(request, user.getId());
  }

  public void setRequestStatus(InstallAgreementRequest request, Long userId) {
    Long projectId = request.getProjectId();
    Long proposalNbr = request.getProposalNbr();
    HashMap<String, Object> params = request.toHashMap();
    params.put("userId", userId);
    params.put("sendInstallationAgreement", request.getSendInstallationAgreement());
    params.put("isSpanish", request.getIsSpanish() != null ? request.getIsSpanish() : false);
    params.put("success", request.getRequest_successful() != null ? request.getRequest_successful() : false);


    log.info("IARQ: setting status projectId={} proposalNbr={} userId={} success={} isSpanish={}",
        projectId, proposalNbr, userId, request.getRequest_successful(), request.getIsSpanish());
    sqlCache.update(
      "installAgreement.setRequestStatus",
      params
    );
  }

  public String generateLoanApplication(Long projectId, Long proposalNbr) throws Exception {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      params.put("proposalNbr", proposalNbr);

      Optional<PandaDocProjectDetails> deets = sqlCache.get(
          "pandaDoc.getProjectDetails",
          params,
          PandaDocProjectDetails.class
      );

      if (deets.isPresent()) {
          PandaDocProjectDetails pd = deets.get();
          if (pd.getLoanType().contains("Sunlight")) {
            Optional<PropLogDetail> propLogDetail = sqlCache.get("installAgreement.getProjectDetailsFromLog", params, PropLogDetail.class);
            try {
              return sunlightService.saveLoanFields(propLogDetail.get(), projectId, proposalNbr);
            } catch (Exception e) {
              return sunlightPortalUrl + "salesdashboard";
            }
          } else if (pd.getLoanType().contains("LoanPal")) {
            // Check if this project has already had a credit check via Sunlight, if so throw error
            Optional<Object> creditLastCheckedBy = sunlightService.getCreditLastCheckedBy(projectId);
            if (creditLastCheckedBy.isPresent()) {
              String creditor = (String) creditLastCheckedBy.get();
              if (creditor.equals("Sunlight")) {
                throw new Exception(String.format("Unable to generate LoanPal application due to existing Sunlight application."));
              }
            }
            String bothStreets = "";
            if (pd.getMailingStreet1() != null) {
              bothStreets += pd.getMailingStreet1();
            }
            if (pd.getMailingStreet2() != null) {
              bothStreets += " " + pd.getMailingStreet2();
            }

            bothStreets = bothStreets.trim();
            String phoneNumber = "";
            if (pd.getPhone() != null) {
              phoneNumber = pd.getPhone().replaceAll("[^\\d]+", "");
              if (phoneNumber.length() > 10 && phoneNumber.charAt(0) == '1') {
                phoneNumber = phoneNumber.substring(1);
              }
            }

            try {
              String financeOption = getFinanceOption(pd.getLoanTerm(), pd.getInterestRate());
              URIBuilder b = new URIBuilder(loanPalBaseUrl + financeOption + ".html");
              b.addParameter("fname", s(pd.getCustomerFirstName()));
              b.addParameter("lname", s(pd.getCustomerLastName()));
              b.addParameter("street", bothStreets);
              b.addParameter("city", s(pd.getCity()));
              b.addParameter("state", s(pd.getMailingState()));
              b.addParameter("zip", s(pd.getPostalCode()));
              b.addParameter("email", s(pd.getCustomerEmail()));
              b.addParameter("phone", phoneNumber);
              b.addParameter("srfn", s(pd.getCloserFirstName()));
              b.addParameter("srln", s(pd.getCloserLastName()));
              b.addParameter("sre", s(pd.getCloserEmail()));
              b.addParameter("cost", s(pd.getTotalSystemPrice()));
              b.addParameter("refnum", s(pd.getProjectId()));
              return b.build().toString().replaceAll("\\+", "%20");
            } catch (URISyntaxException e) {
              log.error("IARQ: uri error {}", e.getMessage());
              e.printStackTrace();
            }
          }
      }

      sunlightService.setCreditLastCheckedBy(projectId, "LoanPal");
      return loanPalBaseUrl;
  }

  private String getFinanceOption(String loanTerm, String interestRate) {
    String financeOption = "";
    final String SEVEN_YEAR_TERM_V1 = "07";
    final String SEVEN_YEAR_TERM_V2 = "7";
    final String SEVEN_YEAR_TERM_V3 = " 7";
    final String TEN_YEAR_TERM = "10";
    final String FIFTEEN_YEAR_TERM = "15";
    final String TWENTY_YEAR_TERM = "20";
    final String TWENTY_FIVE_YEAR_TERM = "25";
    // Handle multiple formats of 7 year loan term
    if (loanTerm.equals(SEVEN_YEAR_TERM_V1) || loanTerm.equals(SEVEN_YEAR_TERM_V2) || loanTerm.equals(SEVEN_YEAR_TERM_V3)) {
      if (interestRate.equals("0.0699")) {
        financeOption = "brs699";
      }
    }
    else if (loanTerm.equals(TEN_YEAR_TERM)) {
      if (interestRate.equals("0.0299")) {
        financeOption = "blueraven";
      }
      else if (interestRate.equals("0.0499")) {
        financeOption = "br";
      }
    }
    else if (loanTerm.equals(FIFTEEN_YEAR_TERM)) {
      if (interestRate.equals("0.0499")) {
        financeOption = "bres1";
      }
    }
    else if (loanTerm.equals(TWENTY_YEAR_TERM)) {
      if (interestRate.equals("0.0148")) {
        financeOption = "flexpay148";
      }
      else if (interestRate.equals("0.0149")) {
        financeOption = "brs149";
      }
      else if (interestRate.equals("0.0198")) {
        financeOption = "flexpay198";
      }
      else if (interestRate.equals("0.0248")) {
        financeOption = "flexpay248";
      }
      else if (interestRate.equals("0.0298")) {
        financeOption = "flexpay298";
      }
      else if (interestRate.equals("0.0398")) {
        financeOption = "flexpay398";
      }
      else if (interestRate.equals("0.0399")) {
        financeOption = "bres2";
      }
      else if (interestRate.equals("0.0498")) {
        financeOption = "flexpay498";
      }
      else if (interestRate.equals("0.0598")) {
        financeOption = "flexpay598";
      }
    }
    else if (loanTerm.equals(TWENTY_FIVE_YEAR_TERM)) {
      if (interestRate.equals("0.0198")) {
        financeOption = "flexpay198";
      }
      else if (interestRate.equals("0.0199")) {
        financeOption = "brs199";
      }
      else if (interestRate.equals("0.0248")) {
        financeOption = "flexpay248";
      }
      else if (interestRate.equals("0.0298")) {
        financeOption = "flexpay298";
      }
      else if (interestRate.equals("0.0299")) {
        financeOption = "blueraven";
      }
      else if (interestRate.equals("0.0398")) {
        financeOption = "flexpay398";
      }
      else if (interestRate.equals("0.0498")) {
        financeOption = "flexpay498";
      }
      else if (interestRate.equals("0.0598")) {
        financeOption = "flexpay598";
      }
    }

    if (financeOption.isEmpty()) {
      financeOption = "blueraven";
    }

    return financeOption;
  }

  public void updateEmailAddress(Long projectId, String emailAddress) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      params.put("emailAddress", emailAddress);
      sqlCache.update("installAgreement.updateEmailAddress", params);
  }

    /**
     * Return the string form of the specified object, or an empty string if the specified
     * object is null.
     *
     * @param in
     * @return
     */
    private String s(Object in) {
        return in != null ? in.toString() : "";
    }

  @Data
  public static class ProposalInfo {
      private Long proposalNbr;
      private String loanType;
  }

  public List<ProposalInfo> getProposalNumbers(Long projectId) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);

      List<ProposalInfo> results = sqlCache.query("installAgreement.getProposalNumbers", params, ProposalInfo.class);
      return results;
  }

}
