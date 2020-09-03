package com.albatross.api.v1.company.blueraven.repository;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementRequest;
import com.albatross.api.v1.company.blueraven.models.PandaDocProjectDetails;
import com.albatross.api.v1.company.blueraven.services.LoanPalService;
import com.albatross.api.v1.company.blueraven.services.PandaDocService;
import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.client.utils.URIBuilder;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Repository;

import java.net.URISyntaxException;
import java.util.*;

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
  private PandaDocService pandaDocService;

  @Value(value = "${app.loanpal.baseUrl}")
  private String baseUrl;

  public List<InstallAgreementProject> getProjects() {
    User user = securityService.getCurrentUser();
    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "INSTALLATION_AGREEMENT", "VIEW_ALL");
    HashMap<String, Object> params = new HashMap<>();
    params.put("view_all", viewAll);
    params.put("user_id", user.getId());

    return sqlCache.query("installAgreement.getProjects", params, InstallAgreementProject.class);
  }

  @Data
  public static class PropLogDetail {
    private String loanAmount;
  }

  public String saveRequest(InstallAgreementRequest request) throws Exception {
    Long projectId = request.getProject_id();
    Boolean sendLoanpalDocs = request.getSend_loanpal_docs();
    request.validateNewRequest();
    String resultMsg = "";
    String financier = getFinancierFromProposalLog(projectId, request.getProposal_nbr());

    sqlCache.update("installAgreement.setAgreementSent", request.toHashMap());

    if (sendLoanpalDocs && financier != null && financier.equals("LoanPal")) {
      JSONObject loanApplication = loanPalService.getApplicationByProjectId(request.getProject_id());
      if (loanApplication != null) {
        try {
          JSONObject outcome = loanApplication.getJSONObject("outcome");
          String loanStatus = outcome.getString("status");
          String loanPalId = loanApplication.getString("id");

          JSONObject loanOptions = outcome.getJSONObject("loanOptions");
          String selectedLoanOption = null != loanOptions ? loanOptions.getString("id") : null;

          //need to send totalSystemCost to loanpal before sending the loanpal docs
          HashMap<String, Object> params = new HashMap<>();
          params.put("projectId", request.getProject_id());
          params.put("proposalNbr", request.getProposal_nbr());
          Optional<PropLogDetail> propLogDetail = sqlCache.get("installAgreement.getLoanAmountFromLog", params, PropLogDetail.class);
          if (propLogDetail.isPresent() && null != selectedLoanOption) {
            loanPalService.saveLoanFields(loanPalId, propLogDetail.get().getLoanAmount(), selectedLoanOption);
          }

          if (loanStatus.equals("Approved")) {
            log.info("sending LoanPal Docs");
            String uri = "/applications/" + loanPalId + "/sendLoanDocs";
            loanPalService.POST(uri, null);
          }
        } catch (JSONException ex){
          log.error("JSON object not found", ex);
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
        if (createPandaDoc) {
            pandaDocService.createDocument(projectId, request.getProposal_nbr(), request.getIsSpanish());
        }
    } catch (Exception e) {
        resultMsg = e.getMessage();
    }

    return resultMsg;
  }

  public Boolean isCashProject(String financier) {
    return financier != null && financier.toLowerCase().equals("cash");
  }

  public Boolean isLoanPalProject(String financier) {
    return financier != null && financier.toLowerCase().equals("loanpal");
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
    Long projectId = request.getProject_id();
    Long proposalNbr = request.getProposal_nbr();
    HashMap<String, Object> params = request.toHashMap();
    params.put("user_id", userId);
    params.put("sendInstallationAgreement", request.getSend_installation_agreement());
    params.put("isSpanish", request.getIsSpanish() != null ? request.getIsSpanish() : false);
    params.put("success", request.getRequest_successful() != null ? request.getRequest_successful() : false);


    log.info("IARQ: setting status projectId={} proposalNbr={} userId={} success={} isSpanish={}",
        projectId, proposalNbr, userId, request.getRequest_successful(), request.getIsSpanish());
    sqlCache.update(
      "installAgreement.setRequestStatus",
      params
    );
  }

  public String generateLoanPal(Long projectId, Long proposalNbr) {
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
              URIBuilder b = new URIBuilder(baseUrl);
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
              e.printStackTrace();
          }
      }
      return baseUrl;
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
  public static class ProposalNumber {
      private Long proposalNbr;
  }

  public List<ProposalNumber> getProposalNumbers(Long projectId) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);

      List<ProposalNumber> results = sqlCache.query("installAgreement.getProposalNumbers", params, ProposalNumber.class);
      return results;
  }

}
