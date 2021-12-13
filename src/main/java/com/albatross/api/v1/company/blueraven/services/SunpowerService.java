package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.repository.InstallAgreementRepository;
import com.albatross.api.v1.flow.enums.State;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.nio.charset.Charset;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SunpowerService {

  private final SqlCache sqlCache;

  @Value(value = "${sunpower.api.token}")
  private String basicToken;

  @Value(value = "${sunpower.api.host}")
  private String apiUrl;

  public String saveLoanFields(InstallAgreementRepository.PropLogDetail propLogDetail, Long projectId, String sendVia) throws Exception {
    JSONObject jsonContact = new JSONObject();
    JSONArray projectsArray = new JSONArray();
    JSONArray applicantsArray = new JSONArray();
    JSONArray quotesArray = new JSONArray();
    JSONObject projectDetails = new JSONObject();
    JSONObject applicantDetails = new JSONObject();
    JSONObject quoteDetails = new JSONObject();

    projectDetails.put("externalId", propLogDetail.getProjectId().toString());
    DecimalFormat df2 = new DecimalFormat("#.##");
    projectDetails.put("apr",  Double.valueOf(df2.format(Double.parseDouble(propLogDetail.getInterestRate()) * 100)));
    projectDetails.put("isACH", true);

    if (propLogDetail.getLoanAmount() == null) {
      String message = "No Loan Amount found for this proposal";
      log.error("SUNPWR: Error opening or updating Loan Application for Sunpower: {}", message);
      throw new Exception(message);
    }
    else {
      try {
        quoteDetails.put("loanAmount", Integer.parseInt(propLogDetail.getLoanAmount()));
      } catch (NumberFormatException nfe) {
        quoteDetails.put("loanAmount", Math.floor(Double.parseDouble(propLogDetail.getLoanAmount())));
      }
    }

    quotesArray.put(quoteDetails);

    if (propLogDetail.getSalesRepresentativeEmail() != null && propLogDetail.getSalesRepresentativeEmail().contains("@")) {
      projectDetails.put("salesRepresentativeEmail", propLogDetail.getSalesRepresentativeEmail());
    }
    projectDetails.put("salesRepresentativeFirstName", propLogDetail.getSalesRepresentativeFirstName());
    projectDetails.put("salesRepresentativeLastName", propLogDetail.getSalesRepresentativeLastName());
    projectDetails.put("term", Integer.parseInt(propLogDetail.getLoanTerm())*12);
    projectDetails.put("productType", "Solar");
    projectDetails.put("installStreet", propLogDetail.getAddress());
    projectDetails.put("installCity", propLogDetail.getCity());

    String state = propLogDetail.getState();
    if (state.length() != 2) {
      State stateObj = State.valueOfName(state);
      state = stateObj.getAbbreviation();
    }

    projectDetails.put("installStateName", state);
    projectDetails.put("installZipCode", propLogDetail.getZip());
    applicantDetails.put("isPrimary", true);

    int idx = propLogDetail.getFullName().lastIndexOf(' ');
    if (idx != -1) {
      applicantDetails.put("firstName", propLogDetail.getFullName().substring(0, idx));
      applicantDetails.put("lastName", propLogDetail.getFullName().substring(idx + 1));
    }

    applicantDetails.put("phone", propLogDetail.getPhone());

    if (propLogDetail.getEmail() != null && propLogDetail.getEmail().contains("@")) {
      applicantDetails.put("email", propLogDetail.getEmail());
    }

    applicantDetails.put("mailingStreet", propLogDetail.getAddress());
    applicantDetails.put("mailingCity", propLogDetail.getCity());
    applicantDetails.put("mailingStateName", state);
    applicantDetails.put("mailingZipCode", propLogDetail.getZip());
    applicantDetails.put("residenceStreet", propLogDetail.getAddress());
    applicantDetails.put("residenceCity", propLogDetail.getCity());
    applicantDetails.put("residenceStateName", state);
    applicantDetails.put("residenceZipCode", propLogDetail.getZip());

    applicantsArray.put(applicantDetails);

    projectDetails.put("applicants", applicantsArray);
    projectDetails.put("quotes", quotesArray);
    projectsArray.put(projectDetails);
    jsonContact.put("projects", projectsArray);

    if (sendVia == null) {
      sendVia = "embedded";
    }

    HttpResponse res = POST("active-bpel/rt/Customer?sendVia="+sendVia, IOUtils.toInputStream(jsonContact.toString(), (Charset) null));
    JSONObject respJson = res.getJSON();
    JSONObject customerResponse = respJson.getJSONObject("customerResponse");
    JSONObject status = customerResponse.getJSONObject("status");
    Boolean success = status.getBoolean("success");
    String result = "";

    if (success) {
      String message = status.getString("message");
      if (message.equals("OK")) {
        result = customerResponse.getString("activationURL");
      }
      else if (message.equals("Quote Updated")) {
        result = "Application already exists, customer information updated if applicable";
      }
    }
    else {
      String message = status.getString("message");
      log.error("SUNPWR: Error opening or updating Loan Application for Sunpower: {}", message);
      throw new Exception(message);
    }

    setCreditLastCheckedBy(projectId, "Sunpower");
    return result;
  }

  public String sendLoanDocs(Long projectId) throws Exception {
    JSONObject creditJson = new JSONObject();
    creditJson.put("externalId", projectId.toString());
    HttpResponse creditResp = GET("active-bpel/rt/Contract/"+projectId, IOUtils.toInputStream(creditJson.toString(), (Charset) null));
    JSONObject respJson = creditResp.getJSON();
    JSONObject contractResponse = respJson.getJSONObject("contractResponse");
    JSONObject status = contractResponse.getJSONObject("status");
    Boolean success = status.getBoolean("success");

    if (success) {
      return "Loan agreement created successfully";
    }
    else {
      String message = status.getString("message");
      log.error("SUNPWR: Error creating Loan agreement for Sunpower: {}", message);
      throw new Exception(message);
    }
  }

  public void setCreditLastCheckedBy(Long projectId, String financier) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("creditLastCheckedBy", financier);
    sqlCache.update("installAgreement.setCreditLastCheckedBy", params);
  }

  private HttpResponse request(String method, String uri, InputStream content) throws Exception {
    String url = apiUrl + uri;
    log.debug("SUNPOWER: sending to Sunpower url: {}", url);
    Map<String, String> headers = new HashMap<>();
    headers.put("Authorization", String.format("Basic %s", basicToken));
    headers.put("Content-Type", "application/json");
    return HttpUtils.call(method, url, headers, content);
  }

  public HttpResponse GET(String url, InputStream content) throws Exception {
    return request("GET", url, content);
  }

  public HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }

}
