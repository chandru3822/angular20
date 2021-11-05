package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.config.LoanPalConfiguration;
import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.nio.charset.Charset;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Optional;

@Deprecated
@Service
@Slf4j
@RequiredArgsConstructor
public class LoanPalService {
  private final LoanPalConfiguration config;
  private final SqlCache sqlCache;

  public Boolean processProject(Long projectId) throws Exception {
    log.debug("LOANPAL: processing project {}", projectId);

    try {
      JSONObject application = getApplicationByProjectId(projectId.toString());
      String creditCheck = getCreditCheck(application);

      HashMap<String, Object> data = new HashMap<>();
      data.put("Credit Check", creditCheck);
      data.put("Credit Decision Date", getCreditDecisionDate(application));
      data.put("Partner Job ID", application.getString("loanPalId"));

      String maxLoanAmount = getMaxLoanAmount(application);
      if (maxLoanAmount != null && !maxLoanAmount.isEmpty()) {
        data.put("Maximum Loan Amount", maxLoanAmount);
      }

      if (creditCheck.equals("Fail")) {
        log.error("LOANPAL: Credit Check failed for projectId={}", projectId);
        throw new Exception("LoanPal Credit Check failed for project " + projectId.toString());
      } else {
        log.debug("LOANPAL: credit check is good for project {}", projectId);
      }
    } catch (Exception ex) {
      throw ex;
    }

    return true;
  }

  public void saveLoanFields(String loanId, String loanAmount, String selectedLoanOption) throws Exception {
    String uri = "/applications/" + loanId + "/loanAmountAndOption" ;

    String jsonParams = new JSONObject()
        .put("totalSystemCost", loanAmount)
        .put("selectedLoanOption", selectedLoanOption).toString();

    HttpResponse res = PUT(uri, IOUtils.toInputStream(jsonParams, (Charset) null));

    if (res.getResponseCode() != 200) {
      throw new Exception(String.format("Unable to save loan amount and option for loan %s: %s", loanId, res.getBody()));
    }
  }

  public JSONObject getApplicationByProjectId(String projectId) throws Exception {
    JSONObject returnApplication = new JSONObject();
    returnApplication.put("type", "LoanPal");

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", Long.valueOf(projectId));

    Optional<Object> dealId = sqlCache.get("installAgreement.getDealId", params, new SingleColumnRowMapper<>(Object.class));
    JSONArray applications = null;
    // First try to find a Loan Application for the Deal ID, if none is found - then try the Project ID
    if (dealId.isPresent()) {
        String uri = "/applications/reference/" + dealId.get().toString();
        HttpResponse res = GET(uri);
        if (res.getResponseCode() == 200) {
            applications = res.getJSONArray();
            if (applications.length() != 1) {
                log.warn("LOANPAL: unexpected number of applications for project {} ({})", projectId, applications.length());
            }
        }
    }
    // Try to find a Loan application for the project Id
    if (applications == null) {
        String uri = "/applications/reference/" + projectId;
        HttpResponse res = GET(uri);
        if (res.getResponseCode() != 200) {
            throw new Exception(String.format("Unable to locate loan application for project %s: %s", projectId, res.getBody()));
        }

        applications = res.getJSONArray();
        if (applications.length() != 1) {
          log.warn("LOANPAL: unexpected number of applications for project {} ({})", projectId, applications.length());
        }
    }

    JSONObject application = null;
    int approvedWithStipsIndex = -1;
    if (applications.length() > 1) {
      for (int i = 0; i < applications.length(); i++) {
        JSONObject app = applications.getJSONObject(i);
        if (app.getJSONObject("status").getString("application").equals("Approved")) {
          application = app;
          break;
        }
        else if (app.getJSONObject("status").getString("application").equals("ApprovedWithStips")) {
          approvedWithStipsIndex = i;
        }
      }
      // If no Approved loan was found
      if (application == null) {
        // If an ApprovedWithStips loan exists
        if (approvedWithStipsIndex != -1) {
          application = applications.getJSONObject(approvedWithStipsIndex);
        }
        else {
          // If no Approved or ApprovedWithStips loans are found, use the last/most recent loan application
          application = applications.getJSONObject(applications.length() - 1);
        }
      }
    }
    else {
      application = applications.getJSONObject(0);
    }

    JSONObject loanPalApp = getApplicationByLoanId(getLoanId(application));
    JSONObject statusJson = loanPalApp.getJSONObject("loanStatus");
    returnApplication.put("status", getLoanStatusForMobile(statusJson.getString("application")));
    JSONObject applicationJson = new JSONObject();
    applicationJson.put("application", statusJson.getString("application"));
    returnApplication.put("message", statusJson.getString("application"));
    returnApplication.put("loanStatus", applicationJson);
    returnApplication.put("outcome", loanPalApp.getJSONObject("outcome"));
    returnApplication.put("loanPalId", loanPalApp.getString("id"));
    returnApplication.put("createdAt", loanPalApp.getString("createdAt"));
    return returnApplication;
  }

