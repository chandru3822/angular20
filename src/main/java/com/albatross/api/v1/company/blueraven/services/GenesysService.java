package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CallGroupPhoneNumber;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
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
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;


@Service
@Slf4j
public class GenesysService {
  @Value(value = "${genesys.api.client.id}")
  private String clientId;

  @Value(value = "${genesys.api.client.secret}")
  private String clientSecret;

  @Value("${app.home_url}")
  private String homeUrl;

  @Autowired
  private ContactService contactService;

  @Autowired
  private CustomFieldValueService customFieldValueService;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private SMSService smsService;

  @Autowired
  private VerseWebhookService verseWebhookService;

  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private ObjectMapper om;

  private ApiClient initGenesysApi() throws IOException, ApiException {
    PureCloudRegionHosts region = PureCloudRegionHosts.us_west_2;
    ApiClient apiClient = ApiClient.Builder.standard().withBasePath(region).build();
    ApiResponse<AuthResponse> authResponse = apiClient.authorizeClientCredentials(clientId, clientSecret);
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
    Optional<Contact> result = sqlCache.get("genesys.getContactIdByPhone", params, new ContactService.ContactMapper<>(Contact.class, om));
    return result.orElse(null);
  }

  public JSONObject getContactUrlByPhone(String phoneNumber) {
    JSONObject contactJson = new JSONObject();
    Contact contact = getContactByPhone(phoneNumber);
    if (contact != null) {
      contactJson.put("contactUrl", homeUrl + "/contact/" + contact.getId());
      return contactJson;
    }
    else {
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
      Optional<String> agentId = sqlCache.get("genesys.getAgentIdByContactId", params, new SingleColumnRowMapper<>(String.class));
      contactJson.put("existingCustomer", true);
      contactJson.put("contactUrl", homeUrl + "/contact/" + contact.getId());
      if (agentId.isPresent()) {
        contactJson.put("agentId", agentId.get());
      }
      else {
        contactJson.put("agentId", "");
      }

      params.put("parentCompanyId", user.getHighestParentCompanyId());
      params.put("isParent", isParent);
      params.put("companyId", user.getCompanyId());
      List<String> appointments = sqlCache.query("genesys.getContactAppointments", params, new SingleColumnRowMapper<>(String.class));
      try {
        JSONArray appointmentsJson = new JSONArray(appointments.get(0));
        JSONObject appointmentJson = appointmentsJson.getJSONObject(0);
        if (!appointmentJson.isNull("first_appointment_pitched")) {
          contactJson.put("appointmentPitched", true);
        }
        else {
          contactJson.put("appointmentPitched", false);
        }

        if (!appointmentJson.isNull("first_appointment")) {
          contactJson.put("appointment", true);
        }
        else {
          contactJson.put("appointment", false);
        }

        if (appointmentJson.has("future_appointment") && !appointmentJson.isNull("future_appointment")) {
          contactJson.put("futureAppointment", appointmentJson.getBoolean("future_appointment"));
        }
        else {
          contactJson.put("futureAppointment", false);
        }
      } catch (Exception e) {
        contactJson.put("appointmentPitched", false);
        contactJson.put("appointment", false);
        contactJson.put("futureAppointment", false);
      }

    }
    else {
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
      params.put("intValue", Long.parseLong(leadStatusId));
      params.put("intArrayValue", null);
      params.put("customFieldGroupAssignmentId", 399L);
      params.put("sourceId", contact.getId());
      params.put("userId", currentUser.trueUserId());
      sqlCache.update("customFieldValues.contact.upsertCustomFieldValue", params);
      return true;
    }

    return false;
  }

