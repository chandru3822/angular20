package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.InstallAgreementQuery;
import com.albatross.api.v1.company.blueraven.services.queries.EnfinQuery;
import com.albatross.api.v1.company.blueraven.services.queries.MosaicQuery;
import com.albatross.api.v1.flow.enums.State;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.nio.charset.Charset;
import java.text.DecimalFormat;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class EnFinService {

  private final SqlCache sqlCache;

  private String accessToken;

  @Value(value = "${enfin.api.clientId}")
  private String clientId;

  @Value(value = "${enfin.api.secret}")
  private String secret;

  @Value(value = "${enfin.api.username}")
  private String username;

  @Value(value = "${enfin.api.password}")
  private String password;

  @Value(value = "${enfin.api.host}")
  private String apiUrl;

  public String saveLoanFields(InstallAgreementService.PropLogDetail propLogDetail, Long projectId, Long proposalNbr) throws Exception {
    JSONObject projectDetails = new JSONObject();
    JSONObject installationDetails = new JSONObject();
    JSONArray applicantDetailsArray = new JSONArray();
    JSONObject applicantDetails = new JSONObject();
    JSONObject quoteDetails = new JSONObject();

    projectDetails.put("partnerInstallerEmail", propLogDetail.getSalesRepresentativeEmail() != null ? propLogDetail.getSalesRepresentativeEmail() : "propertyandfinancing@blueravensolar.com");
    projectDetails.put("organizationName", "Blue Raven Solar");
    projectDetails.put("designPartnerName", "Blue Raven Solar");
    projectDetails.put("financingType", "Loan");
    DecimalFormat df2 = new DecimalFormat("#.##");
    quoteDetails.put("apr", Double.valueOf(df2.format(Double.parseDouble(propLogDetail.getInterestRate()) * 100)));

    if (propLogDetail.getLoanAmount() == null) {
      throw new Exception("Error opening or updating Loan Application for EnFin: No Loan Amount found");
    } else {
      try {
        quoteDetails.put("loanAmount", Integer.parseInt(propLogDetail.getLoanAmount()));
      } catch (NumberFormatException nfe) {
        quoteDetails.put("loanAmount", Math.floor(Double.parseDouble(propLogDetail.getLoanAmount())));
      }
    }

    // Check if the email (before the @ sign) exceeds EnFin's limit
    String email = propLogDetail.getEmail();
    int atIndex = email.indexOf('@');
    if (atIndex != -1) {
      email = email.substring(0, atIndex);
    }

    if (email.length() > 40) {
      throw new Exception("Error generating Loan Application for EnFin: Email address exceeds the 40 character limit");
    }

    quoteDetails.put("loanTerm", Integer.parseInt(propLogDetail.getLoanTerm()));
    quoteDetails.put("projectType", getSystemType(propLogDetail));

    if (propLogDetail.getPanel() != null && (propLogDetail.getPanel().equals("Qcell") || propLogDetail.getPanel().equals("Qcells"))) {
      quoteDetails.put("pvEquipment", propLogDetail.getPanel());
    }
    else {
      quoteDetails.put("pvEquipment", "Other");
    }

    if (propLogDetail.getStorageBrand() != null && propLogDetail.getStorageBrand().equals("QHome")) {
      quoteDetails.put("storageEquipment", "QHome");
    }
    else {
      quoteDetails.put("storageEquipment", "Other");
    }

    quoteDetails.put("systemSize", Double.parseDouble(propLogDetail.getSystemSize())/1000);
    quoteDetails.put("totalContractPriceSameAsLoanAmount", true);
    quoteDetails.put("totalContractPrice", propLogDetail.getLoanAmount());
    quoteDetails.put("projectIncludesNonSolarImprovement", false);
    quoteDetails.put("nonSolarImprovementAmount", 0);

    String state = propLogDetail.getState();
    if (state.length() != 2) {
      State stateObj = State.valueOfName(state);
      state = stateObj.getAbbreviation();
    }

    installationDetails.put("streetAddress", propLogDetail.getAddress());
    installationDetails.put("city", propLogDetail.getCity());
    installationDetails.put("state", state);

    String zipCode = propLogDetail.getZip().replaceAll("[^\\d]+", "");
    installationDetails.put("zipCode", zipCode);

    String fullName = propLogDetail.getFullName();
    int firstIndex = fullName.indexOf(' ');
    int lastIndex = fullName.lastIndexOf(' ');
    if (firstIndex != -1) {
      applicantDetails.put("firstName", fullName.substring(0, firstIndex));
      applicantDetails.put("lastName", propLogDetail.getFullName().substring(lastIndex + 1));
    }

    String phoneNumber = propLogDetail.getPhone();
    if (phoneNumber != null) {
      phoneNumber = phoneNumber.replaceAll("[^\\d]+", "");
      if (phoneNumber.length() > 10 && phoneNumber.charAt(0) == '1') {
        phoneNumber = phoneNumber.substring(1);
      }
    }
    applicantDetails.put("mobileNumber", phoneNumber);

    if (propLogDetail.getEmail() != null && propLogDetail.getEmail().contains("@")) {
      applicantDetails.put("emailAddress", propLogDetail.getEmail());
    }

    applicantDetails.put("primaryAddress", propLogDetail.getAddress());
    applicantDetails.put("city", propLogDetail.getCity());
    applicantDetails.put("state", state);
    applicantDetails.put("zipCode", zipCode);

    applicantDetailsArray.put(applicantDetails);
    projectDetails.put("applicantPersonalInfo", applicantDetailsArray);
    projectDetails.put("installationAddress", installationDetails);
    projectDetails.put("loanInformation", quoteDetails);

    HttpResponse res = POST("apexrest/enfin/embeddedCreditApplication", IOUtils.toInputStream(projectDetails.toString(), (Charset) null));
    JSONObject respJson = res.getJSON();
    String status = respJson.getString("status");
    if (status.equals("ERROR")) {
      String errorMsg = respJson.getString("reason");
      if (errorMsg.contains("Existing")) {
        throw new Exception("A credit application for the customer has already been submitted. Please navigate to the EnFin portal to find the application.");
      }
      else {
        throw new Exception("Error message response from EnFin: " + errorMsg);
      }
    }

    String applicationId = respJson.getString("applicationId");
    setEnfinApplicationId(projectId, proposalNbr, applicationId);
    String applicationUrl = respJson.getString("embeddedUrl");
    return applicationUrl;
  }

  private void setEnfinApplicationId(Long projectId, Long proposalNbr, String applicationId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);
    params.put("applicationId", applicationId);
    sqlCache.updateBySql(InstallAgreementQuery.setEnfinApplicationId, params);
  }

  private String getSystemType(InstallAgreementService.PropLogDetail propLogDetail) {
    boolean batteryProject = false;
    boolean reRoofProject = false;
    if (propLogDetail.getNumberOfBatteries() != null && Integer.parseInt(propLogDetail.getNumberOfBatteries()) > 0) {
      batteryProject = true;
    }

    if (propLogDetail.getAllAncillaryCosts() != null && propLogDetail.getAllAncillaryCosts().contains("Reroof Cost")) {
      reRoofProject = true;
    }

    if (batteryProject && !reRoofProject) {
      return "SolarSystemBatteryStorage";
    }
    else if (!batteryProject && reRoofProject) {
      return "SolarSystemReroofing";
    }
    else if (batteryProject && reRoofProject) {
      return "SolarSystemBatteryStorageReroofing";
    }
    else {
      return "SolarSystem";
    }
  }

  public String getCreditStatus(Long projectId) throws Exception {
    JSONObject creditJson = new JSONObject();
    creditJson.put("externalIds", projectId.toString());
    HttpResponse creditResp = POST("getstatus/status", IOUtils.toInputStream(creditJson.toString(), (Charset) null));
    JSONObject respJson = creditResp.getJSON();
    JSONArray projectsResp = respJson.getJSONArray("projects");
    JSONObject currProject = projectsResp.getJSONObject(0);
    return currProject.getString("statusText");
  }

  public String updateFinancialAgreementSigned(String enfinApplicationId) {
    String msg = "";
    Map<String, Object> params = new HashMap<>();
    params.put("enfinApplicationId", enfinApplicationId);
    Optional<Long> projectId =
      sqlCache.getBySql(
        EnfinQuery.getProjectIdFromEnfinApplicationId, params, new SingleColumnRowMapper<>(Long.class));
    if (projectId.isPresent()) {
      Instant now = Instant.now();
      params.put("projectId", projectId.get());
      params.put("dateValue", DateTimeFormatter.ISO_INSTANT.format(now));
      sqlCache.updateBySql(EnfinQuery.setFinancialAgreementSigned, params);
    }
    else {
      JSONObject projectDetails = new JSONObject();
      projectDetails.put("appId", enfinApplicationId);
      projectDetails.put("organizationName", "Blue Raven Solar");
      try {
        HttpResponse res = POST("apexrest/enfin/getProjectInformation", IOUtils.toInputStream(projectDetails.toString(), (Charset) null));
        JSONObject respJson = res.getJSON();
        String status = respJson.getString("status");
        if (!status.equals("SUCCESS")) {
          return "No project found in EnFin for ApplicationId ID: "  + enfinApplicationId;
        }
        JSONObject applicantDetails = respJson.getJSONObject("applicantDetails");
        String email = applicantDetails.getString("email");
        params.put("email", email);
        projectId =
          sqlCache.getBySql(
            EnfinQuery.getProjectIdFromEmail, params, new SingleColumnRowMapper<>(Long.class));
        if (projectId.isPresent()) {
          Instant now = Instant.now();
          params.put("projectId", projectId.get());
          params.put("dateValue", DateTimeFormatter.ISO_INSTANT.format(now));
          sqlCache.updateBySql(MosaicQuery.setFinancialAgreementSigned, params);
        }
        else {
          msg = "No project found for EnFin ApplicationId ID: "  + enfinApplicationId;
        }
      } catch (Exception e) {
        msg = "No project found in EnFin for ApplicationId ID: "  + enfinApplicationId;
      }
    }

    return msg;
  }

  private String generateToken() throws Exception {
    Map<String, String> headers = new HashMap<>();
    headers.put("Content-Type", "application/json");
    String url = apiUrl + "oauth2/token"
        + "?client_id="
        + clientId
        + "&client_secret="
        + secret
        + "&username="
        + username
        + "&password="
        + password
        + "&grant_type=password";

    HttpResponse resp = HttpUtils.call("POST", url, headers);
    if (resp.getResponseCode() != 200) {
      throw new Exception("SUNLIGHT: Unable to generate Sunlight token: %s".formatted(resp.getBody()));
    }

    String respBody = resp.getBody();
    JSONObject jsonResp = new JSONObject(respBody);
    return jsonResp.getString("access_token");
  }

  private HttpResponse request(String method, String uri, InputStream content) throws Exception {
    String url = apiUrl + uri;
    accessToken = generateToken();
    log.debug("ENFIN: sending to EnFin url: {}", url);
    Map<String, String> headers = new HashMap<>();
    headers.put("Authorization", "OAuth %s".formatted(accessToken));
    headers.put("Content-Type", "application/json");
    return HttpUtils.call(method, url, headers, content);
  }

  public HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }
}
