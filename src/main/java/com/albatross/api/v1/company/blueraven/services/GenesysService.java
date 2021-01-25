package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.ContactService;
import com.fasterxml.jackson.databind.ObjectMapper;
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
  private SecurityService securityService;

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
    Contact contact = contactService.getContact(contactId);
    WritableDialerContact wdc = new WritableDialerContact();
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
    HashMap<String, Object> contactMap = new HashMap<>();
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put("phone", contact.getPhone() != null ? contact.getPhone() : "");
    contactMap.put("mobile", contact.getMobile() != null ? contact.getMobile() : "");
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatter.format(calendar.getTime()));
    contactMap.put("lead_source", "");
    contactMap.put("lead_source_detail", "");
    contactMap.put("lead_status", "");

    for (CustomFieldValue cfv: values) {
      String value = "";
      if (cfv.getIntValue() != null && !cfv.getListOfValues().isEmpty()) {
        for (ListOfValue lov: cfv.getListOfValues()) {
          if (lov.getId().equals(cfv.getIntValue())) {
            value = lov.getName();
            break;
          }
        }
      }

      if (cfv.getFieldName().equals("Lead Source")) {
        contactMap.put("lead_source", value);
      }
      else if (cfv.getFieldName().equals("Lead Source Detail")) {
        contactMap.put("lead_source_detail", value);
      }
      else if (cfv.getFieldName().equals("Lead Status")) {
        contactMap.put("lead_status", value);
      }
    }
    wdc.setData(contactMap);

    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();
    ContactListEntityListing newContactList = apiInstance.getOutboundContactlists(new GetOutboundContactlistsRequest());
    String contactListId = newContactList.getEntities().get(0).getId();

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

  public void updateContact(Long contactId, List<CustomFieldValue> values) throws IOException, ApiException {
    Contact contact = contactService.getContact(contactId);
    Calendar calendar = Calendar.getInstance();
    SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
    DialerContact dc = new DialerContact();
    HashMap<String, Object> contactMap = new HashMap<>();
    contactMap.put("id", contact.getId());
    contactMap.put("first_name", contact.getFirstName() != null ? contact.getFirstName() : "");
    contactMap.put("last_name", contact.getLastName() != null ? contact.getLastName() : "");
    contactMap.put("street1", contact.getStreet1() != null ? contact.getStreet1() : "");
    contactMap.put("street2", contact.getStreet2() != null ? contact.getStreet2() : "");
    contactMap.put("phone", contact.getPhone() != null ? contact.getPhone() : "");
    contactMap.put("mobile", contact.getMobile() != null ? contact.getMobile() : "");
    contactMap.put("city", contact.getCity() != null ? contact.getCity() : "");
    contactMap.put("postal_code", contact.getPostalCode() != null ? contact.getPostalCode() : "");
    contactMap.put("email", contact.getEmail() != null ? contact.getEmail() : "");
    contactMap.put("date_created", formatter.format(calendar.getTime()));
    contactMap.put("lead_source", "");
    contactMap.put("lead_source_detail", "");
    contactMap.put("lead_status", "");

    for (CustomFieldValue cfv: values) {
      String value = "";
      if (cfv.getIntValue() != null && !cfv.getListOfValues().isEmpty()) {
        for (ListOfValue lov: cfv.getListOfValues()) {
          if (lov.getId().equals(cfv.getIntValue())) {
            value = lov.getName();
            break;
          }
        }
      }

      if (cfv.getFieldName().equals("Lead Source")) {
        contactMap.put("lead_source", value);
      }
      else if (cfv.getFieldName().equals("Lead Source Detail")) {
        contactMap.put("lead_source_detail", value);
      }
      else if (cfv.getFieldName().equals("Lead Status")) {
        contactMap.put("lead_status", value);
      }
    }

    dc.setData(contactMap);
    // Get the list of contacts
    Configuration.setDefaultApiClient(initGenesysApi());
    OutboundApi apiInstance = new OutboundApi();
    ContactListEntityListing newContactList = apiInstance.getOutboundContactlists(new GetOutboundContactlistsRequest());
    String contactListId = newContactList.getEntities().get(0).getId();


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
}
