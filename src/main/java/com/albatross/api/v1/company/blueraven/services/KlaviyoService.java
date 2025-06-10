package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.GenesysQuery;
import com.albatross.api.v1.company.blueraven.services.queries.KlaviyoQuery;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.util.ObjectUtils;

import java.math.BigDecimal;
import java.net.http.HttpClient;

import java.io.InputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.*;
import java.time.LocalDate;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class KlaviyoService {

  @Value(value = "${klaviyo.api.host}")
  private String apiUrl;

  @Value(value = "${klaviyo.api.token}")
  private String basicToken;

  private final SqlCache sqlCache;

  private final LocalDate KLAVIYO_START_DATE = LocalDate.of(2024, 9, 28);

  private final String KLAVIYO_EMAIL_LIST_ID = "RdueKz";
  private final String KLAVIYO_SMS_LIST_ID = "SnT5Dr";
  private final String KLAVIYO_MASTER_CONTACT_LIST_ID = "Rmj4vB";

  @Data
  public static class CustomContact {
    Long id, contactTypeId, countryId;
    String firstName, lastName, street1, street2, phone, mobile, city, postalCode, email, state;
    Date dateCreated;
  }

  // Used to handle contact create/updates
  public void handleContact(Long contactId, List<CustomFieldValue> values, boolean isUpdate, boolean isDigitalLead) {
    // Return if token is not set
    if (ObjectUtils.isEmpty(basicToken) || basicToken.length() < 5) {
      return;
    }

    String url = apiUrl + "/profiles";
    try {
      CustomContact contact = getContact(contactId, true);

      if (isUpdate) {
        ZonedDateTime contactCreatedDate = contact.getDateCreated().toInstant().atZone(ZoneId.of("US/Mountain"));
        // Check to see if this contact was create before the Klaviyo integration was deployed
        // if so, do not attempt an update as it will not be in Klaviyo
        if (contactCreatedDate.toLocalDate().isBefore(KLAVIYO_START_DATE)) {
          return;
        }
      }

      JSONObject contactJson = buildContactJson(contact, values, isUpdate);
      String klaviyoProfileId = isUpdate ? getKlaviyoProfileId(contact.getEmail()) : null;

      if (isUpdate) {
        updateContact(url, klaviyoProfileId, contactJson);
      } else {
        createContact(url, contactJson, contact, isDigitalLead);
      }

      //log.info("KLAVIYO: Successfully posted contactId="+ contactId + ", url="+url);
    } catch (Exception e) {
      String msg = "KLAVIYO: Error in posting contactId="+ contactId + ", msg=" +e.getMessage() + ", url="+url;
      log.error(msg);
    }
  }

  private JSONObject buildContactJson(CustomContact contact, List<CustomFieldValue> values, boolean isUpdate) {
    JSONObject data = new JSONObject();
    data.put("type", "profile");

    JSONObject attributes = new JSONObject();
    attributes.put("email", contact.getEmail());
    attributes.put("external_id", contact.getId());
    attributes.put("first_name", contact.getFirstName());
    attributes.put("last_name", contact.getLastName());

    JSONObject location = new JSONObject();
    location.put("address1", contact.getStreet1());
    location.put("address2", contact.getStreet2());
    location.put("city", contact.getCity());
    location.put("region", contact.getState());
    location.put("zip", contact.getPostalCode());
    attributes.put("location", location);

    if (!isUpdate) {
      attributes.put("phone_number", formatPhoneNumber(contact.getPhone()));
    }

    JSONObject properties = new JSONObject();
    getCfvValues(properties, values);
    attributes.put("properties", properties);

    data.put("attributes", attributes);
    return new JSONObject().put("data", data);
  }

  private String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber == null) return null;
    phoneNumber = phoneNumber.replaceAll("[^\\d]+", "");
    return phoneNumber.startsWith("1") ? "+" + phoneNumber : "+1" + phoneNumber;
  }

  private void updateContact(String url, String klaviyoProfileId, JSONObject contactJson) throws Exception {
    contactJson.getJSONObject("data").put("id", klaviyoProfileId);
    HttpResponse resp = PATCH(url + "/" + klaviyoProfileId, contactJson.toString());
    handleResponse(resp, "updating contact");
  }

  private void createContact(String url, JSONObject contactJson, CustomContact contact, boolean isDigitalLead) throws Exception {
    HttpResponse resp = POST(url, IOUtils.toInputStream(contactJson.toString(), StandardCharsets.UTF_8));
    handleResponse(resp, "creating contact");

    if (isDigitalLead) {
      JSONObject dataResp = resp.getJSON().getJSONObject("data");
      String klaviyoProfileId = dataResp.getString("id");
      subscribeContactToList(klaviyoProfileId, KLAVIYO_MASTER_CONTACT_LIST_ID);
      subscribeToMessaging(klaviyoProfileId, contact.getEmail(), formatPhoneNumber(contact.getPhone()));
    }

  }

  private void subscribeToMessaging(String klaviyoProfileId, String email, String phoneNumber) throws Exception {
    JSONObject emailRequest = generateSubscribeEmailProfilesRequestBody(klaviyoProfileId, email);
    HttpResponse emailResp = POST(apiUrl + "/profile-subscription-bulk-create-jobs/", IOUtils.toInputStream(emailRequest.toString(), StandardCharsets.UTF_8));
    handleResponse(emailResp, "subscribing to email");

    JSONObject smsRequest = generateSubscribeSmsProfilesRequestBody(klaviyoProfileId, email, phoneNumber);
    HttpResponse smsResp = POST(apiUrl + "/profile-subscription-bulk-create-jobs/", IOUtils.toInputStream(smsRequest.toString(), StandardCharsets.UTF_8));
    handleResponse(smsResp, "subscribing to SMS");
  }

  // Used to set the project id on the profile/contact in Klaviyo, called when a project is created
  public void updateProjectId(Long contactId, Long projectId) {
    // Return if token is not set
    if (ObjectUtils.isEmpty(basicToken) || ObjectUtils.isEmpty(basicToken == null) || basicToken.length() < 5) {
      return;
    }

    CustomContact contact = getContact(contactId, true);

    String url = apiUrl + "/profiles";
    JSONObject contactJson = new JSONObject();
    JSONObject attributes = new JSONObject();
    JSONObject properties = new JSONObject();
    JSONObject data = new JSONObject();

    data.put("type", "profile");

    try {
      properties.put("Project ID", projectId);
      attributes.put("properties", properties);
      data.put("attributes", attributes);
      contactJson.put("data", data);

      String klaviyoProfileId = getKlaviyoProfileId(contact.getEmail());
      data.put("id", klaviyoProfileId);

      HttpResponse resp = PATCH(url + "/" + klaviyoProfileId, contactJson.toString());
      handleResponse(resp, "updating project id");

      //log.info("KLAVIYO: Successfully updated project id for contactId="+ contactId + ", url="+url);
    } catch (Exception e) {
      String msg = "KLAVIYO: Error in updating project id for contactId="+ contactId + ", msg=" +e.getMessage() + ", url="+url;
      log.error(msg);
    }
  }

  // Used to create the request body for subscribing to email
  private JSONObject generateSubscribeEmailProfilesRequestBody(String klaviyoId, String email) {
    JSONObject subscriberProfile = new JSONObject();
    JSONObject data = new JSONObject();

    data.put("type", "profile-subscription-bulk-create-job");

    JSONObject attributes = new JSONObject();
    data.put("attributes", attributes);

    JSONObject profiles = new JSONObject();
    attributes.put("profiles", profiles);

    JSONArray profilesData = new JSONArray();
    profiles.put("data", profilesData);

    JSONObject profile = new JSONObject();
    profile.put("id", klaviyoId);
    profilesData.put(profile);

    profile.put("type", "profile");

    JSONObject profileAttributes = new JSONObject();
    profile.put("attributes", profileAttributes);

    JSONObject subscriptions = new JSONObject();
    profileAttributes.put("subscriptions", subscriptions);
    profileAttributes.put("email", email);

    JSONObject emailSub = new JSONObject();
    subscriptions.put("email", emailSub);

    JSONObject emailMarketing = new JSONObject();
    emailSub.put("marketing", emailMarketing);

    emailMarketing.put("consent", "SUBSCRIBED");

    attributes.put("historical_import", false);

    JSONObject relationships = new JSONObject();
    data.put("relationships", relationships);

    JSONObject list = new JSONObject();
    relationships.put("list", list);

    JSONObject emailList = new JSONObject();

    emailList.put("type", "list");

    emailList.put("id", KLAVIYO_EMAIL_LIST_ID);

    list.put("data", emailList);

    subscriberProfile.put("data", data);
    return subscriberProfile;
  }

  // Used to create the request body for subscribing to SMS
  private JSONObject generateSubscribeSmsProfilesRequestBody(String klaviyoId, String email, String phoneNumber) {
    JSONObject subscriberProfile = new JSONObject();
    JSONObject data = new JSONObject();

    data.put("type", "profile-subscription-bulk-create-job");

    JSONObject attributes = new JSONObject();
    data.put("attributes", attributes);

    JSONObject profiles = new JSONObject();
    attributes.put("profiles", profiles);

    JSONArray profilesData = new JSONArray();
    profiles.put("data", profilesData);

    JSONObject profile = new JSONObject();
    profile.put("id", klaviyoId);
    profilesData.put(profile);

    profile.put("type", "profile");

    JSONObject profileAttributes = new JSONObject();
    profile.put("attributes", profileAttributes);

    JSONObject subscriptions = new JSONObject();
    profileAttributes.put("subscriptions", subscriptions);
    profileAttributes.put("email", email);
    profileAttributes.put("phone_number", phoneNumber);

    JSONObject smsSub = new JSONObject();
    subscriptions.put("sms", smsSub);

    JSONObject smsMarketing = new JSONObject();
    smsSub.put("marketing", smsMarketing);

    smsMarketing.put("consent", "SUBSCRIBED");

    attributes.put("historical_import", false);

    JSONObject relationships = new JSONObject();
    data.put("relationships", relationships);

    JSONObject list = new JSONObject();
    relationships.put("list", list);

    JSONObject smsList = new JSONObject();

    smsList.put("type", "list");
    smsList.put("id", KLAVIYO_SMS_LIST_ID);

    list.put("data", smsList);

    subscriberProfile.put("data", data);
    return subscriberProfile;
  }

  private JSONObject generateActionRequestBody(String klaviyoId, String email, String metricName, JSONObject contactProperties) {
    JSONObject actionRequestBody = new JSONObject();
    JSONObject data = new JSONObject();
    data.put("type", "event");

    JSONObject attributes = new JSONObject();
    data.put("attributes", attributes);

    // Needed but not used
    JSONObject properties = new JSONObject();
    attributes.put("properties", properties);

    JSONObject metric = new JSONObject();
    JSONObject metricData = new JSONObject();
    JSONObject metricAttributes = new JSONObject();
    metricData.put("type", "metric");
    metric.put("data", metricData);
    metricAttributes.put("name", metricName);

    metricData.put("attributes", metricAttributes);
    attributes.put("metric", metric);

    JSONObject profile = new JSONObject();
    profile.put("id", klaviyoId);
    JSONObject profileData = new JSONObject();
    profileData.put("type", "profile");

    JSONObject profileAttributes = new JSONObject();
    JSONObject profileProperties = new JSONObject();
    profileAttributes.put("properties", profileProperties);
    profileProperties.put("email", email);
    for (String key : contactProperties.keySet()) {
      profileProperties.put(key, contactProperties.get(key));
    }

    profileData.put("attributes", profileAttributes);
    profile.put("data", profileData);
    attributes.put("profile", profile);

    actionRequestBody.put("data", data);
    return actionRequestBody;
  }

  private void subscribeContactToList(String klaviyoProfileId, String listId) {
    try {
      // Create the JSON payload
      JSONObject requestBody = new JSONObject();
      JSONArray dataArray = new JSONArray();

      JSONObject profile = new JSONObject();
      profile.put("type", "profile");
      profile.put("id", klaviyoProfileId);

      dataArray.put(profile);
      requestBody.put("data", dataArray);

      HttpResponse resp = POST(apiUrl + "/lists/" + listId + "/relationships/profiles", IOUtils.toInputStream(requestBody.toString(), (Charset) null));
      handleResponse(resp, "adding contact");
    } catch (Exception e) {
      String msg = "KLAVIYO: Error in posting klaviyoProfileId="+ klaviyoProfileId + ", listId=" + listId + ", msg=" +e.getMessage();
      log.error(msg);
    }
  }

  private void handleResponse(HttpResponse resp, String action) throws Exception {
    Set<Integer> successResponseCodes = Set.of(200, 201, 202, 204);
    // If response is unsuccessful, get error message and throw an exception
    if (!successResponseCodes.contains(resp.getResponseCode())) {
      JSONObject errorResp = resp.getJSON();
      JSONArray errors = errorResp.getJSONArray("errors");
      String errorMessage = errors.toList().stream()
        .map(error -> ((Map<?, ?>) error).get("detail").toString())
        .collect(Collectors.joining(", "));
      throw new Exception("Error " + action + ": " + errorMessage);
    }
  }

  private void executeAction(JSONObject actionRequestBody) throws Exception {
    String subscribeUrl = apiUrl + "/events/";
    // Subscribe the contact/profile to Email messaging, also adds them to the list
    HttpResponse resp = POST(subscribeUrl, IOUtils.toInputStream(actionRequestBody.toString(), (Charset) null));
    handleResponse(resp, "executing action");
  }

  public void processKlaviyoContacts() {
    populateCronContactLists(KlaviyoQuery.getDigitalCronContacts);
  }

  private void populateCronContactLists(String contactListQuery) {
    // Get list of Contacts that need to be updated in Klaviyo
    List<KlaviyoContactProperties> contacts = sqlCache.queryBySql(contactListQuery, null, KlaviyoContactProperties.class);
    for (KlaviyoContactProperties contact : contacts) {
      try {
        updateKlaviyoContactProperties(contact);
      } catch (Exception e) {
        log.error("KLAVIYO: Error during cron - updating projectId={}, msg={}", contact.getProjectId(), e.getMessage());
      }
    }
  }

  // Used by the cron query to update only certain values
  private void updateKlaviyoContactProperties(KlaviyoContactProperties klaviyoContactProperties) {
    if (ObjectUtils.isEmpty(basicToken) || ObjectUtils.isEmpty(basicToken == null)) {
      return;
    }

    String url = apiUrl + "/profiles";
    JSONObject contactJson = new JSONObject();
    JSONObject attributes = new JSONObject();
    JSONObject properties;
    JSONObject data = new JSONObject();
    data.put("type", "profile");

    try {
      // call populatePropertiesForCronContacts() in place of code below
      properties = populatePropertiesForCronContacts(klaviyoContactProperties);
      attributes.put("properties", properties);
      data.put("attributes", attributes);
      contactJson.put("data", data);

      String klaviyoProfileId = getKlaviyoProfileId(klaviyoContactProperties.getEmail());
      if (klaviyoProfileId == null) {
        return;
      }

      data.put("id", klaviyoProfileId);
      HttpResponse resp = PATCH(url + "/" + klaviyoProfileId, contactJson.toString());
      handleResponse(resp, "updating contact during cron");
      //log.info("KLAVIYO: Successfully updated contact during cron for projectId="+ klaviyoContactProperties.getProjectId());
    } catch (Exception e) {
      String msg = "KLAVIYO: Error updating contact during cron for projectId="+ klaviyoContactProperties.getProjectId() + ", msg=" +e.getMessage();
      log.error(msg);
    }
  }

  private JSONObject populatePropertiesForCronContacts(KlaviyoContactProperties klaviyoContactProperties) {
    JSONObject properties = new JSONObject();

    properties.put("gclid", klaviyoContactProperties.getGclid() != null ? klaviyoContactProperties.getGclid() : "");
    properties.put("fbclid", klaviyoContactProperties.getFbclid() != null ? klaviyoContactProperties.getFbclid() : "");
    properties.put("twclid", klaviyoContactProperties.getTwclid() != null ? klaviyoContactProperties.getTwclid() : "");
    properties.put("msclid", klaviyoContactProperties.getMsclid() != null ? klaviyoContactProperties.getMsclid() : "");
    properties.put("UTM Source", klaviyoContactProperties.getUtmSource() != null ? klaviyoContactProperties.getUtmSource() : "");
    properties.put("UTM Medium", klaviyoContactProperties.getUtmMedium() != null ? klaviyoContactProperties.getUtmMedium() : "");
    properties.put("UTM Content", klaviyoContactProperties.getUtmContent() != null ? klaviyoContactProperties.getUtmContent() : "");
    properties.put("UTM Campaign", klaviyoContactProperties.getUtmCampaign() != null ? klaviyoContactProperties.getUtmCampaign() : "");
    properties.put("Vendor ID", klaviyoContactProperties.getVendorId() != null ? klaviyoContactProperties.getVendorId() : "");
    properties.put("Lead Price", klaviyoContactProperties.getLeadPrice() != null ? klaviyoContactProperties.getLeadPrice() : 0.0);
    properties.put("Tier", klaviyoContactProperties.getTier() != null ? klaviyoContactProperties.getTier() : "");
    properties.put("Electric Monthly", klaviyoContactProperties.getElectricMonthly() != null ? klaviyoContactProperties.getElectricMonthly() : 0.0);
    properties.put("Roof Material", klaviyoContactProperties.getRoofMaterial() != null ? klaviyoContactProperties.getRoofMaterial() : "");
    properties.put("Sun Exposure", klaviyoContactProperties.getSunExposure() != null ? klaviyoContactProperties.getSunExposure() : "");
    properties.put("Homeowner", klaviyoContactProperties.getHomeowner() != null ? klaviyoContactProperties.getHomeowner() : "");
    properties.put("Lead Level", klaviyoContactProperties.getLeadLevel() != null ? klaviyoContactProperties.getLeadLevel() : 0);
    properties.put("Credit Score", klaviyoContactProperties.getCreditScore() != null ? klaviyoContactProperties.getCreditScore() : 0);
    properties.put("Lead Created Date", klaviyoContactProperties.getLeadCreatedDate() != null ? klaviyoContactProperties.getLeadCreatedDate().toString() : "");
    properties.put("Lead Status", klaviyoContactProperties.getLeadStatus() != null ? klaviyoContactProperties.getLeadStatus() : "");
    properties.put("Aidaform Recipient", klaviyoContactProperties.getAidaformRecipient() != null ? klaviyoContactProperties.getAidaformRecipient() : 0);
    properties.put("Household Income", klaviyoContactProperties.getHouseholdIncome() != null ? klaviyoContactProperties.getHouseholdIncome() : 0.0);
    properties.put("Roof Design", klaviyoContactProperties.getRoofDesign() != null ? klaviyoContactProperties.getRoofDesign() : "");
    properties.put("Unqualified Reason", klaviyoContactProperties.getUnqualifiedReason() != null ? klaviyoContactProperties.getUnqualifiedReason() : "");
    properties.put("Company Brand", klaviyoContactProperties.getCompanyBrand() != null ? klaviyoContactProperties.getCompanyBrand() : "");

    if (klaviyoContactProperties.getProjectId() != null) {
      properties.put("Is Retargeted", klaviyoContactProperties.isRetargeted());
      properties.put("Primary Appointment Outcome", klaviyoContactProperties.getCloserAppointmentOutcomeName() != null ? klaviyoContactProperties.getCloserAppointmentOutcomeName() : "");
      properties.put("Project Status", klaviyoContactProperties.getCompanyProjectStatusType() != null ? klaviyoContactProperties.getCompanyProjectStatusType() : "");
      properties.put("Utility Provider", klaviyoContactProperties.getUtilityCompanyName() != null ? klaviyoContactProperties.getUtilityCompanyName() : "");
      properties.put("Pitch Date", klaviyoContactProperties.getFirstAppointmentPitched() != null ? klaviyoContactProperties.getFirstAppointmentPitched() : "");
      properties.put("Most Recent Note Date", klaviyoContactProperties.getLatestActivityNoteDate() != null ? klaviyoContactProperties.getLatestActivityNoteDate() : "");
      properties.put("Book Date", klaviyoContactProperties.getCompleteDateBooking() != null ? klaviyoContactProperties.getCompleteDateBooking() : "");
      properties.put("Primary Appointment Date", klaviyoContactProperties.getPrimaryAppointmentDate() != null ? klaviyoContactProperties.getPrimaryAppointmentDate() : "");
      properties.put("Sold Date (FDA)", klaviyoContactProperties.getFinalDesignSignedDate() != null ? klaviyoContactProperties.getFinalDesignSignedDate() : "");
      properties.put("Final Design Complete Date", klaviyoContactProperties.getFinalDesignCompleteDate() != null ? klaviyoContactProperties.getFinalDesignCompleteDate().toString() : "");
      properties.put("Substantial Completion Date", klaviyoContactProperties.getSubstantialCompletionDate() != null ? klaviyoContactProperties.getSubstantialCompletionDate().toString() : "");
      properties.put("Project Created Date", klaviyoContactProperties.getProjectCreatedDate() != null ? klaviyoContactProperties.getProjectCreatedDate().toString() : "");
      properties.put("Lead Source Detail", klaviyoContactProperties.getLeadSourceDetailName() != null ? klaviyoContactProperties.getLeadSourceDetailName() : "");
      properties.put("Lead Source", klaviyoContactProperties.getLeadSource() != null ? klaviyoContactProperties.getLeadSource() : "");
      properties.put("System Size", klaviyoContactProperties.getSystemSize() != null ? klaviyoContactProperties.getSystemSize() : "");
    }

    return properties;
  }

  private void getCfvValues(JSONObject properties, List<CustomFieldValue> values) {
    for (CustomFieldValue cfv : values) {
      String value = "";

      // Handle single integer value
      if (cfv.getIntValue() != null) {
        if (cfv.getListOfValues() != null) {
          Map<Long, String> lovMap = cfv.getListOfValues().stream()
            .collect(Collectors.toMap(ListOfValue::getId, ListOfValue::getName));
          value = lovMap.getOrDefault(cfv.getIntValue(), cfv.getFieldValue());
        } else {
          value = cfv.getFieldValue();
        }
      }
      // Handle array of integer values
      else if (cfv.getIntArrayValue() != null && !cfv.getIntArrayValue().isEmpty()) {
        if (cfv.getListOfValues() != null) {
          Map<Long, String> lovMap = cfv.getListOfValues().stream()
            .collect(Collectors.toMap(ListOfValue::getId, ListOfValue::getName));
          value = cfv.getIntArrayValue().stream()
            .map(lovMap::get)
            .filter(Objects::nonNull)
            .collect(Collectors.joining(", "));
        }
      }
      // Handle text value
      else if (cfv.getTextValue() != null) {
        value = cfv.getTextValue();
      }

      // Map field names to property keys
      if (cfv.getFieldName() != null) {
        switch (cfv.getFieldName()) {
          case "Lead Source":
            properties.put("Lead Source", value);
            break;
          case "Lead Source Detail":
            properties.put("Lead Source Detail", value);
            break;
          case "Lead Status":
            properties.put("Lead Status", value);
            break;
          case "Lead Level":
            properties.put("Lead Level", cfv.getIntValue() == null ? "" : cfv.getIntValue().toString());
            break;
          case "Twitter Click ID":
            properties.put("twclid", value);
            break;
          case "Facebook Click ID":
            properties.put("fbclid", value);
            break;
          case "Microsoft Click ID":
            properties.put("msclid", value);
            break;
          case "UTM Source":
            properties.put("UTM Source", value);
            break;
          case "UTM Medium":
            properties.put("UTM Medium", value);
            break;
          case "UTM Content":
            properties.put("UTM Content", value);
            break;
          case "UTM Campaign":
            properties.put("UTM Campaign", value);
            break;
          case "Company Brand":
            properties.put("Company Brand", value);
            break;
          default:
            break;
        }
      }
    }
  }

  // Get Klaviyo's internal id for a contact
  private String getKlaviyoProfileId(String email) throws Exception {
    try {
      String filterParam = String.format("?filter=equals(email,\"%s\")", email);
      String url = apiUrl + "/profiles" + filterParam;
      HttpResponse resp = GET(url);
      handleResponse(resp, "getting Klaviyo contact profile Id");
      JSONObject dataResp = resp.getJSON();
      JSONArray dataJsonArray = dataResp.getJSONArray("data");
      // No profile found in Klaviyo for this email
      if (dataJsonArray.isEmpty()) {
        return null;
      }

      JSONObject data = dataJsonArray.getJSONObject(0);
      return data.getString("id");
    } catch (Exception e) {
      String errorMessage = "Error getting Klaviyo contact profile Id:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
      throw new Exception(errorMessage);
    }
  }

  public void postUnqualifiedEvent(Long projectId) {
    try {
      JSONObject klaviyoData = new JSONObject();
      KlaviyoContactProperties unqualifiedEventProperties = sqlCache.getBySql(KlaviyoQuery.getUnqualifiedEventProperties, Map.of("projectId", projectId), KlaviyoContactProperties.class)
        .orElse(null);

      if (unqualifiedEventProperties != null) {
        klaviyoData.put("Sales Dev Rep", unqualifiedEventProperties.getSalesDevRep());
        klaviyoData.put("Unqualified Reason", unqualifiedEventProperties.getUnqualifiedReason());
        klaviyoData.put("Sales Dev Rep", unqualifiedEventProperties.getSalesDevRep());
        String email = unqualifiedEventProperties.getEmail();
        JSONObject actionRequestBody = generateActionRequestBody(getKlaviyoProfileId(email), email, "Unqualified", klaviyoData);
        executeAction(actionRequestBody);
      }
    } catch (Exception e) {
      String errorMessage = "Error executing Unqualified event for projectId: " + projectId + ", errorMsg:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
    }
  }

  public void postAppointmentSetEvent(Long projectId) {
    try {
      JSONObject klaviyoData = new JSONObject();
      KlaviyoContactProperties appointmentSetEventProperties = sqlCache.getBySql(KlaviyoQuery.getAppointmentSetEventProperties, Map.of("projectId", projectId), KlaviyoContactProperties.class)
        .orElse(null);

      if (appointmentSetEventProperties != null) {
        klaviyoData.put("Project ID", projectId);
        klaviyoData.put("First Appointment Date", appointmentSetEventProperties.getFirstAppointmentPitched());
        klaviyoData.put("Primary Appointment Date", appointmentSetEventProperties.getPrimaryAppointmentDate());
        klaviyoData.put("Sales Dev Representative", appointmentSetEventProperties.getSalesDevRep());
        klaviyoData.put("Closer", appointmentSetEventProperties.getCloser());
        String email = appointmentSetEventProperties.getEmail();
        JSONObject actionRequestBody = generateActionRequestBody(getKlaviyoProfileId(email), email, "Appointment Set", klaviyoData);
        executeAction(actionRequestBody);
      }
    } catch (Exception e) {
      String errorMessage = "Error executing Appointment Set event for projectId: " + projectId + ", errorMsg:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
    }
  }

  public void postPitchedEvent(Long projectId) {
    try {
      JSONObject klaviyoData = new JSONObject();
      KlaviyoContactProperties pitchedEventProperties = sqlCache.getBySql(KlaviyoQuery.getPitchedEventProperties, Map.of("projectId", projectId), KlaviyoContactProperties.class)
        .orElse(null);

      if (pitchedEventProperties != null) {
        klaviyoData.put("Sales Dev Representative", pitchedEventProperties.getSalesDevRep());
        klaviyoData.put("Closer", pitchedEventProperties.getCloser());
        klaviyoData.put("Project ID", projectId);
        String email = pitchedEventProperties.getEmail();
        JSONObject actionRequestBody = generateActionRequestBody(getKlaviyoProfileId(email), email, "Pitched", klaviyoData);
        executeAction(actionRequestBody);
      }
    } catch (Exception e) {
      String errorMessage = "Error executing Pitched event for projectId: " + projectId + ", errorMsg:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
    }
  }

  public void postBookedEvent(Long projectId) {
    try {
      JSONObject klaviyoData = new JSONObject();
      KlaviyoContactProperties bookedEventProperties = sqlCache.getBySql(KlaviyoQuery.getBookedEventProperties, Map.of("projectId", projectId), KlaviyoContactProperties.class)
        .orElse(null);

      if (bookedEventProperties != null) {
        klaviyoData.put("System Size", bookedEventProperties.getSystemSize());
        klaviyoData.put("Pitched Appointment Date", bookedEventProperties.getPitchedAppointmentDate());
        klaviyoData.put("Closer Appointment Outcome Name", bookedEventProperties.getCloserAppointmentOutcomeName());
        klaviyoData.put("Sales Dev Representative", bookedEventProperties.getSalesDevRep());
        klaviyoData.put("Closer", bookedEventProperties.getCloser());
        klaviyoData.put("Project ID", projectId);
        String email = bookedEventProperties.getEmail();
        JSONObject actionRequestBody = generateActionRequestBody(getKlaviyoProfileId(email), email, "Booked", klaviyoData);
        executeAction(actionRequestBody);
      }
      else {
        throw new RuntimeException("Unable to find project from given projectId");
      }
    } catch (Exception e) {
      String errorMessage = "Error executing Booked event for projectId: " + projectId + ", errorMsg:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
    }
  }

  public void postFinalDesignCompletedEvent(Long projectId) {
    try {
      JSONObject klaviyoData = new JSONObject();
      KlaviyoContactProperties finalDesignCompletedEventProperties = sqlCache.getBySql(KlaviyoQuery.getFinalDesignCompletedEventProperties, Map.of("projectId", projectId), KlaviyoContactProperties.class)
        .orElse(null);

      if (finalDesignCompletedEventProperties != null) {
        klaviyoData.put("System Size", finalDesignCompletedEventProperties.getSystemSize());
        klaviyoData.put("Sales Dev Representative", finalDesignCompletedEventProperties.getSalesDevRep());
        klaviyoData.put("Closer", finalDesignCompletedEventProperties.getCloser());
        klaviyoData.put("Project ID", projectId);
        String email = finalDesignCompletedEventProperties.getEmail();
        JSONObject actionRequestBody = generateActionRequestBody(getKlaviyoProfileId(email), email, "Final Design Completed", klaviyoData);
        executeAction(actionRequestBody);
      }
    } catch (Exception e) {
      String errorMessage = "Error executing Final Design Completed event for projectId: " + projectId + ", errorMsg:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
    }
  }

  public void postSubstantialCompletionEvent(Long projectId) {
    try {
      JSONObject klaviyoData = new JSONObject();
      KlaviyoContactProperties substantialCompletionEventProperties = sqlCache.getBySql(KlaviyoQuery.getSubstantialCompletionEventProperties,
          Map.of("projectId", projectId), KlaviyoContactProperties.class)
        .orElse(null);

      if (substantialCompletionEventProperties != null) {
        klaviyoData.put("System Size", substantialCompletionEventProperties.getSystemSize());
        klaviyoData.put("Sales Dev Representative", substantialCompletionEventProperties.getSalesDevRep());
        klaviyoData.put("Closer", substantialCompletionEventProperties.getCloser());
        klaviyoData.put("Project ID", projectId);
        String email = substantialCompletionEventProperties.getEmail();
        JSONObject actionRequestBody = generateActionRequestBody(getKlaviyoProfileId(email), email, "Substantial Completion", klaviyoData);
        executeAction(actionRequestBody);
      }
    } catch (Exception e) {
      String errorMessage = "Error executing Substantial Completion event for projectId: " + projectId + ", errorMsg:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
    }
  }

  public CustomContact getContact(Long contactId, Boolean isParent) {
    //this function was created to return a smaller contact object and to remove an otherwise unavoidable circular reference
    Map<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);

    params.put("companyId", 3L);
    params.put("parentCompanyId", 3L);
    params.put("isParent", isParent);

    //todo make this query return all the props needed
    Optional<CustomContact> contact = sqlCache.getBySql(GenesysQuery.getContact, params, CustomContact.class);

    return contact.orElse(null);
  }

  private HttpResponse request(String method, String url, InputStream content) throws Exception {
    //log.debug("KLAVIYO: sending to Klaviyo url: {}", url);
    Map<String, String> headers = new HashMap<>();
    headers.put("revision", "2024-07-15");
    headers.put("Authorization", "Klaviyo-API-Key %s".formatted(basicToken));
    headers.put("Content-Type", "application/json");
    return HttpUtils.call(method, url, headers, content);
  }

  private HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }

  private HttpResponse GET(String url) throws Exception {
    return request("GET", url, null);
  }

  private HttpResponse PATCH(String url, String content) throws Exception {
    RestClient client  = RestClient.builder()
      .requestFactory(new JdkClientHttpRequestFactory(HttpClient.newBuilder()
        .followRedirects(HttpClient.Redirect.NORMAL)
        .build()))
      .baseUrl(url)
      .build();

    Map<String, String> headers = new HashMap<>();
    headers.put("revision", "2024-07-15");
    headers.put("Authorization", "Klaviyo-API-Key %s".formatted(basicToken));
    headers.put("Content-Type", "application/json");

    ResponseEntity<String> response = client
      .patch()
      .uri("/")  // Assuming the full URL is provided in the baseUrl
      .accept(MediaType.APPLICATION_JSON)
      .headers(httpHeaders -> headers.forEach(httpHeaders::add))
      .body(content)
      .retrieve()
      .toEntity(String.class);

    InputStream bodyStream = IOUtils.toInputStream(response.getBody(), StandardCharsets.UTF_8);
    HttpResponse httpResponse = new HttpResponse(response.getStatusCodeValue(), bodyStream, null);
    return httpResponse;
  }

  @Data
  private static class KlaviyoContactProperties {
    private Long projectId, leadLevel, creditScore;
    private boolean isRetargeted;
    private String closerAppointmentOutcomeName, companyProjectStatusType, utilityCompanyName, firstAppointmentPitched,
      latestActivityNoteDate, gclid, fbclid, twclid, msclid, utmSource, utmMedium, utmContent, utmCampaign,
      email, completeDateBooking, primaryAppointmentDate, finalDesignSignedDate, closer, salesDevRep, systemSize,
      appointmentOutcome, unqualifiedReason, pitchedAppointmentDate, vendorId, tier, roofMaterial, sunExposure,
      homeowner, leadStatus, roofDesign, leadSourceDetailName, leadSource, aidaformRecipient, companyBrand;
    private BigDecimal leadPrice, electricMonthly, householdIncome;
    private Date leadCreatedDate, projectCreatedDate, finalDesignCompleteDate, substantialCompletionDate;
  }
}
