package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.config.LoanPalConfiguration;
import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.nio.charset.Charset;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class LoanPalService {
  @Autowired
  private LoanPalConfiguration config;

  public Boolean processProject(Long projectId) throws Exception {
    log.info("LOANPAL: processing project {}", projectId);

    try {
      JSONObject application = getApplicationByProjectId(projectId);
      String creditCheck = getCreditCheck(application);

      HashMap<String, Object> data = new HashMap<>();
      data.put("Credit Check", creditCheck);
      data.put("Credit Decision Date", getCreditDecisionDate(application));
      data.put("Partner Job ID", getLoanId(application));

      String maxLoanAmount = getMaxLoanAmount(application);
      if (maxLoanAmount != null && !maxLoanAmount.isEmpty()) {
        data.put("Maximum Loan Amount", maxLoanAmount);
      }

      if (creditCheck.equals("Fail")) {
        log.info("LOANPAL: not queuing PandaDoc document creation projectId={}", projectId);
        throw new Exception("LoanPal Credit Check failed for project " + projectId.toString());
      } else {
        log.info("LOANPAL: credit check is good for project {}", projectId);
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

  public JSONObject getApplicationByProjectId(Long projectId) throws Exception {
    String uri = "/applications/reference/" + projectId.toString();
    HttpResponse res = GET(uri);
    if (res.getResponseCode() != 200) {
      throw new Exception(String.format("Unable to locate LoanPal application for project %s: %s", projectId, res.getBody()));
    }

    JSONArray applications = res.getJSONArray();
    if (applications.length() != 1) {
      log.warn("LOANPAL: unexpected number of applications for project {} ({})", projectId, applications.length());
    }

    JSONObject application = applications.getJSONObject(0);
    return getApplicationByLoanId(getLoanId(application));
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

  public String getMaxLoanAmount(JSONObject app) throws JSONException {
    JSONObject outcome = app.getJSONObject("outcome");
    return outcome.optString("maxLoanAmount");
  }

  private HttpResponse GET(String url) throws Exception {
    return request("GET", url, null);
  }

  private HttpResponse request(String method, String uri, InputStream content) throws Exception {
    String url = String.format("%s%s%s", config.getApiHost(), config.getUriPrefix(), uri);
    log.info("sending to loanpal url: {}", url);
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
