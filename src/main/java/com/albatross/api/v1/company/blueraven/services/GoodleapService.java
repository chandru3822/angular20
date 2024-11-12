package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.GoodleapLoanStatus;
import com.albatross.api.v1.company.blueraven.models.PandaDocProjectDetails;
import com.albatross.api.v1.company.blueraven.services.queries.GoodleapQuery;
import com.albatross.api.v1.company.blueraven.services.queries.InstallAgreementQuery;
import jakarta.annotation.PostConstruct;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.http.*;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;
import org.springframework.web.client.RestTemplate;
import org.springframework.beans.factory.annotation.Value;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class GoodleapService {

  private final SqlCache sqlCache;

  @Value("${app.goodleap.api.key}")
  private String apiKey;

  @Value("${app.goodleap.api.host}")
  private String host;

  private HttpHeaders headers;

  private final RestTemplate rest = new RestTemplate();

  private final String SALES_REP_ADVANCED_INSTALLED_ROLE_ID = "d322f510-e1ac-4ece-aba7-d41a2b955a61";

  private final String DEFAULT_NEW_USER_PASSWORD = "Solar101!";

  private final Long DESIGN_AND_FINANCING_PSID = 3355L;
  private final Long DESIGN_FINANCIAL_AGREEMENT_SIGNED_CFGAID = 19505L;
  private final Long DESIGN_COUNTER_SIGNED_CFGAID = 19506L;

  private final Long RETROFIT_DESIGN_AND_FINANCING_PSID = 3392L;
  private final Long RETROFIT_FINANCIAL_AGREEMENT_SIGNED_CFGAID = 20912L;
  private final Long RETROFIT_COUNTER_SIGNED_CFGAID = 20913L;

  private final Long BATTERY_DESIGN_AND_FINANCING_PSID = 3587L;
  private final Long BATTERY_FINANCIAL_AGREEMENT_SIGNED_CFGAID = 24922L;
  private final Long BATTERY_COUNTER_SIGNED_CFGAID = 24925L;

  private final Long LEASE_DESIGN_AND_FINANCING_PSID = 3620L;
  private final Long LEASE_FINANCIAL_AGREEMENT_SIGNED_CFGAID = 25449L;
  private final Long LEASE_COUNTER_SIGNED_CFGAID = 25452L;

  private final Long SALES_DEV_USER_ID = 2371412L;

  @PostConstruct
  public void init() {
    headers = new HttpHeaders();
    headers.setBasicAuth(apiKey);
  }

  public JSONObject getApplicationByProjectId(Long projectId) {
    return getApplicationByProjectId(projectId, false);
  }

  public JSONObject getApplicationByProjectId(Long projectId, boolean withDates) {
    Assert.notNull(projectId, "Project ID can't be null");

    // First try to find an application for the Deal ID, if none is found - then try the Project ID
    Optional<Object> dealId = sqlCache.getBySql(InstallAgreementQuery.getDealId, Map.of("projectId", projectId), new SingleColumnRowMapper<>(Object.class));
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
    if (applications == null || applications.isEmpty()) {
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
    } else if (applications.isEmpty()) {
      final String message = "GOODLEAP: Unable to locate application for project ID: %s".formatted(projectId);
      //this error is ALWAYS accompanied by the error from "ARQ: Installation agreement: Failed to get loan...." turning this one off since the same info is available in the accompanying error
//      log.info(message);
      throw new NotFoundException(message);
    } else {
      application = applications.getJSONObject(0);
    }

    application.put("status", getNormalizedStatus(application.getString("status")));
    application.put("message", application.getString("status"));

    if (withDates) {
      final String loanId = application.getString("id");

      ResponseEntity<String> response = rest.exchange(host + "/loans/" + loanId + "/status", HttpMethod.GET, request, String.class);

      if (response.getStatusCode() != HttpStatus.OK) {
        throw new RuntimeException("Unable to fetch loan application status for project ID: " + projectId);
      }

      try {
        JSONObject status = new JSONObject(response.getBody());
        application.put("docsSentAt", status.get("docsSentAt"));
        application.put("docsSignedAt", status.get("docsSignedByPrimaryAt"));
      } catch (JSONException e) {
        throw new RuntimeException("Unable to read loan application status for project ID: " + projectId);
      }
    }

    return application;
  }

  public String generateApplication(PandaDocProjectDetails pd) {
    HttpHeaders jsonHeaders = new HttpHeaders();
    jsonHeaders.setBasicAuth(apiKey);
    jsonHeaders.setContentType(MediaType.APPLICATION_JSON);

    if (pd.getCloserEmail() == null) {
      throw new RuntimeException("Unable to find Closer details");
    }

    String closerPhoneNumber = "";
    if (pd.getCloserPhone() != null) {
      closerPhoneNumber = pd.getCloserPhone().replaceAll("[^\\d]+", "");
      if (closerPhoneNumber.length() > 10 && closerPhoneNumber.charAt(0) == '1') {
        closerPhoneNumber = closerPhoneNumber.substring(1);
      }
    }

    JSONObject projectDetails = new JSONObject();

    String offerId = getOfferId(pd.getLoanTerm(), pd.getInterestRate(), pd.getMailingState());
    if (offerId.isEmpty()) {
      throw new RuntimeException("Unable to find matching offer for project ID: " + pd.getProjectId());
    }

    projectDetails.put("referenceNumber", s(pd.getProjectId()));
    projectDetails.put("offerId", offerId);
    projectDetails.put("channel", "Apply");
    projectDetails.put("state", s(pd.getMailingState()));

    JSONObject loanAmount = new JSONObject();
    loanAmount.put("type", "USD");
    loanAmount.put("value", s(pd.getLoanAmount()));
    projectDetails.put("amount", loanAmount);

    JSONObject applicant = new JSONObject();
    applicant.put("firstName", s(pd.getCustomerFirstName()));
    applicant.put("lastName", s(pd.getCustomerLastName()));
    applicant.put("email", s(pd.getCustomerEmail()));
    projectDetails.put("applicant", applicant);

    JSONArray enrollments = new JSONArray();
    enrollments.put("AUTOPAY");
    projectDetails.put("enrollments", enrollments);

    JSONObject closerDetails = new JSONObject();
    closerDetails.put("firstName", pd.getCloserFirstName());
    closerDetails.put("lastName", pd.getCloserLastName());
    closerDetails.put("email", pd.getCloserEmail());
    closerDetails.put("phone", closerPhoneNumber);

    projectDetails.put("submittingUser", closerDetails);

    try {
      createUser(closerDetails);
      HttpEntity<String> request = new HttpEntity<>(projectDetails.toString(), jsonHeaders);
      ResponseEntity<String> response = rest.exchange(host + "/loans-share", HttpMethod.POST, request, String.class);

      if (response.getStatusCode() != HttpStatus.CREATED) {
        throw new RuntimeException("Unable to generate loan application for project ID: " + pd.getProjectId());
      }

      setApplicationCreatedDate(pd.getProjectId(), pd.getProposalNbr());
      JSONObject data = new JSONObject(response.getBody());
      return data.getString("link");
    } catch (Exception e) {
      throw new RuntimeException(e.getMessage());
    }
  }

  private void setApplicationCreatedDate(Long projectId, Long proposalNbr) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);

    sqlCache.updateBySql(
      GoodleapQuery.setApplicationCreatedDate, params);
  }

  public JSONArray getApplicationStipulations(Long projectId) {
    JSONObject application = getApplicationByProjectId(projectId);

    try {
      HttpEntity<String> request = new HttpEntity<>(null, headers);
      ResponseEntity<String> response = rest.exchange(host + "/loans/" + application.getString("id") + "/stipulations", HttpMethod.GET, request, String.class);

      if (response.getStatusCode() != HttpStatus.OK) {
        throw new RuntimeException("Unable to fetch loan stipulations for project ID: " + projectId);
      }

      return new JSONArray(response.getBody());

    } catch (Exception e) {
      throw new RuntimeException("Unable to read loan stipulations for project ID: " + projectId);
    }
  }

  public void sendDocs(String loanId) {
    HttpEntity<String> request = new HttpEntity<>(null, headers);
    ResponseEntity<Void> response = rest.exchange(host + "/loans/" + loanId + "/documents", HttpMethod.POST, request, Void.class);

    if (response.getStatusCode() != HttpStatus.NO_CONTENT) {
      throw new RuntimeException("Unable to send Goodleap docs with loan ID: %s".formatted(loanId));
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
      throw new RuntimeException("Unable to update loan fields for loan ID: %s".formatted(loanId));
    }
  }

  // Statuses used that aren't of type GoodleapLoanStatus are returned from the Sunlight service
  public String getNormalizedStatus(String status) {

    List<String> approved = List.of(
      GoodleapLoanStatus.APPROVED.toString(),
      GoodleapLoanStatus.FUNDED.toString(),
      GoodleapLoanStatus.SOLD.toString(),
      GoodleapLoanStatus.CONDITIONAL.toString(),
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
    } else if (pending.stream().anyMatch(status::equalsIgnoreCase)) {
      normalizedStatus = "Pending";
    } else if (declined.stream().anyMatch(status::equalsIgnoreCase)) {
      normalizedStatus = "Denied";
    } else if (cancelled.stream().anyMatch(status::equalsIgnoreCase)) {
      normalizedStatus = "Cancelled";
    }

    return normalizedStatus;
  }

  public Boolean shouldCreatePandaDocs(Long projectId) {
    try {
      JSONObject application = getApplicationByProjectId(projectId);

      if (application == null) {
        return false;
      }

      return !application.getString("status").equals("Denied") && !application.getString("status").equals("Cancelled");
    } catch (NotFoundException e) {
      return false;
    }
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

  private String getOfferId(String loanTerm, String interestRate, String mailingState) {
    HttpHeaders jsonHeaders = new HttpHeaders();
    jsonHeaders.setBasicAuth(apiKey);
    jsonHeaders.setContentType(MediaType.APPLICATION_JSON);

    HttpEntity<String> request = new HttpEntity<>(null, headers);
    ResponseEntity<String> response = rest.exchange(host + "/offers", HttpMethod.GET, request, String.class);

    if (response.getStatusCode() != HttpStatus.OK) {
      throw new RuntimeException("Unable to fetch loan stipulations for project ID: ");
    }

    JSONObject data = new JSONObject(response.getBody());
    JSONArray offers = data.getJSONArray("data");
    // Add 0.5 to adjust for ACH discount
    double interestRateValue = (Double.parseDouble(interestRate) * 100) + 0.5;
    for (int i = 0; i < offers.length(); i++) {
      JSONObject offer = offers.getJSONObject(i);
      double rate = offer.getDouble("rate");
      int term = offer.getInt("term");
      JSONArray statesArray = offer.getJSONArray("states");

      if (rate == interestRateValue && term == Integer.parseInt(loanTerm) && statesArray.length() > 0) {
        for (int j = 0; j < statesArray.length(); j++) {
          String state = statesArray.getString(j);
          if (state.equals(mailingState)) {
            return offer.getString("offerId");
          }
        }
      }
    }

    return "";
  }

  public void updateFinancialAgreementSignedValue(Long projectId, String timestampValue) {
    Map<String, Object> params = new HashMap<>();
    Instant instant = Instant.parse(timestampValue);
    params.put("projectId", projectId);
    params.put("dateValue", instant.toString());

    sqlCache.updateBySql(
      GoodleapQuery.setFinancialAgreementSigned, params);
  }

  // Used to find proposals w/ plh.financial_agreement_signed or plh.countersigned updates
  // Pushes those values to project custom fields
  public void updateWebhookFinancialFields() {
    // Get a list of countersigned updates per project
    List<ProposalFinancialFields> projectCountersignedUpdates =
      sqlCache.queryBySql(
        GoodleapQuery.getFinancialAgreementSignedUpdates,
        null,
        ProposalFinancialFields.class);

    for (ProposalFinancialFields projectFinancialField : projectCountersignedUpdates) {
      // Update Design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getFinancialAgreementSigned().toString(),
        DESIGN_AND_FINANCING_PSID, DESIGN_FINANCIAL_AGREEMENT_SIGNED_CFGAID);
      // Update Retrofit design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getFinancialAgreementSigned().toString(),
        RETROFIT_DESIGN_AND_FINANCING_PSID, RETROFIT_FINANCIAL_AGREEMENT_SIGNED_CFGAID);
      // Update Retrofit design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getFinancialAgreementSigned().toString(),
        BATTERY_DESIGN_AND_FINANCING_PSID, BATTERY_FINANCIAL_AGREEMENT_SIGNED_CFGAID);
      // Update Lease design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getFinancialAgreementSigned().toString(),
        LEASE_DESIGN_AND_FINANCING_PSID, LEASE_FINANCIAL_AGREEMENT_SIGNED_CFGAID);
    }

    List<ProposalFinancialFields> projectFinancialAgreementSignedUpdates =
      sqlCache.queryBySql(
        GoodleapQuery.getCountersignedUpdates,
        null,
        ProposalFinancialFields.class);

    for (ProposalFinancialFields projectFinancialField : projectFinancialAgreementSignedUpdates) {
      // Update Design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getCountersigned().toString(),
        DESIGN_AND_FINANCING_PSID, DESIGN_COUNTER_SIGNED_CFGAID);
      // Update Retrofit design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getCountersigned().toString(),
        RETROFIT_DESIGN_AND_FINANCING_PSID, RETROFIT_COUNTER_SIGNED_CFGAID);
      // Update Battery design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getCountersigned().toString(),
        BATTERY_DESIGN_AND_FINANCING_PSID, BATTERY_COUNTER_SIGNED_CFGAID);
      // Update Lease design and financing
      updateCfgaValue(projectFinancialField.getProjectId(), projectFinancialField.getCountersigned().toString(),
        LEASE_DESIGN_AND_FINANCING_PSID, LEASE_COUNTER_SIGNED_CFGAID);
    }
  }

  public Optional<Long> getPpsId(Long projectId , Long psId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("psId", psId);
    return
      sqlCache.getBySql(
        GoodleapQuery.getPpsId, params, new SingleColumnRowMapper<>(Long.class));
  }

  public String updateCfgaValue(Long projectId, String timestampValue, Long psId, Long cfgaId) {
    String errorMsg = "";
    Optional<Long> ppsId = getPpsId(projectId, psId);
    if (ppsId.isPresent()) {
      Map<String, Object> params = new HashMap<>();
      DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.S");
      LocalDateTime localDateTime = LocalDateTime.parse(timestampValue, inputFormatter);
      LocalDate localDate = localDateTime.toLocalDate();
      String formattedDate = localDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
      params.put("dateValue", formattedDate);
      // Sales Dev Lead's user ID
      params.put("leadOwnerUserId", SALES_DEV_USER_ID);
      params.put("projectProcessStepId", ppsId.get());
      params.put("customFieldGroupAssignmentId", cfgaId);

      sqlCache.updateBySql(
        GoodleapQuery.upsertCustomFieldValue, params);
    }
    else {
      errorMsg = String.format("No Process Step (psId=%s) found for Project ID: %s", psId, projectId);
    }

    return errorMsg;
  }

  private void createUser(JSONObject closerDetails) {
    HttpHeaders jsonHeaders = new HttpHeaders();
    jsonHeaders.setBasicAuth(apiKey);
    jsonHeaders.setContentType(MediaType.APPLICATION_JSON);
    String closerEmail = closerDetails.getString("email");
    HttpEntity<String> request = new HttpEntity<>(null, headers);
    ResponseEntity<String> response = rest.exchange(host + "/users?email=" + closerEmail, HttpMethod.GET, request, String.class);
    JSONObject data = new JSONObject(response.getBody());
    JSONArray users = data.getJSONArray("data");
    // User already exists
    if (!users.isEmpty()) {
      return;
    }

    // Matching User not found, create one
    JSONObject userDetails = new JSONObject();
    userDetails.put("firstName", closerDetails.getString("firstName"));
    userDetails.put("lastName", closerDetails.getString("lastName"));
    userDetails.put("email", closerDetails.getString("email"));
    userDetails.put("mobilePhone", closerDetails.getString("phone"));
    userDetails.put("roleId", SALES_REP_ADVANCED_INSTALLED_ROLE_ID);
    userDetails.put("password", DEFAULT_NEW_USER_PASSWORD);
    request = new HttpEntity<>(userDetails.toString(), jsonHeaders);
    try {
      ResponseEntity<String> createUserResp = rest.exchange(host + "/users", HttpMethod.POST, request, String.class);
    } catch (Exception e) {
      log.error("IARQ: Creating user in GoodLeap error={}", e.getMessage());
      throw new RuntimeException("Unable to create User");
    }
    return;
  }

  public static class NotFoundException extends RuntimeException {
    public NotFoundException(String message) {
      super(message);
    }
  }

  @Data
  private static class ProposalFinancialFields {
    Long projectId;
    Date financialAgreementSigned, countersigned;
  }
}