  public void addContact(Long contactId, List<CustomFieldValue> values, boolean isHubspot) throws IOException, ApiException {
    // Only add contacts if we are in Prod
    if (StringUtils.isEmpty(clientId) || StringUtils.isEmpty(clientSecret == null)) {
      return;
    }

    Contact contact;
    if (isHubspot) {
      contact = contactService.getHubspotContact(contactId);
    }
    else {
      contact = contactService.getContact(contactId);
    }

    WritableDialerContact wdc = new WritableDialerContact();
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    HashMap<String, Object> contactMap = new HashMap<>();
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put("phone", contact.getPhone() != null ? contact.getPhone().replaceAll("[^0-9]", "") : "");
    contactMap.put("mobile", contact.getMobile() != null ? contact.getMobile().replaceAll("[^0-9]", "") : "");
    contactMap.put("contact_type_id", contact.getContactTypeId() != null ? contact.getContactTypeId() : "");
    contactMap.put("Total Call Attempts", "");
    contactMap.put("Contacted Call Attempts", "");
    contactMap.put("contactcallable", 1);
    contactMap.put("zipcodeautomatictimezone", "");
    contactMap.put("Call Scheduled", "");
    contactMap.put("callerId", getCallerGroupNumber(contact));
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatter.format(calendar.getTime()));

    getCfvValues(contactMap, values);
    String genesysContactListName = (String) contactMap.remove("genesys_contact_list_name");

    wdc.setData(contactMap);

