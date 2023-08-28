package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.InstallAgreementQuery;
import com.albatross.api.v1.flow.enums.State;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.services.ContactService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.apache.http.client.utils.URIBuilder;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.Charset;
import java.text.DecimalFormat;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class SunpowerService {

  private final SqlCache sqlCache;
  private final ContactService contactService;

  @Value(value = "${sunpower.api.token}")
  private String basicToken;

  @Value(value = "${sunpower.api.host}")
  private String apiUrl;

  @Value(value = "${sunpower.api.spfUrl}")
  private String sunpowerSpfUrl;

  public String saveLoanFields(
      InstallAgreementService.PropLogDetail propLogDetail,
      Long projectId,
      Long proposalNbr,
      String sendVia,
      boolean isUpdate)
      throws Exception {
    JSONObject jsonContact = new JSONObject();
    JSONArray projectsArray = new JSONArray();
    JSONArray applicantsArray = new JSONArray();
    JSONArray quotesArray = new JSONArray();
    JSONObject projectDetails = new JSONObject();
    JSONObject applicantDetails = new JSONObject();
    JSONObject quoteDetails = new JSONObject();

    // If we are updating, don't return the application URL, make an API call so that proposal data gets updated in Sunpower
    if (!isUpdate) {
      Optional<Object> sunpowerUrl = getSunpowerUrl(projectId, proposalNbr);
      if (sunpowerUrl.isPresent()) {
        setCreditLastCheckedBy(projectId, "Sunpower");
        return sunpowerUrl.get().toString();
      }
    }

    DecimalFormat df2 = new DecimalFormat("#.##");
    Double aprValue = Double.valueOf(df2.format(Double.parseDouble(propLogDetail.getInterestRate()) * 100));
    if (!isUpdate && ((aprValue.equals(1.99) && propLogDetail.getLoanTerm().equals("25")) || (aprValue.equals(0.99) && propLogDetail.getLoanTerm().equals("20")))) {
      throw new Exception(
        "Error: This financial product is no longer available. Please choose another proposal number to continue.");
    }

    projectDetails.put("externalId", propLogDetail.getProjectId().toString());

    projectDetails.put(
        "apr", aprValue
        );
    projectDetails.put("isACH", true);

    if (sendVia == null) {
      sendVia = "embedded";
    }

    projectDetails.put("sendVia", sendVia);

    if (propLogDetail.getLoanAmount() == null) {
      String message = "No Loan Amount found for this proposal";
      log.error("SUNPWR: Error opening or updating Loan Application for Sunpower: {}", message);
      throw new Exception(message);
    } else {
      try {
        quoteDetails.put("loanAmount", Integer.parseInt(propLogDetail.getLoanAmount()));
      } catch (NumberFormatException nfe) {
        quoteDetails.put(
            "loanAmount", Math.floor(Double.parseDouble(propLogDetail.getLoanAmount())));
      }
    }

    quotesArray.put(quoteDetails);

    Contact contact = contactService.getContactByProjectId(projectId);


    projectDetails.put("salesRepresentativeEmail", "support@blueravensolar.com");
    projectDetails.put(
        "salesRepresentativeFirstName", "BRS");
    projectDetails.put(
        "salesRepresentativeLastName", "Support");
    projectDetails.put("term", Integer.parseInt(propLogDetail.getLoanTerm()) * 12);
    projectDetails.put("productType", "Solar");
    projectDetails.put("installStreet", contact.getStreet1());
    projectDetails.put("installCity", contact.getCity());

    String state = contact.getState();
    if (state.length() != 2) {
      State stateObj = State.valueOfName(state);
      state = stateObj.getAbbreviation();
    }

    projectDetails.put("installStateName", state);

    String contactZipcode = contact.getPostalCode().substring(0,5);
    projectDetails.put("installZipCode", contactZipcode);
    applicantDetails.put("isPrimary", true);


    applicantDetails.put("firstName", contact.getFirstName());
    applicantDetails.put("lastName", contact.getLastName());

    String phone = (contact.getMobile() != null && !contact.getMobile().isEmpty()) ? contact.getMobile() : contact.getPhone();
    phone = phone.replaceAll("[^0-9]", "");
    if (phone.startsWith("1")) {
      phone = phone.substring(1);
    }

    applicantDetails.put("phone", phone);

    if (contact.getEmail() != null && contact.getEmail().contains("@")) {
      applicantDetails.put("email", contact.getEmail());
    }

    applicantDetails.put("mailingStreet", contact.getStreet1());
    applicantDetails.put("mailingCity", contact.getCity());
    applicantDetails.put("mailingStateName", state);
    applicantDetails.put("mailingZipCode", contactZipcode);
    applicantDetails.put("residenceStreet", contact.getStreet1());
    applicantDetails.put("residenceCity", contact.getCity());
    applicantDetails.put("residenceStateName", state);
    applicantDetails.put("residenceZipCode", contactZipcode);

    applicantsArray.put(applicantDetails);

    projectDetails.put("applicants", applicantsArray);
    projectDetails.put("quotes", quotesArray);
    projectsArray.put(projectDetails);
    jsonContact.put("projects", projectsArray);

    HttpResponse res =
        POST(
            "active-bpel/rt/Customer",
            IOUtils.toInputStream(jsonContact.toString(), (Charset) null));
    JSONObject respJson = res.getJSON();
    JSONObject customerResponse = respJson.getJSONObject("customerResponse");
    JSONObject status = customerResponse.getJSONObject("status");
    Boolean success = status.getBoolean("success");
    String result = "";

    if (success) {
      String message = status.getString("message");
      if (message.equals("OK")) {
        result = customerResponse.getString("activationURL");
        setSunpowerUrl(projectId, proposalNbr, result);
      } else if (message.equals("Quote Updated")) {
        Optional<Object> sunpowerUrl = getSunpowerUrl(projectId);
        if (sunpowerUrl.isPresent()) {
          setSunpowerUrl(projectId, proposalNbr, sunpowerUrl.get().toString());
          return sunpowerUrl.get().toString();
        }

        result = "Quote Updated";
      }
    } else {
      String message = status.getString("message");
      log.error("SUNPWR: Error opening or updating Loan Application for SunPower: {}", message);
      if (message.equalsIgnoreCase("Quote is expired")) {
        throw new Exception("This quote is expired, please renew the quote in order to proceed by tapping the Update or Renew Quote button");
      }

      throw new Exception("Error opening or updating Loan Application for SunPower: " + message);
    }

    setCreditLastCheckedBy(projectId, "Sunpower");
    return result;
  }

  public String openDolphinLoanApp(
    InstallAgreementService.PropLogDetail pd) {
    try {
      Contact contact = contactService.getContactByProjectId(pd.getProjectId());
      URIBuilder b = new URIBuilder(sunpowerSpfUrl);

      Double storageSize =
        Double.parseDouble(
          pd.getStorageSizeKwh() == null
            ? "0"
            : pd.getStorageSizeKwh());

      Optional<SunpowerProducts> sunpowerProducts = getSunpowerProducts(pd);
      if (!sunpowerProducts.isPresent()) {
        return sunpowerSpfUrl;
      }

      SunpowerProducts sp = sunpowerProducts.get();

      if (storageSize < 1) {
        b.addParameter("project_type", "SOLAR");
      }
      else {
        b.addParameter("project_type", "SOLAR_STORAGE");
      }

      // Convert from Watts to kW
      Double projectSize =
        Double.parseDouble(
          pd.getSystemSize() == null
            ? "0"
            : pd.getSystemSize());

      BigDecimal roundedValue = new BigDecimal(projectSize).setScale(2, RoundingMode.HALF_UP);
      BigDecimal roundedLoanAmount = new BigDecimal(pd.getLoanAmount()).setScale(2, RoundingMode.HALF_UP);

      b.addParameter("project_size", roundedValue.toString());
      b.addParameter("financial_amount", s(roundedLoanAmount));
      b.addParameter("financial_product_id", s(sp.getFinancialProductId()));
      b.addParameter("inverter_id", s(sp.getInverterId()));
      b.addParameter("panel_id", s(sp.getPanelId()));
      b.addParameter("storage_id", s(sp.getStorageId()));
      b.addParameter("project_address_line1", s(pd.getProjectStreet1()));
      b.addParameter("project_address_line2", s(pd.getProjectStreet2()));
      b.addParameter("project_city", s(pd.getProjectCity()));
      b.addParameter("project_state", s(pd.getProjectState()));
      b.addParameter("project_zip_code", s(pd.getProjectZipCode()));
      b.addParameter("project_residence_use", "Primary Residence");
      b.addParameter("borrower_first_name", s(contact.getFirstName()));
      b.addParameter("borrower_last_name", s(contact.getLastName()));

      String phone = (contact.getMobile() != null && !contact.getMobile().isEmpty()) ? contact.getMobile() : contact.getPhone();
      phone = phone.replaceAll("[^0-9]", "");
      if (phone.startsWith("1")) {
        phone = phone.substring(1);
      }

      b.addParameter("borrower_phone", formatPhoneNumber(phone));

      if (contact.getEmail() != null && contact.getEmail().contains("@")) {
        b.addParameter("borrower_email", s(contact.getEmail()));
        b.addParameter("borrower_email_confirm", s(pd.getEmail()));
      }

      if ((pd.getProjectStreet1() == null && contact.getStreet1() == null ||
        pd.getProjectStreet1() != null && pd.getProjectStreet1().equals(contact.getStreet1()))
        && (pd.getProjectStreet2() == null && contact.getStreet2() == null ||
        pd.getProjectStreet2() != null && pd.getProjectStreet2().equals(contact.getStreet2()))
        && (pd.getProjectCity() == null && contact.getCity() == null ||
        pd.getProjectCity() != null && pd.getProjectCity().equals(contact.getCity()))) {
        b.addParameter("borrower_address_same_as_project", "true");
      } else {
        b.addParameter("borrower_address_same_as_project", "false");
        b.addParameter("borrower_address_line1", s(contact.getStreet1()));
        b.addParameter("borrower_address_line2", s(contact.getStreet2()));
        b.addParameter("borrower_city", s(contact.getCity()));

        String state = contact.getState();
        if (state.length() != 2) {
          State stateObj = State.valueOfName(state);
          state = stateObj.getAbbreviation();
        }

        b.addParameter("borrower_state", s(state));
        b.addParameter("borrower_zip_code", s(contact.getPostalCode()));
      }

      return b.build().toString().replaceAll("\\+", "%20");
    } catch (Exception e) {
      log.error("SUNPWR: Error opening loan application for Sunpower: {}", e.getMessage());
      return sunpowerSpfUrl;
    }
  }

  private static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length() == 10) {
      String areaCode = phoneNumber.substring(0, 3);
      String firstPart = phoneNumber.substring(3, 6);
      String secondPart = phoneNumber.substring(6);

      return areaCode + "-" + firstPart + "-" + secondPart;
    } else {
      return phoneNumber;
    }
  }

  public JSONObject getApplicationDetails(Long projectId, Long proposalNbr) {
    JSONObject returnApplication = new JSONObject();
    returnApplication.put("type", "Sunpower");

    // Check if there is a SunPower URL stored for this Project & Proposal Number
    Optional<Object> sunpowerUrl = getSunpowerUrl(projectId, proposalNbr);
    if (sunpowerUrl.isPresent()) {
      returnApplication.put("applicationUrl", sunpowerUrl.get().toString());
    } else {
      // Check if there is a SunPower URL stored for this Project (any Proposal Number)
      Optional<Object> sunpowerUrlPerProject = getSunpowerUrl(projectId);
      if (sunpowerUrlPerProject.isPresent()) {
        returnApplication.put("applicationUrl", sunpowerUrlPerProject.get().toString());
      } else {
        returnApplication.put("applicationUrl", "");
      }
    }

    return returnApplication;
  }

  public String sendLoanDocs(Long projectId) throws Exception {
    JSONObject creditJson = new JSONObject();
    creditJson.put("externalId", projectId.toString());
    HttpResponse creditResp =
        GET(
            "active-bpel/rt/Contract/" + projectId,
            IOUtils.toInputStream(creditJson.toString(), (Charset) null));
    JSONObject respJson = creditResp.getJSON();
    JSONObject contractResponse = respJson.getJSONObject("contractResponse");
    JSONObject status = contractResponse.getJSONObject("status");
    Boolean success = status.getBoolean("success");

    if (success) {
      return "Loan agreement created successfully";
    } else {
      String message = status.getString("message");
      //log.error("SUNPWR: Error creating Loan agreement for Sunpower: {}", message);
      throw new Exception(message);
    }
  }

  private Optional<Object> getSunpowerUrl(Long projectId, Long proposalNbr) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);
    return sqlCache.getBySql(
        InstallAgreementQuery.getSunpowerUrl, params, new SingleColumnRowMapper<>(Object.class));
  }

  private Optional<Object> getSunpowerUrl(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    return sqlCache.getBySql(
        InstallAgreementQuery.getSunpowerUrlPerProject,
        params,
        new SingleColumnRowMapper<>(Object.class));
  }

  private void setSunpowerUrl(Long projectId, Long proposalNbr, String url) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("proposalNbr", proposalNbr);
    params.put("url", url);
    sqlCache.updateBySql(InstallAgreementQuery.setSunpowerUrl, params);
  }

  public void setCreditLastCheckedBy(Long projectId, String financier) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("creditLastCheckedBy", financier);
    sqlCache.updateBySql(InstallAgreementQuery.setCreditLastCheckedBy, params);
  }

  private Optional<SunpowerProducts> getSunpowerProducts(InstallAgreementService.PropLogDetail pd) {
    HashMap<String, Object> params = new HashMap<>();

    Double interestRate =
      Double.parseDouble(
        pd.getInterestRate() == null
          ? "0"
          : pd.getInterestRate()) * 100;
    BigDecimal interestRateRounded = new BigDecimal(interestRate).setScale(2, RoundingMode.HALF_UP);

    params.put("financialName", pd.getLoanTerm() + " Year Loan at " + interestRateRounded + "% APR");
    params.put("inverterName", pd.getInverterCustomGetting());

    HashSet<String> panelNames = new HashSet<>(Arrays.asList("REC", "SPR-U400-BLK", "SPR-U4000-BLK", "SEG SOLAR INC. 405"));
    if (panelNames.contains(pd.getPanel())) {
      params.put("panelName", pd.getPanel());
    }
    else {
      params.put("panelName", pd.getPanel() + " " + pd.getPanelWattage());
    }

    params.put("batteryName", pd.getStorageBrand() + " " + pd.getStorageSizeKwh());
    return sqlCache.getBySql(
      InstallAgreementQuery.getSunpowerProducts, params, SunpowerProducts.class);
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

  private HttpResponse request(String method, String uri, InputStream content) throws Exception {
    String url = apiUrl + uri;
    log.debug("SUNPOWER: sending to SunPower url: {}", url);
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

  @Data
  public static class SunpowerProducts {
    private String financialProductId, inverterId, panelId, storageId;
  }
}
