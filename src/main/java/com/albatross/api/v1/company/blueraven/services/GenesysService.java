package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.ContactService;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.SMSService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.i18n.phonenumbers.NumberParseException;
import com.mypurecloud.sdk.v2.*;
import com.mypurecloud.sdk.v2.api.OutboundApi;
import com.mypurecloud.sdk.v2.api.request.*;
import com.mypurecloud.sdk.v2.extensions.AuthResponse;
import com.mypurecloud.sdk.v2.model.*;
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
    HashMap<String, Object> params = new HashMap<>();
    params.put("phone", phoneNumber);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("companyId", user.getCompanyId());
    Optional<Contact> result = sqlCache.get("genesys.getContactByPhone", params, new ContactService.ContactMapper<>(Contact.class, om));
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

  public void addContact(Long contactId, List<CustomFieldValue> values) throws IOException, ApiException {
    // Only add contacts if we are in Prod
    if (StringUtils.isEmpty(clientId) || StringUtils.isEmpty(clientSecret == null)) {
      return;
    }

    Contact contact = contactService.getContact(contactId);
    WritableDialerContact wdc = new WritableDialerContact();
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd");
    HashMap<String, Object> contactMap = new HashMap<>();
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put("phone", contact.getPhone() != null ? contact.getPhone() : "");
    contactMap.put("mobile", contact.getMobile() != null ? contact.getMobile() : "");
    contactMap.put("contact_type_id", contact.getContactTypeId() != null ? contact.getContactTypeId() : "");
    contactMap.put("contact_type", contact.getContactTypeId() != null ? contact.getContactTypeId() : "");
    contactMap.put("Lead Main State", "");
    contactMap.put("Total Call Attempts", "");
    contactMap.put("Contacted Call Attempts", "");
    contactMap.put("contactcallable", 1);
    contactMap.put("zipcodeautomatictimezone", "");
    contactMap.put("CallRecordLastAttempt-mobile", "");
    contactMap.put("CallRecordLastResult-mobile", "");
    contactMap.put("CallRecordLastAgentWrapup-mobile", "");
    contactMap.put("SmsLastAttempt-mobile", "");
    contactMap.put("SmsLastResult-mobile", "");
    contactMap.put("Callable-mobile", 1);
    contactMap.put("AutomaticTimeZone-mobile", "");
    contactMap.put("callerId", getCallerGroupNumber(contact));
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatter.format(calendar.getTime()));

    getCfvValues(contactMap, values);

    wdc.setData(contactMap);

    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();
    ContactListEntityListing contactListEntity = apiInstance.getOutboundContactlists(new GetOutboundContactlistsRequest());

    String lead = (String) contactMap.get("lead_source");
    String leadSourceDetail = (String) contactMap.get("lead_source_detail");
    String leadLevel = (String) contactMap.get("lead_level");
    if (lead.isEmpty()) {
      return;
    }

    String contactListName = getContactListName(lead, leadSourceDetail, leadLevel);
    if (contactListName == null) {
      return;
    }

    String contactListId = "";
    for (ContactList cl: contactListEntity.getEntities()) {
      if (cl.getName().equals(lead)) {
        contactListId = cl.getId();
        break;
      }
    }
    // If no Contact List match was found
    if (contactListId.isEmpty()) {
      return;
    }

    List<DialerContact> dc = apiInstance.postOutboundContactlistContacts(contactListId, new ArrayList<>(Arrays.asList(wdc)), false, false, false);
    // Store the Genesys Contact ID
    updateGenesysCfv(contact.getId(), dc.get(0).getId(), 19357L);
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
    params.put("userId", currentUser.getId());
    sqlCache.update("customFieldValues.contact.upsertCustomFieldValue", params);
  }

  public void updateContact(Long contactId) throws IOException, ApiException {
    // Only update contacts if we are in Prod
    if (StringUtils.isEmpty(clientId) || StringUtils.isEmpty(clientSecret == null)) {
      return;
    }

    Contact contact = contactService.getContact(contactId);
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd");
    DialerContact dc = new DialerContact();
    HashMap<String, Object> contactMap = new HashMap<>();
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put("phone", contact.getPhone() != null ? contact.getPhone() : "");
    contactMap.put("mobile", contact.getMobile() != null ? contact.getMobile() : "");
    contactMap.put("contact_type_id", contact.getContactTypeId() != null ? contact.getContactTypeId() : "");
    contactMap.put("Total Call Attempts", "");
    contactMap.put("Contacted Call Attempts", "");
    contactMap.put("contactcallable", 1);
    contactMap.put("zipcodeautomatictimezone", "");
    contactMap.put("CallRecordLastAttempt-mobile", "");
    contactMap.put("CallRecordLastResult-mobile", "");
    contactMap.put("CallRecordLastAgentWrapup-mobile", "");
    contactMap.put("SmsLastAttempt-mobile", "");
    contactMap.put("SmsLastResult-mobile", "");
    contactMap.put("Callable-mobile", 1);
    contactMap.put("AutomaticTimeZone-mobile", "");
    contactMap.put("callerId", getCallerGroupNumber(contact));
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatter.format(calendar.getTime()));

    List<CustomFieldGroup> customFieldGroups = customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.CONTACT.toString(), contactId);
    getCfvValues(contactMap, customFieldGroups.get(0).getCustomFieldValues());

    dc.setData(contactMap);
    // Get the list of contacts
    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();
    ContactListEntityListing contactListEntity = apiInstance.getOutboundContactlists(new GetOutboundContactlistsRequest());

    String lead = (String) contactMap.get("lead_source");
    if (lead.isEmpty()) {
      return;
    }

    String contactListId = "";
    for (ContactList cl: contactListEntity.getEntities()) {
      if (cl.getName().equals(lead)) {
        contactListId = cl.getId();
        break;
      }
    }
    // If no Contact List match was found
    if (contactListId.isEmpty()) {
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
      }
    }
  }

  private String getCallerGroupNumber(Contact contact) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("postalCode", contact.getPostalCode());
    Optional<String> groupNumber = sqlCache.get("callGroup.getCallerGroupNumber", params, new SingleColumnRowMapper<>(String.class));
    if (groupNumber.isPresent()) {
      try {
        return smsService.cleanPhoneNumber("+" + contact.getCountryId() + groupNumber.get());
      } catch (NumberParseException e) {
        return "+1385-292-1523";
      }
    }
    else {
      return "+13852921523";
    }
  }

  private String getContactListName(String lead, String leadSourceDetail, String leadLevel) {
    HashSet<String> levelOneLeadSourceDetails = new HashSet<>() {{
      add("SolarReviews");
      add("Solar Lead Factory");
      add("SolarLeadFactory");
      add("RGR");
      add("Modernize");
      add("Energy Bill Cruncher");
      add("EnergyBillCruncher");
      add("Clean Energy Experts");
      add("CleanEnergyExperts");
      add("Clean Energy Authority");
      add("CleanEnergyAuthority");
    }};

    HashSet<String> levelTwoLeadSourceDetails = new HashSet<>() {{
      add("Recursive Advertising");
      add("RecursiveAdvertising");
      add("LeadLabz");
      add("Energy Bill Cruncher");
      add("EnergyBillCruncher");
      add("Blue Fire Leads");
      add("BlueFireLeads");
    }};

    HashSet<String> manualCallsSources = new HashSet<>() {{
      add("Retention");
      add("Closer Gen");
      add("CloserGen");
      add("Referral");
      add("Setter Gen");
      add("SetterGen");
      add("Retargeted");
      add("Purchased Appointments");
      add("PurchasedAppointments");
    }};

    if (leadSourceDetail == null) {
      leadSourceDetail = "";
    }

    if (leadLevel == null) {
      leadLevel = "";
    }

    if (leadLevel.equals("1")) {
      if (lead.equals("Paid Lead Gen")) {
        if (levelOneLeadSourceDetails.contains(leadSourceDetail)) {
          return "Level 1";
        }
      }
    }
    else if (leadLevel.equals("2")) {
      if (lead.equals("Paid Lead Gen")) {
        if (levelTwoLeadSourceDetails.contains(leadSourceDetail)) {
          return "Level 3";
        }
      }
    }
    else if (leadLevel.equals("3")) {
      if (lead.equals("Paid Lead Gen")) {
        if (leadSourceDetail.equals("Best Company") || leadSourceDetail.equals("Clean Energy Experts")) {
          return "Level 3";
        }
      }
      else if (lead.equals("Paid Advertising")) {
        if (leadSourceDetail.equals("Faraday") || leadSourceDetail.equals("Instagram") || leadSourceDetail.equals("Facebook")
          || leadSourceDetail.equals("YouTube")) {
          return "Level 3";
        }
      }
      else if (lead.equals("Organic")) {
        if (leadSourceDetail.equals("Digital Organic")) {
          return "Level 3";
        }
      }
    }
    else if (leadLevel.equals("10")) {
      return "InsideSales";
    }
    else if (manualCallsSources.contains(lead)) {
      return "Manual Calls";
    }

    return null;
  }
}
