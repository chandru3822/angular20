package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.InstallAgreementQuery;
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
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class MosaicService {

  private final SqlCache sqlCache;

  private String accessToken;

  @Value(value = "${mosaic.api.clientId}")
  private String clientId;

  @Value(value = "${mosaic.api.secret}")
  private String secret;

  @Value(value = "${mosaic.api.host}")
  private String apiUrl;

  public String saveLoanFields(InstallAgreementService.PropLogDetail propLogDetail, Long projectId, Long proposalNbr) throws Exception {
    JSONObject projectDetails = new JSONObject();
    JSONObject applicantDetails = new JSONObject();
    JSONObject projectAddress = new JSONObject();

    String state = propLogDetail.getState();
    if (state.length() != 2) {
      State stateObj = State.valueOfName(state);
      state = stateObj.getAbbreviation();
    }

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
      if (!phoneNumber.startsWith("1")) {
        phoneNumber = "+1" + phoneNumber;
      }
      else {
        phoneNumber = "+" + phoneNumber;
      }
    }
    applicantDetails.put("phoneNumber", phoneNumber);

    if (propLogDetail.getEmail() != null && propLogDetail.getEmail().contains("@")) {
      applicantDetails.put("emailAddress", propLogDetail.getEmail());
    }

    String salesRepEmail = propLogDetail.getSalesRepresentativeEmail();
    if (salesRepEmail == null) {
      throw new Exception("Unable to generate Mosaic application without a Sales Rep");
    }

    // Check to see if the Sales Rep has an account in Mosaic, create one if they do not
    boolean salesRepUserExists = checkIfUserExists(salesRepEmail);
    if (!salesRepUserExists) {
      createUser(salesRepEmail, propLogDetail.getSalesRepresentativeFirstName(), propLogDetail.getSalesRepresentativeLastName());
    }

    String zipCode = propLogDetail.getZip().replaceAll("[^\\d]+", "");
    projectAddress.put("street", propLogDetail.getAddress());
    projectAddress.put("city", propLogDetail.getCity());
    projectAddress.put("stateAbbreviation", state);
    projectAddress.put("zipCode", zipCode);

    projectDetails.put("primaryApplicant", applicantDetails);
    projectDetails.put("projectAddress", projectAddress);
    projectDetails.put("salesRepIdentifier", salesRepEmail);
    projectDetails.put("externalId", projectId.toString());
    // Create the application
    HttpResponse res = POST("/v3/applications", IOUtils.toInputStream(projectDetails.toString(), (Charset) null));
    JSONObject respJson = res.getJSON();

    if (res.getResponseCode() != 202) {
      StringBuilder errorMessage = new StringBuilder();
      errorMessage.append("%s\n".formatted("Error creating Mosaic loan application: "));
      JSONArray errors = respJson.getJSONArray("errors");
      for (int i = 0; i < errors.length(); i++) {
        String currErrorMsg = "";
        JSONObject error = errors.getJSONObject(i);
        if (error.has("field")) {
          currErrorMsg = error.getString("field") + " ";
        }
        currErrorMsg += error.getString("message");
        errorMessage.append("%s\n".formatted(currErrorMsg));
      }
      throw new Exception(errorMessage.toString());
    }

    String applicationId = respJson.getString("id");
    setMosaicApplicationId(projectId, proposalNbr, applicationId);

    // Mosaic requires a delay to avoid an error between these two calls
    Thread.sleep(5000);
    return shareApplication(applicationId, true);
  }

  public String shareApplication(String applicationId, boolean sendEmail) throws Exception {
    JSONObject shareApplication = new JSONObject();
    String[] methodArray;
    if (sendEmail) {
      methodArray = new String[]{"Email", "Link"};
    }
    else {
      methodArray = new String[]{"Link"};
    }

    shareApplication.put("methods", methodArray);
    shareApplication.put("loanType", "Solar");
    // Get the link for the application via share
    JSONObject respJson = new JSONObject();
    HttpResponse res = POST("/v2/applications/" + applicationId + "/share", IOUtils.toInputStream(shareApplication.toString(), (Charset) null));
    if (res.getResponseCode() != 200) {
      StringBuilder errorMessage = new StringBuilder();
      errorMessage.append("%s\n".formatted("Error creating Mosaic loan application: "));
      respJson = res.getJSON();
      JSONArray errors = respJson.getJSONArray("errors");
      for (int i = 0; i < errors.length(); i++) {
        String currErrorMsg = "";
        JSONObject error = errors.getJSONObject(i);
        if (error.has("field")) {
          currErrorMsg = error.getString("field") + " ";
        }
        currErrorMsg += error.getString("message");
        errorMessage.append("%s\n".formatted(currErrorMsg));
      }
      throw new Exception(errorMessage.toString());
    }
    respJson = res.getJSON();
    JSONArray sharesArray = respJson.getJSONArray("shares");

    for (int i = 0; i < sharesArray.length(); i++) {
      JSONObject share = sharesArray.getJSONObject(i);
      String method = share.getString("method");
      if (!method.equals("Link")) {
        continue;
      }
      return share.getString("link");
    }
    throw new Exception("Error creating Mosaic loan application: Unable to generate application link");
  }

  public void sendLoanDocs(Long projectId, Long proposalNbr, InstallAgreementService.PropLogDetail propLogDetail) throws Exception {
    Optional<String> moasiacApplicationId = getMosaicApplicationId(projectId, proposalNbr);
    if (moasiacApplicationId.isPresent()) {
      String applicationId = moasiacApplicationId.get();
      // Get the application and see if it was Approved
      HttpResponse res = GET("/v2/applications/" + applicationId, null);
      JSONObject respJson = res.getJSON();
      if (res.getResponseCode() != 200) {
        StringBuilder errorMessage = new StringBuilder();
        errorMessage.append("%s\n".formatted("Error creating Mosaic loan application: "));
        JSONArray errors = respJson.getJSONArray("errors");
        for (int i = 0; i < errors.length(); i++) {
          String currErrorMsg = "";
          JSONObject error = errors.getJSONObject(i);
          if (error.has("field")) {
            currErrorMsg = error.getString("field") + " ";
          }
          currErrorMsg += error.getString("message");
          errorMessage.append("%s\n".formatted(currErrorMsg));
        }
        throw new Exception(errorMessage.toString());
      }
      String status = respJson.getString("status");
      if (!respJson.has("decision")) {
        throw new Exception("Unable to send Mosaic finance docs due to application status: " + status);
      }

      JSONObject creditDecision = respJson.getJSONObject("decision");
      String decisionStatus = creditDecision.getString("status");
      if (!decisionStatus.contains("Approved")) {
        String decisionDescription = creditDecision.getString("description");
        throw new Exception("Unable to send Mosaic finance docs: " + decisionDescription);
      }

      // Approved
      Double propRate = Double.parseDouble(propLogDetail.getInterestRate()) * 100;
      propRate = Math.round(propRate * 100.0) / 100.0;
      String financeProductId = getFinanceProductId(creditDecision, propRate, propLogDetail.getLoanTerm(), isEnsembleProposal(propLogDetail.getState()));
      if (financeProductId.isEmpty()) {
        throw new Exception("No matching Mosaic finance offer found for: " + propLogDetail.getLoanTerm() + " year loan term, "
          + propRate + "% APR");
      }

      String offerId = createOffer(propLogDetail.getLoanAmount(), applicationId, financeProductId);
      shareOffer(offerId);
    }
    else {
      throw new Exception("No Mosaic application found for this proposal");
    }

  }

  private boolean checkIfUserExists(String email) throws Exception {
    HttpResponse res = GET("/v2/logins?email=" + email, null);
    JSONObject respJson = res.getJSON();
    if (res.getResponseCode() != 200) {
      StringBuilder errorMessage = new StringBuilder();
      errorMessage.append("%s\n".formatted("Error finding Sales Rep user in Mosaic: "));
      JSONArray errors = respJson.getJSONArray("errors");
      for (int i = 0; i < errors.length(); i++) {
        String currErrorMsg = "";
        JSONObject error = errors.getJSONObject(i);
        if (error.has("field")) {
          currErrorMsg = error.getString("field") + " ";
        }
        currErrorMsg += error.getString("message");
        errorMessage.append("%s\n".formatted(currErrorMsg));
      }
      throw new Exception(errorMessage.toString());
    }

    JSONArray users = respJson.getJSONArray("logins");
    if (!users.isEmpty()) {
      return true;
    }

    return false;
  }

  private void createUser(String email, String firstName, String lastName) throws Exception {
    JSONObject userDetails = new JSONObject();
    userDetails.put("email", email);
    userDetails.put("firstName", firstName);
    userDetails.put("lastName", lastName);
    userDetails.put("role", "Salesperson");
    userDetails.put("partnerIdentifier", "blueraven");
    userDetails.put("status", "Enabled");
    HttpResponse res = POST("/v2/logins", IOUtils.toInputStream(userDetails.toString(), (Charset) null));
    if (res.getResponseCode() != 201) {
      StringBuilder errorMessage = new StringBuilder();
      errorMessage.append("%s\n".formatted("Error creating Sales Rep user in Mosaic: "));
      JSONObject respJson = res.getJSON();
      JSONArray errors = respJson.getJSONArray("errors");
      for (int i = 0; i < errors.length(); i++) {
        String currErrorMsg = "";
        JSONObject error = errors.getJSONObject(i);
        if (error.has("field")) {
          currErrorMsg = error.getString("field") + " ";
        }
        currErrorMsg += error.getString("message");
        errorMessage.append("%s\n".formatted(currErrorMsg));
      }
      throw new Exception(errorMessage.toString());
    }
  }

  private String getFinanceProductId(JSONObject creditDecision, Double proposalRate, String proposalTerm, Boolean isEnsembleProposal) {
    int termMonths = Integer.parseInt(proposalTerm) * 12;
    JSONArray financingProducts = creditDecision.getJSONArray("financingProducts");
    for (int i = 0; i < financingProducts.length(); i++) {
      JSONObject financeProduct = financingProducts.getJSONObject(i);
      double rate = financeProduct.getDouble("rate");
      int totalPeriods = financeProduct.getInt("totalPeriods");
      String financingProductType = financeProduct.getString("financingProductType");
      if (financingProductType.equals("Choice") && rate == proposalRate && totalPeriods == termMonths) {
        if (!isEnsembleProposal) {
          return financeProduct.getString("id");
        }
        else {
          // If this is an Ensemble proposal, only return an Ensemble product (based on the product name)
          String name = financeProduct.getString("name");
          if (name.contains("Blue Raven Ensemble")) {
            return financeProduct.getString("id");
          }
        }
      }
    }

    return "";
  }

  private Boolean isEnsembleProposal(String state) {
    final HashSet<String> nonEnsembleStates = new HashSet<>(Arrays.asList("VA", "NC", "KY", "OH", "CO", "SC", "NV"));
    if (nonEnsembleStates.contains(state)) {
      return false;
    }
    else {
      return true;
    }
  }

  private String createOffer(String loanAmount, String applicationId, String financeProductId) throws Exception {
    JSONObject mosaicOffer = new JSONObject();
    JSONArray projects = new JSONArray();
    JSONObject project = new JSONObject();

    project.put("amount", Integer.parseInt(loanAmount));
    project.put("projectType", "Solar");
    projects.put(project);

    mosaicOffer.put("financingProductId", financeProductId);
    mosaicOffer.put("projects", projects);

    HttpResponse res = POST("/v2/applications/" + applicationId + "/offers", IOUtils.toInputStream(mosaicOffer.toString(), (Charset) null));
    JSONObject respJson = res.getJSON();

    if (res.getResponseCode() != 202) {
      StringBuilder errorMessage = new StringBuilder();
      errorMessage.append("%s\n".formatted("Error creating Mosaic offer: "));
      JSONArray errors = respJson.getJSONArray("errors");
      for (int i = 0; i < errors.length(); i++) {
        String currErrorMsg = "";
        JSONObject error = errors.getJSONObject(i);
        currErrorMsg += error.getString("message");

        // If an offer has already been created, get the ID
        if (currErrorMsg.contains("Offer already exists")) {
          HttpResponse appRes = GET("/v2/applications/" + applicationId, null);
          JSONObject appRespJson = appRes.getJSON();
          if (appRespJson.has("offers")) {
            JSONArray offers = appRespJson.getJSONArray("offers");
            JSONObject offer = offers.getJSONObject(0);
            return offer.getString("id");
          }
        }

        errorMessage.append("%s\n".formatted(currErrorMsg));
      }
      throw new Exception(errorMessage.toString());
    }

    return respJson.getString("id");
  }

  private void shareOffer(String offerId) throws Exception {
    JSONObject mosaicOffer = new JSONObject();
    mosaicOffer.put("method", "Email");
    HttpResponse res = POST("/v2/offers/" + offerId + "/share", IOUtils.toInputStream(mosaicOffer.toString(), (Charset) null));
    JSONObject respJson = res.getJSON();

    if (res.getResponseCode() != 202) {
      StringBuilder errorMessage = new StringBuilder();
      errorMessage.append("%s\n".formatted("Error creating Mosaic offer: "));
      JSONArray errors = respJson.getJSONArray("errors");
      for (int i = 0; i < errors.length(); i++) {
        String currErrorMsg = "";
        JSONObject error = errors.getJSONObject(i);
        currErrorMsg += error.getString("message");
        errorMessage.append("%s\n".formatted(currErrorMsg));
      }
      throw new Exception(errorMessage.toString());
    }
  }

  public JSONObject getApplicationDetails(Long projectId, Long proposalNbr) throws Exception {
    JSONObject returnApplication = new JSONObject();
    Optional<String> moasiacApplicationId = getMosaicApplicationId(projectId, proposalNbr);
    String status = "Other";
    String message = "";
    returnApplication.put("type", "Mosaic");
    returnApplication.put("loanStatus", new JSONObject());
    if (moasiacApplicationId.isPresent()) {
      String applicationId = moasiacApplicationId.get();
      // Get the application and see if it was Approved
      HttpResponse res = GET("/v2/applications/" + applicationId, null);
      JSONObject respJson = res.getJSON();
      if (res.getResponseCode() != 200) {
        StringBuilder errorMessage = new StringBuilder();
        errorMessage.append("%s\n".formatted("Error creating Mosaic loan application: "));
        JSONArray errors = respJson.getJSONArray("errors");
        for (int i = 0; i < errors.length(); i++) {
          String currErrorMsg = "";
          JSONObject error = errors.getJSONObject(i);
          if (error.has("field")) {
            currErrorMsg = error.getString("field") + " ";
          }
          currErrorMsg += error.getString("message");
          errorMessage.append("%s\n".formatted(currErrorMsg));
        }
        message = errorMessage.toString();
        status = "Error";
        returnApplication.put("status", status);
        returnApplication.put("message", message);
        return returnApplication;
      }

      if (!respJson.has("decision")) {
        status = "Error";
        returnApplication.put("status", status);
        returnApplication.put("message", message);
        return returnApplication;
      }

      JSONObject creditDecision = respJson.getJSONObject("decision");
      String decisionStatus = creditDecision.getString("status");
      status = getNormalizedStatus(decisionStatus);
    }

    returnApplication.put("status", status);
    returnApplication.put("message", message);
    return returnApplication;
  }

  private String generateToken() throws Exception {
    Map<String, String> headers = new HashMap<>();
    JSONObject body = new JSONObject();
    headers.put("Content-Type", "application/json");
    String url = apiUrl + "/v2/oauth/token";
    body.put("client_id", clientId);
    body.put("client_secret", secret);
    body.put("grant_type", "client_credentials");
    body.put("audience", apiUrl);

    HttpResponse resp = HttpUtils.call("POST", url, headers, IOUtils.toInputStream(body.toString(), (Charset) null));
    if (resp.getResponseCode() != 200) {
      throw new Exception("MOSAIC: Unable to generate Mosaic token: %s".formatted(resp.getBody()));
    }

    String respBody = resp.getBody();
    JSONObject jsonResp = new JSONObject(respBody);
    return jsonResp.getString("access_token");
  }

  public String getNormalizedStatus(String status) {
    List<String> declined = List.of(
      "Declined",
      "Blocked",
      "Not Qualified"
    );

    if (status.equalsIgnoreCase("Approved")) {
      return "Approved";
    } else if (status.equalsIgnoreCase("Pending")) {
      return "Pending";
    } else if (declined.stream().anyMatch(status::equalsIgnoreCase)) {
      return "Declined";
    } else if (status.equalsIgnoreCase("Error")) {
      return "Error";
    } else {
      return "Other";
    }
  }

  private Optional<String> getMosaicApplicationId(Long projectId, Long proposalNbr) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);
    return
      sqlCache.getBySql(
        InstallAgreementQuery.getMosaicApplicationId, Map.of("projectId", projectId, "proposalNbr", proposalNbr), new SingleColumnRowMapper<>(String.class));
  }

  private void setMosaicApplicationId(Long projectId, Long proposalNbr, String applicationId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);
    params.put("applicationId", applicationId);
    sqlCache.updateBySql(InstallAgreementQuery.setMosaicApplicationId, params);
  }

  private HttpResponse request(String method, String uri, InputStream content) throws Exception {
    String url = apiUrl + uri;
    accessToken = generateToken();
    log.debug("MOSAIC: sending to Mosaic url: {}", url);
    Map<String, String> headers = new HashMap<>();
    headers.put("Authorization", "Bearer %s".formatted(accessToken));
    headers.put("Content-Type", "application/json");
    return HttpUtils.call(method, url, headers, content);
  }

  public HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }

  public HttpResponse GET(String url, InputStream content) throws Exception {
    return request("GET", url, content);
  }
}