    String leadLevel = (String) contactMap.remove("lead_level");
    if (leadLevel.equals("20")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, false);
      return;
    }
    else if (leadLevel.equals("21")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, true);
      return;
    }

    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();
    String contactListId = getContactListId(leadLevel, apiInstance, genesysContactListName, false);
    // If no Contact  List is found
    if (contactListId == null) {
      return;
    }

    List<DialerContact> dc = apiInstance.postOutboundContactlistContacts(contactListId, new ArrayList<>(Arrays.asList(wdc)), false, false, false);
    // Store the Genesys Contact ID
    updateGenesysCfv(contact.getId(), dc.get(0).getId(), 19357L);

    if (genesysContactListName == null || genesysContactListName.isEmpty()) {
      String oldContactListId = getContactListId(leadLevel, apiInstance, genesysContactListName, true);
      // If no Contact  List is found
      if (contactListId == null) {
        return;
      }

      List<DialerContact> dcOld = apiInstance.postOutboundContactlistContacts(oldContactListId, new ArrayList<>(Arrays.asList(wdc)), false, false, false);
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
    params.put("intArrayValue", null);
    params.put("customFieldGroupAssignmentId", cfgaId);
    params.put("sourceId", contactId);
    params.put("userId", currentUser.trueUserId());
    sqlCache.update("customFieldValues.contact.upsertCustomFieldValue", params);
  }

  private String checkIfCustomFieldDropdownValueExists(Integer listOfValueId, String customFieldDropdownValue) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("listOfValueId", listOfValueId);
    params.put("customFieldDropdownValue", customFieldDropdownValue);

    Optional<String> customFieldDropdownValueId = sqlCache.queryForObjectOptional("contactLead.checkIfCustomFieldDropdownValueExists", params, String.class);
    return customFieldDropdownValueId.orElse("null");
  }

  public void updateContact(Long contactId) throws IOException, ApiException {
    // Only update contacts if we are in Prod
    if (StringUtils.isEmpty(clientId) || StringUtils.isEmpty(clientSecret == null)) {
      return;
    }

    Contact contact = contactService.getContact(contactId);
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    DialerContact dc = new DialerContact();
    HashMap<String, Object> contactMap = new HashMap<>();
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put("phone", contact.getPhone() != null ? contact.getPhone().replaceAll("[^0-9]", "") : "");
    contactMap.put("mobile", contact.getMobile() != null ? contact.getMobile().replaceAll("[^0-9]", "") : "");
    contactMap.put("contact_type_id", contact.getContactTypeId() != null ? contact.getContactTypeId() : "");
    contactMap.put("Total Call Attempts", "");
    contactMap.put("Contacted Call Attempts", "");
    contactMap.put("contactcallable", 1);
    contactMap.put("zipcodeautomatictimezone", "");
    contactMap.put("Call Scheduled", "");
    contactMap.put("callerId", getCallerGroupNumber(contact));
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatter.format(calendar.getTime()));

    List<CustomFieldGroup> customFieldGroups = customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.CONTACT.toString(), contactId);
    List<CustomFieldValue> values = customFieldGroups.get(0).getCustomFieldValues();
    // Add Lead Level custom field so that value gets pulled
    values.add(customFieldGroups.get(1).getCustomFieldValues().stream().filter(cfg -> cfg.getCustomFieldId().equals(10982L)).findFirst().orElse(null));
    getCfvValues(contactMap, customFieldGroups.get(0).getCustomFieldValues());
    contactMap.remove("genesys_contact_list_name");

    String leadLevel = (String) contactMap.remove("lead_level");
    if (leadLevel.equals("20")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, false);
      return;
    }
    else if (leadLevel.equals("21")) {
      contactMap.put("state", contact.getState());
      verseWebhookService.postContact(contactMap, true);
      return;
    }

    dc.setData(contactMap);

    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();
    String contactListId = getContactListId(leadLevel, apiInstance, null, true);
    // If no Contact  List is found
    if (contactListId == null) {
      return;
    }

    // Try with the Contact ID first (for imported contacts)
    // if that doesn't work use the Genesys Agent ID (newly created Contacts)
    try {
      apiInstance.putOutboundContactlistContact(contactListId, contact.getId().toString(), dc);
    } catch (ApiException e) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("contactId", contact.getId());
      Optional<String> genesysContactId = sqlCache.get("genesys.getGenesysContactIdByContactId", params, new SingleColumnRowMapper<>(String.class));
      if (genesysContactId.isPresent()) {
        apiInstance.putOutboundContactlistContact(contactListId, genesysContactId.get(), dc);
      }
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

    for (CustomFieldValue cfv: values) {
      String value = "";
      if (cfv.getIntValue() != null) {
        // If Contact is from ContactLeadService, value for Lead Source & Lead Source Detail will be in fieldValue
        if (cfv.getListOfValues() == null) {
          value = cfv.getFieldValue();
        }
        else {
          for (ListOfValue lov: cfv.getListOfValues()) {
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
        }
        else if (cfv.getFieldName().equals("Lead Source Detail")) {
          contactMap.put("lead_source_detail", value);
        }
        else if (cfv.getFieldName().equals("Lead Status")) {
          contactMap.put("lead_status", value);
        }
        else if (cfv.getFieldName().equals("Lead Level")) {
          contactMap.put("lead_level", cfv.getIntValue() == null ? "" : cfv.getIntValue().toString());
        }
        else if (cfv.getFieldName().equals("Referral")) {
          contactMap.put("referral", cfv.getBooleanValue() == null ? false : cfv.getBooleanValue());
        }
        else if (cfv.getFieldName().equals("Genesys Contact List Name")) {
          contactMap.put("genesys_contact_list_name", cfv.getFieldValue());
        }
      }
    }
  }

  private String getCallerGroupNumber(Contact contact) {
    HashMap<String, Object> params = new HashMap<>();
    User user = securityService.getCurrentUser();
    params.put("postalCode", contact.getPostalCode());

    List<CallGroupPhoneNumber> callGroupPhoneNumbers = sqlCache.query("callGroup.getCallerGroupNumbers", params, CallGroupPhoneNumber.class);

    // Update the Contacts Assigned/Call Count for this Call Group for each phone number
    for (CallGroupPhoneNumber cgpn: callGroupPhoneNumbers) {
      HashMap<String, Object> currParams = new HashMap<>();
      currParams.put("callGroupId", cgpn.getCallGroupId());
      currParams.put("phoneNumber", cgpn.getPhoneNumber());
      sqlCache.update("callGroup.updatePhoneCallCount", currParams);
    }

    // Get the Call groups again after the Call Counts have been updated
    callGroupPhoneNumbers = sqlCache.query("callGroup.getCallerGroupNumbers", params, CallGroupPhoneNumber.class);

    Long previousUsedGroupPhoneId = null;
    Long currentlyUsedGroupPhoneId = null;
    Long currentlyUsedGroupId = null;
    String phoneNumber = "";

    // Return default number if no numbers are found for this postal code
    if (callGroupPhoneNumbers.isEmpty()) {
      return "+13852921523";
    }

    if (callGroupPhoneNumbers.size() > 1) {
      for (int i = 0; i < callGroupPhoneNumbers.size(); i++) {
        if (callGroupPhoneNumbers.get(i).getLastUsed()) {
          previousUsedGroupPhoneId = callGroupPhoneNumbers.get(i).getId();
          // If at the end of list of numbers, select the first number as the next number to use
          if (i == callGroupPhoneNumbers.size() - 1) {
            currentlyUsedGroupPhoneId = callGroupPhoneNumbers.get(0).getId();
            currentlyUsedGroupId = callGroupPhoneNumbers.get(0).getCallGroupId();
            phoneNumber = callGroupPhoneNumbers.get(0).getPhoneNumber();
          }
          else {
            currentlyUsedGroupPhoneId = callGroupPhoneNumbers.get(i+1).getId();
            currentlyUsedGroupId = callGroupPhoneNumbers.get(i+1).getCallGroupId();
            phoneNumber = callGroupPhoneNumbers.get(i+1).getPhoneNumber();
          }
          break;
        }
      }
      // If no number has lastUsed = true, select the first number to use as the current number
      if (previousUsedGroupPhoneId == null) {
        currentlyUsedGroupPhoneId = callGroupPhoneNumbers.get(0).getId();
        currentlyUsedGroupId = callGroupPhoneNumbers.get(0).getCallGroupId();
        phoneNumber = callGroupPhoneNumbers.get(0).getPhoneNumber();
      }
    }
    else {
      currentlyUsedGroupPhoneId = callGroupPhoneNumbers.get(0).getId();
      currentlyUsedGroupId = callGroupPhoneNumbers.get(0).getCallGroupId();
      phoneNumber = callGroupPhoneNumbers.get(0).getPhoneNumber();
    }

    // Mark the previous Phone Number as no longer being lastUsed
    if (previousUsedGroupPhoneId != null) {
      params.put("previousUsedId", previousUsedGroupPhoneId);
      sqlCache.update("callGroup.updateLastUsedPhoneNumber", params);
    }

    // Mark the current Phone Number as being lastUsed and increment call count
    params.put("currentlyUsedId", currentlyUsedGroupPhoneId);
    sqlCache.update("callGroup.updateCurrentlyUsedPhoneNumber", params);


    // Add a row to the phone log table
    params.put("callGroupId", currentlyUsedGroupId);
    params.put("phoneNumber", phoneNumber);
    params.put("createdById", user.trueUserId());
    sqlCache.update("callGroup.addPhoneLog", params);

    if (!phoneNumber.isEmpty()) {
      try {
        return smsService.cleanPhoneNumber("+" + contact.getCountryId() + phoneNumber);
      } catch (NumberParseException e) {
        return "+1385-292-1523";
      }
    }
    else {
      return "+13852921523";
    }
  }

  private String getContactListOldName(String leadLevel) {
    if (leadLevel.equals("1")) {
      return "Level 1";
    }
    else if (leadLevel.equals("2")) {
      return "Level 2";
    }
    else if (leadLevel.equals("3")) {
      return "Level 3";
    }
    else if (leadLevel.equals("9")) {
      return "Level 9";
    }
    else if (leadLevel.equals("10")) {
      return "InsideSales";
    }

    return null;
  }

  private String getContactListName(String leadLevel) {
    if (leadLevel.equals("1")) {
      return "leadlevel1_Day1";
    }
    else if (leadLevel.equals("2")) {
      return "Leadlevel2";
    }
    else if (leadLevel.equals("3")) {
      return "Leadlevel3";
    }
    else if (leadLevel.equals("9")) {
      return "Level 9";
    }
    else if (leadLevel.equals("10")) {
      return "Leadlevel10";
    }

    return null;
  }
  // Get the Genesys id of the Contact List from Genesys
  private String getContactListId(String leadLevel, OutboundApi apiInstance, String genesysContactListName, Boolean useOldContactLists) throws IOException, ApiException {
    GetOutboundContactlistsRequest goclr = new GetOutboundContactlistsRequest();
    goclr.setPageSize(100);
    ContactListEntityListing contactListEntity = apiInstance.getOutboundContactlists(goclr);
    String contactListName = "";
    if (genesysContactListName == null || genesysContactListName.isEmpty()) {
      if (useOldContactLists) {
        contactListName = getContactListOldName(leadLevel);
      }
      else {
        contactListName = getContactListName(leadLevel);
      }

      if (contactListName == null) {
        return null;
      }
    }
    else {
      contactListName = genesysContactListName;
    }

    String contactListId = "";
    for (ContactList cl: contactListEntity.getEntities()) {
      if (cl.getName().equals(contactListName)) {
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

  public void processGenesysContacts()  {
    // Get list of Contact IDs that need to be put into each Genesys Contact List
    List<Contact> contacts = sqlCache.query("genesys.getContactIdsWeek1", null, Contact.class);
    addContactsToGenesys(contacts, "leadlevel1_week1");

    contacts = sqlCache.query("genesys.getContactIdsWeek2", null, Contact.class);
    addContactsToGenesys(contacts, "leadlevel1_week2");

    contacts = sqlCache.query("genesys.getContactIdsAged", null, Contact.class);
    addContactsToGenesys(contacts, "leadlevel1_aged");
  }

  private void addContactsToGenesys(List<Contact> contacts, String contactListName) {
    for (Contact contact: contacts) {
      List<CustomFieldGroup> customFieldGroups = customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.CONTACT.toString(), contact.getId());
      List<CustomFieldValue> values = customFieldGroups.get(0).getCustomFieldValues();

      CustomFieldValue genesysContactListName = new CustomFieldValue();
      genesysContactListName.setFieldName("Genesys Contact List Name");
      genesysContactListName.setFieldValue(contactListName);
      values.add(genesysContactListName);

      try {
        addContact(contact.getId(), values, false);
      } catch (Exception e) {
        String msg = "GENESYS: Error updating contact list: {}";
        log.error(msg, e.getMessage());
      }
    }
  }

  public void updateContactIds(List<Map<String, String>> data) {
    for (Map<String, String> contactValuesMap: data) {
      Long contactId = Long.parseLong(contactValuesMap.get("contactId"));
      String genesysContactId = contactValuesMap.get("genesysContactId");

      HashMap<String, Object> params = new HashMap<>();
      params.put("contactId", contactId);
      params.put("genesysContactId", genesysContactId);
      sqlCache.update("genesys.updateGenesysContactIdByContactId", params);
      try {
        updateContact(contactId);
      } catch (Exception e) {
        String msg = "GENESYS: Error updating contact id: {}";
        log.error(msg, e.getMessage());
      }
    }
  }

  public void updateContactIds(String listOfContactIds) {
    String[] contactIds = listOfContactIds.split(",");
    for (String contactId: contactIds) {
      try {
        Long contactIdToUpdate = Long.parseLong(contactId);
        updateContact(contactIdToUpdate);
      } catch (Exception e) {
        String msg = "GENESYS: Error updating contact id (" +contactId + "): {}";
        log.error(msg, e.getMessage());
      }
    }
  }

}
