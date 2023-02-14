package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CallGroupPhoneNumber;
import com.albatross.api.v1.company.blueraven.services.queries.CallGroupQuery;
import com.albatross.api.v1.company.blueraven.services.queries.ContactLeadQuery;
import com.albatross.api.v1.company.blueraven.services.queries.GenesysQuery;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.queries.customFieldValues.ContactCfvQuery;
import com.albatross.api.v1.flow.services.ContactService;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.SMSService;
import com.albatross.api.v1.flow.services.VerseWebhookService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.i18n.phonenumbers.NumberParseException;
import com.mypurecloud.sdk.v2.*;
import com.mypurecloud.sdk.v2.api.OutboundApi;
import com.mypurecloud.sdk.v2.api.request.GetOutboundContactlistsRequest;
import com.mypurecloud.sdk.v2.extensions.AuthResponse;
import com.mypurecloud.sdk.v2.model.ContactList;
import com.mypurecloud.sdk.v2.model.ContactListEntityListing;
import com.mypurecloud.sdk.v2.model.DialerContact;
import com.mypurecloud.sdk.v2.model.WritableDialerContact;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class GenesysService {

  private final ContactService contactService;
  private final CustomFieldValueService customFieldValueService;
  private final SecurityService securityService;
  private final SqueezeService squeezeService;
  private final SMSService smsService;
  private final VerseWebhookService verseWebhookService;
  private final SqlCache sqlCache;
  private final ObjectMapper om;

  @Value(value = "${genesys.api.client.id}")
  private String clientId;

  @Value(value = "${genesys.api.client.secret}")
  private String clientSecret;

  @Value("${app.home_url}")
  private String homeUrl;

  private ApiClient initGenesysApi() throws IOException, ApiException {
    PureCloudRegionHosts region = PureCloudRegionHosts.us_west_2;
    ApiClient apiClient = ApiClient.Builder.standard().withBasePath(region).build();
    ApiResponse<AuthResponse> authResponse =
        apiClient.authorizeClientCredentials(clientId, clientSecret);
    // Use the ApiClient instance
    return apiClient;
  }

  public Contact getContactByPhone(String phoneNumber) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    String cleanPhoneNumber = phoneNumber.replaceAll("[^0-9]", "");
    if (phoneNumber.startsWith("1")) {
      cleanPhoneNumber = phoneNumber.substring(1);
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("phone", cleanPhoneNumber);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("companyId", user.getCompanyId());
    return sqlCache
        .getBySql(
            GenesysQuery.getContactIdByPhone,
            params,
            new ContactService.ContactMapper<>(Contact.class, om))
        .orElse(null);
  }

  public JSONObject getContactUrlByPhone(String phoneNumber) {
    JSONObject contactJson = new JSONObject();
    Contact contact = getContactByPhone(phoneNumber);
    if (contact != null) {
      contactJson.put("contactUrl", homeUrl + "/contact/" + contact.getId());
      return contactJson;
    } else {
      return null;
    }
  }

  public JSONObject getContactDetailsByPhone(String phoneNumber) {
    JSONObject contactJson = new JSONObject();
    Contact contact = getContactByPhone(phoneNumber);
    if (contact != null) {
      User user = securityService.getCurrentUser();
      Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
      HashMap<String, Object> params = new HashMap<>();
      params.put("contactId", contact.getId());
      Optional<String> agentId =
          sqlCache.getBySql(
              GenesysQuery.getAgentIdByContactId, params, new SingleColumnRowMapper<>(String.class));
      contactJson.put("existingCustomer", true);
      contactJson.put("contactUrl", homeUrl + "/contact/" + contact.getId());
      if (agentId.isPresent()) {
        contactJson.put("agentId", agentId.get());
      } else {
        contactJson.put("agentId", "");
      }

      params.put("parentCompanyId", user.getHighestParentCompanyId());
      params.put("isParent", isParent);
      params.put("companyId", user.getCompanyId());
      List<String> appointments =
          sqlCache.queryBySql(
              GenesysQuery.getContactAppointments, params, new SingleColumnRowMapper<>(String.class));
      try {
        JSONArray appointmentsJson = new JSONArray(appointments.get(0));
        JSONObject appointmentJson = appointmentsJson.getJSONObject(0);
        if (!appointmentJson.isNull("first_appointment_pitched")) {
          contactJson.put("appointmentPitched", true);
        } else {
          contactJson.put("appointmentPitched", false);
        }

        if (!appointmentJson.isNull("first_appointment")) {
          contactJson.put("appointment", true);
        } else {
          contactJson.put("appointment", false);
        }

        if (appointmentJson.has("future_appointment")
            && !appointmentJson.isNull("future_appointment")) {
          contactJson.put("futureAppointment", appointmentJson.getBoolean("future_appointment"));
        } else {
          contactJson.put("futureAppointment", false);
        }
      } catch (Exception e) {
        contactJson.put("appointmentPitched", false);
        contactJson.put("appointment", false);
        contactJson.put("futureAppointment", false);
      }

    } else {
      contactJson.put("existingCustomer", false);
      contactJson.put("appointmentPitched", false);
      contactJson.put("futureAppointment", false);
      contactJson.put("appointment", false);
      contactJson.put("agentId", "");
    }
    return contactJson;
  }

  public Boolean updateAgentId(String phoneNumber, String agentId) {
    Contact contact = getContactByPhone(phoneNumber);
    if (contact != null) {
      updateGenesysCfv(contact.getId(), agentId, 19331L);
      return true;
    }

    return false;
  }

  public Boolean updateLeadStatus(String phoneNumber, String leadStatus) {
    Contact contact = getContactByPhone(phoneNumber);
    String leadStatusId = checkIfCustomFieldDropdownValueExists(696, leadStatus);
    if (contact != null && !leadStatusId.equalsIgnoreCase("null")) {
      User currentUser = securityService.getCurrentUser();
      HashMap<String, Object> params = new HashMap<>();
      params.put("dateValue", null);
      params.put("timestampValue", null);
      params.put("booleanValue", null);
      params.put("textValue", null);
      params.put("numericValue", null);
      params.put("richTextValue", null);
      params.put("intValue", Long.parseLong(leadStatusId));
      params.put("intArrayValue", null);
      params.put("customFieldGroupAssignmentId", 399L);
      params.put("sourceId", contact.getId());
      params.put("userId", currentUser.trueUserId());
      sqlCache.updateBySql(ContactCfvQuery.upsertCustomFieldValue, params);
      return true;
    }

    return false;
  }

  public Boolean updateLeadStatus(Long contactId, String leadStatus) {
    String leadStatusId = checkIfCustomFieldDropdownValueExists(696, leadStatus);
    if (contactId != null && !leadStatusId.equalsIgnoreCase("null")) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("dateValue", null);
      params.put("timestampValue", null);
      params.put("booleanValue", null);
      params.put("textValue", null);
      params.put("numericValue", null);
      params.put("richTextValue", null);
      params.put("intValue", Long.parseLong(leadStatusId));
      params.put("intArrayValue", null);
      params.put("customFieldGroupAssignmentId", 399L);
      params.put("sourceId", contactId);
      params.put("userId", SystemSettings.BR_SYSTEM_USER.getId());
      sqlCache.updateBySql(ContactCfvQuery.upsertCustomFieldValue, params);
      return true;
    }

    return false;
  }

  public void addContact(Long contactId, List<CustomFieldValue> values, boolean isHubspot)
      throws IOException, ApiException {
    // Only add contacts if we are in Prod
    if (StringUtils.isEmpty(clientId) || StringUtils.isEmpty(clientSecret == null)) {
      return;
    }

    Contact contact;
    if (isHubspot) {
      contact = contactService.getHubspotContact(contactId);
    } else {
      User user = new User();
      user.setId(SystemSettings.CRON_USER.getId());
      user.setCompanyId(3L);
      user.setHighestCompanyId(3L);
      user.setParentCompanyId(3L);
      user.setHighestParentCompanyId(3L);
      contact = contactService.getContact(contactId, user);
    }

    WritableDialerContact wdc = new WritableDialerContact();
    SimpleDateFormat formatterDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat formatterTime = new SimpleDateFormat("HH:mm:ss");
    HashMap<String, Object> contactMap = new HashMap<>();
    wdc.setId(contact.getId().toString());
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put(
        "phone", contact.getPhone() != null ? contact.getPhone().replaceAll("[^0-9]", "") : "");
    contactMap.put(
        "mobile", contact.getMobile() != null ? contact.getMobile().replaceAll("[^0-9]", "") : "");
    contactMap.put(
        "contact_type_id", contact.getContactTypeId() != null ? contact.getContactTypeId() : "");
    contactMap.put("Total Call Attempts", 0);
    contactMap.put("Contacted Call Attempts", 0);
    contactMap.put("contactcallable", 1);
    contactMap.put("zipcodeautomatictimezone", "");
    contactMap.put("Call Scheduled", "");
    contactMap.put("callerId", getCallerGroupNumber(contact));
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatterDate.format(contact.getDateCreated()) + "T" + formatterTime.format(contact.getDateCreated()));

    addTextelParameters(contactMap, false);

    getCfvValues(contactMap, values);
    String genesysContactListName = (String) contactMap.remove("genesys_contact_list_name");
    // Genesys contact list names that require additional parameters
    Set<String> genesysAppointmentContactLists = new HashSet<>(Arrays.asList("Sales Dev Retargeted Leads", "Inside Sales Pitched Not Booked"));
    if (!genesysContactListName.isEmpty()) {
      if (genesysAppointmentContactLists.contains(genesysContactListName)) {
        getAppointmentValues(contactId, contactMap);
      }

      if (genesysContactListName.equals("Inside Sales Pitched Not Booked")) {
        getPitchedNotBookedValues(contactId, contactMap);
      }

      if (genesysContactListName.equals("Sales Dev Retargeted Leads")) {
        getRetargetedValues(contactMap);
      }
    }

    String leadLevel = (String) contactMap.remove("lead_level");

    // Genesys contacts will have a lead level
    if (leadLevel == null || leadLevel.isEmpty() || leadLevel.equals("0")) {
      return;
    } else if (leadLevel.equals("20")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, false);
      return;
    } else if (leadLevel.equals("21")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, true);
      return;
    } else if (leadLevel.equals("30")) {
      contactMap.put("state", contact.getState());
      squeezeService.postContact(contactMap);
      return;
    }

    contactMap.put("QueueName", getQueueName(leadLevel));

    wdc.setData(contactMap);

    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();

    String contactListId = "";
    // Add contact for crons
    if (genesysContactListName != null && !genesysContactListName.isEmpty()) {
      contactListId = getContactListId(apiInstance, genesysContactListName);

      // Contact list is found in Genesys
      if (contactListId != null && !contactListId.isBlank()) {
        List<DialerContact> dc =
          apiInstance.postOutboundContactlistContacts(
            contactListId, List.of(wdc), true, false, false);
        // Store the Genesys Contact ID
        updateGenesysCfv(contact.getId(), dc.get(0).getId(), 19357L);
      }
    }
    else {
      // Add contact to LeadLevel_NBS
      contactListId = getContactListId(apiInstance, "LeadLevel_NBS");
      // If no Contact  List is found
      if (contactListId == null || contactListId.isBlank()) {
        return;
      }

      contactMap.remove("Appointment Date");
      contactMap.remove("Appointment Outcome");
      contactMap.remove("PNB");
      contactMap.put("Custom_LastAttemptTime", "");

      if (!contactMap.containsKey("referral")) {
        contactMap.put("referral", false);
      }

      if (!contactMap.containsKey("retargeted")) {
        contactMap.put("retargeted", false);
      }

      contactMap.put("TotalCallAttempts", contactMap.remove("Total Call Attempts"));
      contactMap.put("ContactedCallAttempts", contactMap.remove("Contacted Call Attempts"));
      contactMap.put("CallScheduled", contactMap.remove("Call Scheduled"));
      contactMap.put("ContactCallable", contactMap.remove("contactcallable"));
      contactMap.put("ZipCodeAutomaticTimeZone", contactMap.remove("zipcodeautomatictimezone"));

      wdc.setData(contactMap);

      apiInstance.postOutboundContactlistContacts(
      contactListId, List.of(wdc), true, false, false);
    }
  }

  private void updateGenesysCfv(Long contactId, String textValue, Long cfgaId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("dateValue", null);
    params.put("timestampValue", null);
    params.put("booleanValue", null);
    params.put("textValue", textValue);
    params.put("numericValue", null);
    params.put("intValue", null);
    params.put("richTextValue", null);
    params.put("intArrayValue", null);
    params.put("customFieldGroupAssignmentId", cfgaId);
    params.put("sourceId", contactId);

    try {
      params.put("userId", currentUser.trueUserId());
    } catch (Exception e) {
      params.put("userId", SystemSettings.CRON_USER.getId());
    }

    try {
      sqlCache.updateBySql(ContactCfvQuery.upsertCustomFieldValue, params);

    } catch (Exception e) {

      log.error(
          "GENESYS: Error in updateGenesysCfv contactId={}, textValue={}, cfgaId={}, msg={}",
          contactId,
          textValue,
          cfgaId,
          e.getMessage());
    }
  }

  private String checkIfCustomFieldDropdownValueExists(
      Integer listOfValueId, String customFieldDropdownValue) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("listOfValueId", listOfValueId);
    params.put("customFieldDropdownValue", customFieldDropdownValue);

    Optional<String> customFieldDropdownValueId =
        sqlCache.queryForObjectOptionalBySql(
           ContactLeadQuery.checkIfCustomFieldDropdownValueExists, params, String.class);
    return customFieldDropdownValueId.orElse("null");
  }

  private void getAppointmentValues(Long contactId, HashMap<String, Object> contactMap) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    Optional<String> appointmentDate =
      sqlCache.getBySql(
        GenesysQuery.getContactAppointmentDate,
        params,
        new SingleColumnRowMapper<>(String.class));

    if (appointmentDate.isPresent()) {
      contactMap.put("Appointment Date", appointmentDate.get());
    }
    else {
      contactMap.put("Appointment Date", "");
    }

    Optional<String> appointmentOutcome =
      sqlCache.getBySql(
        GenesysQuery.getContactCloserAppointmentOutcome,
        params,
        new SingleColumnRowMapper<>(String.class));

    if (appointmentOutcome.isPresent()) {
      contactMap.put("Appointment Outcome", appointmentOutcome.get());
    }
    else {
      contactMap.put("Appointment Outcome", "");
    }
  }

  private void getPitchedNotBookedValues(Long contactId, HashMap<String, Object> contactMap) {
    SimpleDateFormat formatterDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat formatterTime = new SimpleDateFormat("HH:mm:ss");
    Date date = new Date();
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    Optional<Boolean> pitchedNotBooked =
      sqlCache.getBySql(
        GenesysQuery.getContactPitchedNotBooked,
        params,
        new SingleColumnRowMapper<>(Boolean.class));

    if (pitchedNotBooked.isPresent()) {
      contactMap.put("PNB", pitchedNotBooked.get());
    }
    else {
      contactMap.put("PNB", false);
    }

    // Hard code certain params for this contact list
    contactMap.remove("contact_type_id");
    contactMap.put("contact_type_id", 2);

    contactMap.remove("date_created");
    contactMap.put("date_created", formatterDate.format(date) + "T" + formatterTime.format(date));

    contactMap.remove("lead_status");
    contactMap.put("lead_status", "Pitched Not Booked");

    contactMap.remove("referral");
    contactMap.remove("retargeted");
  }

  private void getRetargetedValues(HashMap<String, Object> contactMap) {
    SimpleDateFormat formatterDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat formatterTime = new SimpleDateFormat("HH:mm:ss");
    Date date = new Date();

    // Hard code certain params for this contact list
    contactMap.remove("contact_type_id");
    contactMap.put("contact_type_id", 2);

    contactMap.remove("date_created");
    contactMap.put("date_created", formatterDate.format(date) + "T" + formatterTime.format(date));

    contactMap.remove("lead_status");
    contactMap.put("lead_status", "Re-Target");
  }

  public void updateContact(Long contactId) throws IOException, ApiException {
    // Only update contacts if we are in Prod
    if (StringUtils.isEmpty(clientId) || StringUtils.isEmpty(clientSecret == null)) {
      return;
    }

    Contact contact = contactService.getContact(contactId);
    SimpleDateFormat formatterDate = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat formatterTime = new SimpleDateFormat("HH:mm:ss");
    DialerContact dc = new DialerContact();
    HashMap<String, Object> contactMap = new HashMap<>();
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put(
        "phone", contact.getPhone() != null ? contact.getPhone().replaceAll("[^0-9]", "") : "");
    contactMap.put(
        "mobile", contact.getMobile() != null ? contact.getMobile().replaceAll("[^0-9]", "") : "");
    contactMap.put(
        "contact_type_id", contact.getContactTypeId() != null ? contact.getContactTypeId() : "");
    contactMap.put("contactcallable", 1);
    contactMap.put("zipcodeautomatictimezone", "");
    contactMap.put("Call Scheduled", "");
    contactMap.put("callerId", getCallerGroupNumber(contact));
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatterDate.format(contact.getDateCreated()) + "T" + formatterTime.format(contact.getDateCreated()));

    addTextelParameters(contactMap, true);

    List<CustomFieldGroup> customFieldGroups =
        customFieldValueService.getCustomFieldGroupsAndValues(
            ObjectType.CONTACT, contactId);
    List<CustomFieldValue> values = customFieldGroups.get(0).getCustomFieldValues();
    // Add Lead Level custom field so that value gets pulled
    values.add(
        customFieldGroups.get(1).getCustomFieldValues().stream()
            .filter(cfg -> cfg.getCustomFieldId().equals(10982L))
            .findFirst()
            .orElse(null));
    getCfvValues(contactMap, customFieldGroups.get(0).getCustomFieldValues());
    contactMap.remove("genesys_contact_list_name");

    String leadLevel = (String) contactMap.remove("lead_level");

    // Genesys contacts will have a lead level
    if (leadLevel == null || leadLevel.isEmpty() || leadLevel.equals("0")) {
      return;
    }

    contactMap.put("QueueName", getQueueName(leadLevel));

    if (leadLevel.equals("20")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, false);
      return;
    } else if (leadLevel.equals("21")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, true);
      return;
    } else if (leadLevel.equals("30")) {
      contactMap.put("state", contact.getState());
      squeezeService.postContact(contactMap);
      return;
    }

    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();

    List<String> contactListIds = getContactListIds(leadLevel, apiInstance);

    // If no Contact List is found in Genesys
    if (contactListIds.isEmpty()) {
      return;
    }

    for (String contactListId : contactListIds) {
      // Skip empty Contact list Id's, shouldn't happen but if they do
      if (contactListId == null || contactListId.isEmpty()) {
        continue;
      }

      // Get call attempts from existing contact in Genesys
      try {
        DialerContact currentContact = apiInstance.getOutboundContactlistContact(contactListId, contact.getId().toString());
        Map<String, Object> genesysContactData = currentContact.getData();
        contactMap.put("Total Call Attempts", genesysContactData.get("Total Call Attempts") == null ? 0 : genesysContactData.get("Total Call Attempts"));
        contactMap.put("Contacted Call Attempts", genesysContactData.get("Contacted Call Attempts") == null ? 0 : genesysContactData.get("Contacted Call Attempts"));
      } catch (Exception e) {
        contactMap.put("Total Call Attempts", 0);
        contactMap.put("Contacted Call Attempts", 0);
      }

      HashMap<String, Object> contactMapNbs = (HashMap<String, Object>) contactMap.clone();
      contactMapNbs.put("Custom_LastAttemptTime", "");

      if (!contactMapNbs.containsKey("referral")) {
        contactMapNbs.put("referral", false);
      }

      if (!contactMapNbs.containsKey("retargeted")) {
        contactMapNbs.put("retargeted", false);
      }

      contactMapNbs.put("TotalCallAttempts", contactMapNbs.remove("Total Call Attempts"));
      contactMapNbs.put("ContactedCallAttempts", contactMapNbs.remove("Contacted Call Attempts"));
      contactMapNbs.put("CallScheduled", contactMapNbs.remove("Call Scheduled"));
      contactMapNbs.put("ContactCallable", contactMapNbs.remove("contactcallable"));
      contactMapNbs.put("ZipCodeAutomaticTimeZone", contactMapNbs.remove("zipcodeautomatictimezone"));

      dc.setData(contactMapNbs);

      // Try with the Contact ID first (for imported contacts)
      // if that doesn't work use the Genesys Agent ID (newly created Contacts)
      try {
        apiInstance.putOutboundContactlistContact(contactListId, contact.getId().toString(), dc);
      } catch (ApiException e) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("contactId", contact.getId());
        Optional<String> genesysContactId =
          sqlCache.getBySql(
            GenesysQuery.getGenesysContactIdByContactId,
            params,
            new SingleColumnRowMapper<>(String.class));
        if (genesysContactId.isPresent()) {
          try {
            apiInstance.putOutboundContactlistContact(contactListId, genesysContactId.get(), dc);
          } catch (ApiException ae) {
            JSONObject apiException = new JSONObject(ae.getRawBody());
//            log.error(
//                "GENE: Error updating contactId={}, msg={}",
//                contactId,
//                apiException.getString("message"));
          }
        }
      }
    }

    // Attempt to update contact in Sales Dev Retargeted Leads
    String contactListId = getContactListId(apiInstance, "Sales Dev Retargeted Leads");

    HashMap<String, Object> contactMapRetargetedLeads = (HashMap<String, Object>) contactMap.clone();
    getAppointmentValues(contactId, contactMapRetargetedLeads);
    getRetargetedValues(contactMapRetargetedLeads);
    dc.setData(contactMapRetargetedLeads);

    try {
      apiInstance.putOutboundContactlistContact(contactListId, contact.getId().toString(), dc);
    } catch (ApiException e) {
      JSONObject apiException = new JSONObject(e.getRawBody());
    }

    // Attempt to update contact in Inside Sales Pitched Not Booked
    contactListId = getContactListId(apiInstance, "Inside Sales Pitched Not Booked");
    HashMap<String, Object> contactMapPNB = (HashMap<String, Object>) contactMap.clone();
    getAppointmentValues(contactId, contactMapPNB);
    getPitchedNotBookedValues(contactId, contactMapPNB);
    dc.setData(contactMapPNB);
    try {
      apiInstance.putOutboundContactlistContact(contactListId, contact.getId().toString(), dc);
    } catch (ApiException e) {
      JSONObject apiException = new JSONObject(e.getRawBody());
    }
  }

  private void getCfvValues(HashMap<String, Object> contactMap, List<CustomFieldValue> values) {
    contactMap.put("lead_source", "");
    contactMap.put("lead_source_detail", "");
    contactMap.put("lead_status", "");
    contactMap.put("lead_level", "");
    contactMap.put("referral", false);
    contactMap.put("retargeted", false);
    contactMap.put("genesys_contact_list_name", "");

    for (CustomFieldValue cfv : values) {
      String value = "";
      if (cfv.getIntValue() != null) {
        // If Contact is from ContactLeadService, value for Lead Source & Lead Source Detail will be
        // in fieldValue
        if (cfv.getListOfValues() == null) {
          value = cfv.getFieldValue();
        } else {
          for (ListOfValue lov : cfv.getListOfValues()) {
            if (lov.getId().equals(cfv.getIntValue())) {
              value = lov.getName();
              break;
            }
          }
        }
      }

      if (cfv.getFieldName() != null) {
        if (cfv.getFieldName().equals("Lead Source")) {
          contactMap.put("lead_source", value);
        } else if (cfv.getFieldName().equals("Lead Source Detail")) {
          contactMap.put("lead_source_detail", value);
        } else if (cfv.getFieldName().equals("Lead Status")) {
          contactMap.put("lead_status", value);
        } else if (cfv.getFieldName().equals("Lead Level")) {
          contactMap.put(
            "lead_level", cfv.getIntValue() == null ? "" : cfv.getIntValue().toString());
        } else if (cfv.getFieldName().equals("Referral")) {
          contactMap.put("referral", cfv.getBooleanValue() == null ? false : cfv.getBooleanValue());
        } else if (cfv.getFieldName().equals("Genesys Contact List Name")) {
          contactMap.put("genesys_contact_list_name", cfv.getFieldValue());
        }
      }
    }
  }

  private String getCallerGroupNumber(Contact contact) {
    HashMap<String, Object> params = new HashMap<>();
    User user = securityService.getCurrentUser();
    params.put("postalCode", contact.getPostalCode());

    List<CallGroupPhoneNumber> callGroupPhoneNumbers =
        sqlCache.queryBySql(CallGroupQuery.getCallerGroupNumbers, params, CallGroupPhoneNumber.class);

    // Update the Contacts Assigned/Call Count for this Call Group for each phone number
    for (CallGroupPhoneNumber cgpn : callGroupPhoneNumbers) {
      HashMap<String, Object> currParams = new HashMap<>();
      currParams.put("callGroupId", cgpn.getCallGroupId());
      currParams.put("phoneNumber", cgpn.getPhoneNumber());
      sqlCache.updateBySql(CallGroupQuery.updatePhoneCallCount, currParams);
    }

    // Get the Call groups again after the Call Counts have been updated
    callGroupPhoneNumbers =
        sqlCache.queryBySql(CallGroupQuery.getCallerGroupNumbers, params, CallGroupPhoneNumber.class);

    Long currentlyUsedGroupPhoneId = null;
    Long currentlyUsedGroupId = null;
    String phoneNumber = "";

    // Return default number if no numbers are found for this postal code
    if (callGroupPhoneNumbers.isEmpty()) {
      return "+13852921523";
    }

    // Select the number with the lowest call count
    currentlyUsedGroupPhoneId = callGroupPhoneNumbers.get(0).getId();
    currentlyUsedGroupId = callGroupPhoneNumbers.get(0).getCallGroupId();
    phoneNumber = callGroupPhoneNumbers.get(0).getPhoneNumber();

    // Increment call count of the number used
    params.put("currentlyUsedId", currentlyUsedGroupPhoneId);
    sqlCache.updateBySql(CallGroupQuery.updatePhoneNumberCallCount, params);

    // Add a row to the phone log table
    params.put("callGroupId", currentlyUsedGroupId);
    params.put("phoneNumber", phoneNumber);

    // if user is null then it is coming from the cron, use the cron user id
    params.put("createdById", null != user ? user.trueUserId() : SystemSettings.CRON_USER.getId());

    sqlCache.updateBySql(CallGroupQuery.addPhoneLog, params);

    if (!phoneNumber.isEmpty()) {
      try {
        return smsService.cleanPhoneNumber(
            "+" + (null != contact.getCountryId() ? contact.getCountryId() : "1") + phoneNumber);
      } catch (NumberParseException e) {
        return "+1385-292-1523";
      }
    } else {
      return "+13852921523";
    }
  }

  private String getContactListName(String leadLevel) {
    if (leadLevel.equals("1")) {
      return "LeadLevel1_All";
    } else if (leadLevel.equals("2")) {
      return "LeadLevel2_All";
    } else if (leadLevel.equals("3")) {
      return "LeadLevel3_All";
    } else if (leadLevel.equals("10")) {
      return "LeadLevel10_All";
    }

    return null;
  }
  private String getQueueName(String leadLevel) {
    if (leadLevel.equals("1")) {
      return "SMS Level 1";
    } else if (leadLevel.equals("2")) {
      return "SMS Level 2";
    } else if (leadLevel.equals("3")) {
      return "SMS Level 3";
    } else if (leadLevel.equals("10")) {
      return "SMS Level 10";
    }

    return "";
  }

  // Get the Genesys id of the Contact List from Genesys
  private String getContactListId(
    OutboundApi apiInstance,
    String genesysContactListName)
    throws IOException, ApiException {
    GetOutboundContactlistsRequest goclr = new GetOutboundContactlistsRequest();
    goclr.setPageSize(100);
    ContactListEntityListing contactListEntity = apiInstance.getOutboundContactlists(goclr);

    String contactListId = "";
    for (ContactList cl : contactListEntity.getEntities()) {
      if (cl.getName().equals(genesysContactListName)) {
        contactListId = cl.getId();
        break;
      }
    }
    // If no Contact List match was found
    if (contactListId.isEmpty()) {
      return null;
    }

    return contactListId;
  }

  // Get the Genesys id of the Contact List from Genesys
  private List<String> getContactListIds(String leadLevel, OutboundApi apiInstance)
      throws IOException, ApiException {
    HashSet<String> contactListNames = new HashSet<>();
    List<String> contactListIds = new ArrayList<>();
    GetOutboundContactlistsRequest goclr = new GetOutboundContactlistsRequest();
    goclr.setPageSize(100);
    ContactListEntityListing contactListEntity = apiInstance.getOutboundContactlists(goclr);
    contactListNames.add(getContactListName(leadLevel));

    for (ContactList cl : contactListEntity.getEntities()) {
      if (contactListNames.contains(cl.getName())) {
        contactListIds.add(cl.getId());
      }
    }

    return contactListIds;
  }

  public void processGenesysContacts() {
    // Get list of Contact IDs that need to be put into each Genesys Contact List
    List<Contact> contacts = sqlCache.queryBySql(GenesysQuery.getContactIdsSalDevRetargets, null, Contact.class);
    addContactsToGenesys(contacts, "Sales Dev Retargeted Leads");

    contacts = sqlCache.queryBySql(GenesysQuery.getContactIdsInsideSalesPitchedNotBooked, null, Contact.class);
    addContactsToGenesys(contacts, "Inside Sales Pitched Not Booked");
  }

  private void addContactsToGenesys(List<Contact> contacts, String contactListName) {
    for (Contact contact : contacts) {
      List<CustomFieldGroup> customFieldGroups =
        customFieldValueService.getCustomFieldGroupsAndValues(
          ObjectType.CONTACT, contact.getId());
      List<CustomFieldValue> values = customFieldGroups.get(0).getCustomFieldValues();

      CustomFieldValue genesysContactListName = new CustomFieldValue();
      genesysContactListName.setFieldName("Genesys Contact List Name");
      genesysContactListName.setFieldValue(contactListName);
      values.add(genesysContactListName);

      try {
        addContact(contact.getId(), values, false);
      } catch (ApiException ae) {
        JSONObject apiException = new JSONObject(ae.getRawBody());
        log.error(
          "GENESYS: API Error during Cron - adding contactId={}, msg={}",
          contact.getId(),
          apiException.getString("message"));
      } catch (Exception e) {
        log.error("GENESYS: Error during cron - adding contactId={}, msg={}", contact.getId(), e.getMessage());
      }
    }
  }

  public void updateContactIds(List<Map<String, String>> data) {
    for (Map<String, String> contactValuesMap : data) {
      Long contactId = Long.parseLong(contactValuesMap.get("contactId"));
      String genesysContactId = contactValuesMap.get("genesysContactId");

      HashMap<String, Object> params = new HashMap<>();
      params.put("contactId", contactId);
      params.put("genesysContactId", genesysContactId);
      sqlCache.updateBySql(GenesysQuery.updateGenesysContactIdByContactId, params);
      try {
        updateContact(contactId);
      } catch (Exception e) {
        log.error("GENESYS: Error updating contactId={}, msg={}", contactId, e.getMessage());
      }
    }
  }

  public void updateContactIds(String listOfContactIds) {
    String[] contactIds = listOfContactIds.split(",");
    for (String contactId : contactIds) {
      try {
        Long contactIdToUpdate = Long.parseLong(contactId);
        updateContact(contactIdToUpdate);
      } catch (Exception e) {
        log.error("GENESYS: Error updating contactId={}, msg={}", contactId, e.getMessage());
      }
    }
  }

  private void addTextelParameters(HashMap<String, Object> contactMap, boolean isUpdate) {
    contactMap.put(
        "messageBody1",
        "Hello, "
            + "this is Blue Raven Solar. I’m just following up on your inquiry about our solar solutions. I wanted to touch base and answer any questions you may have. Is now a good time to hop on a quick phone call or would you prefer to chat via text?");
    contactMap.put("messageBody2", "Let me know which is better for you!");
    contactMap.put(
        "messageBody3",
        "Hi there, Blue Raven Solar again. We’d be happy to put together a proposal to help you see what solar would look like for you. Let me know when it’s a good time to talk!");
    contactMap.put(
        "messageBody4",
        "Hi there! Just following up on your request for a solar proposal for your home. Is it a good time to chat? You can also text me if that’s easier for you.");
    contactMap.put(
        "messageBody5",
        "Just wanted to check in. We would be more than happy to assist you. Let me know when it’s a good time to talk.");
    contactMap.put(
        "messageBody6",
        "Hey, "
            + " we don't want to bother you, but we do want to help with your request. Are you available to chat sometime in the next couple of days?");
    contactMap.put(
        "messageBody7",
        "Hi, "
            + " are you still interested in scheduling an appointment  for more information about our solar solutions? If so, please let us know!");
    contactMap.put(
        "messageBodyAfterHours",
        "Thank you for your text! We are currently out of office but will reply to your message as soon as we get back in.");
    contactMap.put(
        "messageBodyStop",
        "We have removed you from our messaging campaign. No more messages will be sent. Questions? Send them to sales@blueravensolar.com or call 385-233-0858");

    Long contactId = (Long) contactMap.get("id");
    if (isUpdate) {
      contactMap.put("line_id", "");
    } else {
      saveTextelPhoneKey(contactId, contactMap);
    }
  }

  private void saveTextelPhoneKey(Long contactId, HashMap<String, Object> contactMap) {
    ArrayList<String> textelPhoneKeys =
        new ArrayList<>(
            Arrays.asList(
                "8CEB0154-A24A-4158-B791-3CD1B6EF40CF",
                "EE67684C-8096-4990-8FA1-5C902AD45CBC",
                "0B631987-84D0-4DB2-9629-A0D6E22E95B4",
                "6C2E00EC-CEFD-4BBE-920B-528D19BA7263",
                "D62840D5-A25A-41BD-9FFE-E89BEDDE70FD"));

    Random random = new Random();
    String textelPhoneKey = textelPhoneKeys.get(random.nextInt(textelPhoneKeys.size()));
    updateGenesysCfv(contactId, textelPhoneKey, 22530L);
    contactMap.put("line_id", textelPhoneKey);
  }
}
