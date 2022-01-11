package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.State;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SunlightService {

  private final SqlCache sqlCache;

  private final GoodleapService goodleapService;

  @Value(value = "${sunlight.api.token}")
  private String basicToken;

  private String accessToken;

  @Value(value = "${sunlight.api.username}")
  private String username;

  @Value(value = "${sunlight.api.password}")
  private String password;

  @Value(value = "${sunlight.api.host}")
  private String apiUrl;

  @Value(value = "${sunlight.api.portal}")
  private String portalUrl;

  public String saveLoanFields(InstallAgreementService.PropLogDetail propLogDetail, Long projectId, Long proposalNbr) throws Exception {
    JSONObject jsonContact = new JSONObject();
    JSONArray projectsArray = new JSONArray();
    JSONArray applicantsArray = new JSONArray();
    JSONArray quotesArray = new JSONArray();
    JSONObject projectDetails = new JSONObject();
    JSONObject applicantDetails = new JSONObject();
    JSONObject quoteDetails = new JSONObject();
    String hashId = "";

    Optional<Object> sunlightHash = getSunlightHashId(projectId, proposalNbr);
    if (sunlightHash.isPresent()) {
      hashId = sunlightHash.get().toString();
      setCreditLastCheckedBy(projectId, "Sunlight");
      accessToken = generateToken();
      return portalUrl + "runcredit?sid=" + accessToken + "&pid=" + URLEncoder.encode(hashId, "UTF-8");
    }

    projectDetails.put("externalId", propLogDetail.getProjectId().toString());
    DecimalFormat df2 = new DecimalFormat("#.##");
    projectDetails.put("apr",  Double.valueOf(df2.format(Double.parseDouble(propLogDetail.getInterestRate()) * 100)));
    projectDetails.put("isACH", true);

    if (propLogDetail.getLoanAmount() == null) {
      return portalUrl + "salesdashboard";
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
    if (state.length() == 2) {
      state = State.valueOfAbbreviation(state).toString();
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

    try {
      HttpResponse res = POST("pricing/createaccount", IOUtils.toInputStream(jsonContact.toString(), (Charset) null));
      JSONObject respJson = res.getJSON();
      JSONArray projectsResp = respJson.getJSONArray("projects");
      JSONObject currProject = projectsResp.getJSONObject(0);
      hashId = currProject.getString("hashId");
      if (res.getResponseCode() != 200) {
        return portalUrl + "salesdashboard";
      }
    } catch (Exception e) {
      return portalUrl + "salesdashboard";
    }

    setSunlightHashId(projectId, proposalNbr, hashId);
    setCreditLastCheckedBy(projectId, "Sunlight");

    return portalUrl + "runcredit?sid=" + accessToken + "&pid=" + URLEncoder.encode(hashId, "UTF-8");
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

  public String sendLoanDocs(Long projectId) throws Exception {
    JSONObject jsonContact = new JSONObject();
    JSONArray projectsArray = new JSONArray();
    JSONObject projectDetails = new JSONObject();

    projectDetails.put("externalId", projectId.toString());
    projectsArray.put(projectDetails);
    jsonContact.put("projects", projectsArray);

    HttpResponse res = POST("sendloandocs/request/", IOUtils.toInputStream(jsonContact.toString(), (Charset) null));
    JSONObject jsonResp = res.getJSON();
    if (jsonResp.getString("returnCode").equals("200")) {
      return "Success";
    }

    return "Fail";
  }

  private String generateToken() throws Exception {
    Map<String, String> headers = new HashMap<>();
    headers.put("Authorization", String.format("Basic %s", basicToken));
    headers.put("Content-Type", "application/json");
    String url = apiUrl + "gettoken/accesstoken";
    JSONObject content = new JSONObject();
    content.put("username", username);
    content.put("password", password);
    HttpResponse resp = HttpUtils.call("POST", url, headers, new ByteArrayInputStream(content.toString().getBytes()));
    if (resp.getResponseCode() != 200) {
      throw new Exception(String.format("SUNLIGHT: Unable to generate Sunlight token: %s", resp.getBody()));
    }

    String respBody = resp.getBody();
    JSONObject jsonResp = new JSONObject(respBody);
    return jsonResp.getString("access_token");
  }

  public JSONObject getApplicationByProjectId(Long projectId) throws Exception {
    JSONObject returnApplication = new JSONObject();
    returnApplication.put("type", "Sunlight");
    String creditStatus = getCreditStatus(projectId);
    returnApplication.put("status", goodleapService.getNormalizedStatus(creditStatus));
    returnApplication.put("message", creditStatus);
    returnApplication.put("loanStatus", new JSONObject());
    return returnApplication;
  }

  private Optional<Object> getSunlightHashId(Long projectId, Long proposalNbr) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);
    return sqlCache.get("installAgreement.getSunlightHashId", params, new SingleColumnRowMapper<>(Object.class));
  }

  private void setSunlightHashId(Long projectId, Long proposalNbr, String hashId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);
    params.put("sunlightHashId", hashId);
    sqlCache.update("installAgreement.setSunlightHashId", params);
  }

  public Optional<Object> getCreditLastCheckedBy(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    return sqlCache.get("installAgreement.getCreditLastCheckedBy", params, new SingleColumnRowMapper<>(Object.class));
  }

  public void setCreditLastCheckedBy(Long projectId, String financier) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("creditLastCheckedBy", financier);
    sqlCache.update("installAgreement.setCreditLastCheckedBy", params);
  }

  private HttpResponse request(String method, String uri, InputStream content) throws Exception {
    String url = apiUrl + uri;
    accessToken = generateToken();
    log.debug("SUNLIGHT: sending to Sunlight url: {}", url);
    Map<String, String> headers = new HashMap<>();
    headers.put("Authorization", String.format("Basic %s", basicToken));
    headers.put("SFAccessToken", String.format("Bearer %s", accessToken));
    headers.put("Content-Type", "application/json");
    return HttpUtils.call(method, url, headers, content);
  }

  public HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }

}
