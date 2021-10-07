package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.GoodleapLoanStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import org.springframework.web.client.RestTemplate;

import javax.annotation.PostConstruct;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class GoodleapService {

  private final SqlCache sqlCache;

  @Value("${app.goodleap.api.key}")
  private String apiKey;

  @Value("${app.goodleap.api.host}")
  private String host;

  private HttpHeaders headers;

  private final RestTemplate rest = new RestTemplate();

  @PostConstruct
  public void init() {
    headers = new HttpHeaders();
    headers.setBasicAuth(apiKey);
  }

//  public JSONObject getApplicationByLoanId(String loanId) {
//    HttpEntity<String> request = new HttpEntity<>(null, headers);
//    ResponseEntity<String> response = rest.exchange(host + "/loans/" + loanId, HttpMethod.GET, request, String.class);
//    if (response.getStatusCode() != HttpStatus.OK) {
//      throw new RuntimeException(String.format("Unable to fetch loan application for loan ID: %s", loanId));
//    }
//    return new JSONObject(response.getBody());
//  }

  public JSONObject getApplicationByProjectId(Long projectId) {
    Assert.notNull(projectId, "Project ID can't be null");

    // First try to find an application for the Deal ID, if none is found - then try the Project ID
    Optional<Object> dealId = sqlCache.get("installAgreement.getDealId", Map.of("projectId", projectId), new SingleColumnRowMapper<>(Object.class));
    JSONArray applications = null;
    HttpEntity<String> request = new HttpEntity<>(null, headers);

    // Try to get application by deal ID
    if (dealId.isPresent()) {
      ResponseEntity<String> response = rest.exchange(host + "/loans?referenceNumber=" + dealId.get(), HttpMethod.GET, request, String.class);

      if (response.getStatusCode() == HttpStatus.OK) {
        try {
          JSONObject data = new JSONObject(response.getBody());
          applications = data.getJSONArray("data");
        } catch (JSONException e) {
          throw new RuntimeException("Unable to read applications for project ID: " + projectId);
        }
      }
    }

    // If not found by deal ID, try project ID
    if (applications == null) {
      ResponseEntity<String> response = rest.exchange(host + "/loans?referenceNumber=" + projectId, HttpMethod.GET, request, String.class);

      if (response.getStatusCode() != HttpStatus.OK) {
        throw new RuntimeException("Unable to fetch loan application for project ID: " + projectId);
      }

      try {
        JSONObject data = new JSONObject(response.getBody());
        applications = data.getJSONArray("data");
      } catch (JSONException e) {
        throw new RuntimeException("Unable to read applications for project ID: " + projectId);
      }
    }

    JSONObject application = null;

    if (applications.length() > 1) {

      Integer conditionallyApprovedIndex = null;

      for (int i = 0; i < applications.length(); i++) {
        JSONObject app = applications.getJSONObject(i);
        if (app.get("status").equals(GoodleapLoanStatus.APPROVED)) {
          application = app;
          break;
        } else if (app.get("status").equals(GoodleapLoanStatus.CONDITIONAL)) {
          conditionallyApprovedIndex = i;
        }
      }

      // If no approved application was found, see if a conditional application exists. Else use the most recent application
      if (application == null) {
        if (conditionallyApprovedIndex != null) {
          application = applications.getJSONObject((conditionallyApprovedIndex));
        } else {
          application = applications.getJSONObject(applications.length() - 1);
        }
      }
    } else {
      application = applications.getJSONObject(0);
    }

    application.put("status", getNormalizedStatus(application.getString("status")));
    application.put("message", application.getString("status"));

    return application;
  }

  public void sendDocs(String loanId) {
    HttpEntity<String> request = new HttpEntity<>(null, headers);
    ResponseEntity<Void> response = rest.exchange(host + "/loans/" + loanId + "/documents", HttpMethod.POST, request, Void.class);

    if (response.getStatusCode() != HttpStatus.NO_CONTENT) {
      throw new RuntimeException(String.format("Unable to send Goodleap docs with loan ID: %s", loanId));
    }
  }

  public void updateLoanAmount(String loanId, String amount) {

    JSONObject newAmountValue = new JSONObject();
    newAmountValue.put("type", "USD");
    newAmountValue.put("value", amount);

    JSONObject newAmount = new JSONObject();
    newAmount.put("type", "AMOUNT");
    newAmount.put("value", newAmountValue);

    JSONArray combinedProps = new JSONArray();
    combinedProps.put(newAmount);

    JSONObject requestBody = new JSONObject();
    requestBody.put("changes", combinedProps);

    HttpHeaders jsonHeaders = new HttpHeaders();
    jsonHeaders.setBasicAuth(apiKey);
    jsonHeaders.setContentType(MediaType.APPLICATION_JSON);

    HttpEntity<String> request = new HttpEntity<>(requestBody.toString(), jsonHeaders);
    ResponseEntity<String> response = rest.exchange(host + "/loans/" + loanId + "/changeorders", HttpMethod.POST, request, String.class);

    if (response.getStatusCode() != HttpStatus.CREATED) {
      throw new RuntimeException(String.format("Unable to update loan fields for loan ID: %s", loanId));
    }
  }

  // Statuses used that aren't of type GoodleapLoanStatus are returned from the Sunlight service
  public String getNormalizedStatus(String status) {

    List<String> approved = List.of(
      GoodleapLoanStatus.APPROVED.toString(),
      GoodleapLoanStatus.FUNDED.toString(),
      GoodleapLoanStatus.SOLD.toString(),
      "Change Order Pending",
      "Inspection Approved",
      "Inspection in Review",
      "Installation Approved",
      "Installation in Review",
      "Kitting in Review",
      "Loan Agreement Signed",
      "Notice to Proceed Approved",
      "Notice to Proceed in Review",
      "Permission to Operate in Review",
      "Permit Application Approved",
      "Permit Application in Review",
      "Project Completed",
      "PTO Payment Pending",
      "Sent",
      "Loan Agreement Sent"
    );

    List<String> pending = List.of(
      GoodleapLoanStatus.CREATED.toString(),
      GoodleapLoanStatus.PENDING.toString(),
      GoodleapLoanStatus.CONDITIONAL.toString(),
      GoodleapLoanStatus.LOAN_SELECTION_PENDING.toString(),
      "Credit Pending Review",
      "New"
    );

    List<String> declined = List.of(
      GoodleapLoanStatus.DECLINED.toString(),
      "Credit Declined",
      "Denied",
      "Project Withdrawn"
    );

    List<String> cancelled = List.of(GoodleapLoanStatus.CANCELLED.toString());

    String normalizedStatus = null;

    if (approved.stream().anyMatch(status::equalsIgnoreCase)) {
      normalizedStatus = "Approved";
    }  else if (pending.stream().anyMatch(status::equalsIgnoreCase)) {
      normalizedStatus = "Pending";
    } else if(declined.stream().anyMatch(status::equalsIgnoreCase)) {
      normalizedStatus = "Denied";
    } else if (cancelled.stream().anyMatch(status::equalsIgnoreCase)) {
      normalizedStatus = "Cancelled";
    }

    return normalizedStatus;
  }

  public Boolean shouldCreatePandaDocs(Long projectId) {
    JSONObject application = getApplicationByProjectId(projectId);

    if (application == null) {
      return false;
    }

    return !application.getString("status").equals("Denied") && !application.getString("status").equals("Cancelled");
  }
}