  public JSONObject getApplicationByLoanId(String loanId) throws Exception {
    HttpResponse res = GET("/applications/" + loanId);
    if (res.getResponseCode() != 200) {
      throw new Exception(String.format("Unable to locate LoanPal application %s: %s", loanId, res.getBody()));
    }
    return res.getJSON();
  }

  public String getLoanId(JSONObject obj) throws JSONException {
    return obj.getString("id");
  }

  public String getCreditCheck(JSONObject app) throws JSONException {
    JSONObject loanStatus = app.getJSONObject("loanStatus");
    String status = loanStatus.optString("application");
    String result = "";

    if (status.equals("Approved")) {
      result = "Pass";
    } else if (status.equals("Declined")) {
      result = "Fail";
    } else if (status.equals("Conditional Approval") || status.equals("ApprovedWithStips")) {
      result = "Pending Review";
    }

    return result;
  }

  public String getCreditDecisionDate(JSONObject app) throws JSONException {
    ZonedDateTime created;
    String createdAt = app.getString("createdAt");
    if (createdAt != null) {
        created = ZonedDateTime.parse(createdAt, DateTimeFormatter.ISO_DATE_TIME).withZoneSameInstant(ZoneId.of("US/Mountain"));
    } else {
        created = ZonedDateTime.now().withZoneSameInstant(ZoneId.of("US/Mountain"));
    }

    return created.toLocalDate().toString();
  }

  // Used to standardize the status sent back to mobile for a loan
  public String getLoanStatusForMobile(String creditStatus) {
    HashSet<String> declinedStatus = new HashSet<>() {{
      add("Credit Declined");
      add("Declined");
      add("Denied");
      add("Project Withdrawn");
    }};

    HashSet<String> pendingStatus = new HashSet<>() {{
      add("Credit Pending Review");
      add("Pending");
      add("New");
    }};

    HashSet<String> approvedStatus = new HashSet<>() {{
      add("Change Order Pending");
      add("Inspection Approved");
      add("Inspection in Review");
      add("Installation Approved");
      add("Installation in Review");
      add("Kitting in Review");
      add("Loan Agreement Signed");
      add("Notice to Proceed Approved");
      add("Notice to Proceed in Review");
      add("Permission to Operate in Review");
      add("Permit Application Approved");
      add("Permit Application in Review");
      add("Project Completed");
      add("PTO Payment Pending");
      add("Approved");
      add("Sent");
      add("Loan Agreement Sent");
    }};

    if (approvedStatus.contains(creditStatus)) {
      return "Approved";
    }
    else if (pendingStatus.contains(creditStatus)) {
      return "Pending";
    }
    else if (declinedStatus.contains(creditStatus)) {
      return "Denied";
    }
    else {
      return null;
    }
  }

  public String getMaxLoanAmount(JSONObject app) throws JSONException {
    JSONObject outcome = app.getJSONObject("outcome");
    return outcome.optString("maxLoanAmount");
  }

  private HttpResponse GET(String url) throws Exception {
    return request("GET", url, null);
  }

  private HttpResponse request(String method, String uri, InputStream content) throws Exception {
    String url = String.format("%s%s%s", config.getApiHost(), config.getUriPrefix(), uri);
    log.debug("LOANPAL: sending to loanpal url: {}", url);
    Map<String, String> headers = new HashMap<>();
    headers.put("X-Api-Key", config.getApiKey());
    headers.put("Content-Type", "application/json");
    return HttpUtils.call(method, url, headers, content);
  }

  public HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }

  public HttpResponse PUT(String url, InputStream content) throws Exception {
    return request("PUT", url, content);
  }
}
