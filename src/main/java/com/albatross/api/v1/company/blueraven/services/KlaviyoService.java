package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.KlaviyoQuery;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.util.ObjectUtils;

import java.net.http.HttpClient;

import java.io.InputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class KlaviyoService {

  @Value(value = "${klaviyo.api.host}")
  private String apiUrl;

  @Value(value = "${klaviyo.api.token}")
  private String basicToken;

  private final SqlCache sqlCache;

  private final GenesysService genesysService;

  private final Set<String> DIGITAL_LEAD_SOURCES = new HashSet<>(Arrays.asList ("Paid Lead Gen", "Paid Advertising", "Organic", "Organic with Referral"));

  // Used to handle contact create/updates
  public void handleContact(Long contactId, List<CustomFieldValue> values, boolean isUpdate) {
    // Return if token is not set
    if (ObjectUtils.isEmpty(basicToken) || ObjectUtils.isEmpty(basicToken == null) || basicToken.length() < 5) {
      return;
    }

    String url = apiUrl + "/profiles";
    JSONObject contactJson = new JSONObject();
    JSONObject attributes = new JSONObject();
    JSONObject properties = new JSONObject();
    JSONObject data = new JSONObject();
    JSONObject location = new JSONObject();

    data.put("type", "profile");

    try {
      GenesysService.CustomContact contact = genesysService.getContact(contactId, true);

      attributes.put("email", contact.getEmail());
      attributes.put("external_id", contact.getId());
      attributes.put("first_name", contact.getFirstName());
      attributes.put("last_name", contact.getLastName());
      location.put("address1", contact.getStreet1());
      location.put("address2", contact.getStreet2());
      location.put("city", contact.getCity());
      location.put("region", contact.getState());
      location.put("zip", contact.getPostalCode());

      attributes.put("location", location);

      String phoneNumber = contact.getPhone();
      if (phoneNumber != null) {
        phoneNumber = phoneNumber.replaceAll("[^\\d]+", "");
        if (!phoneNumber.startsWith("1")) {
          phoneNumber = "+1" + phoneNumber;
        }
        else {
          phoneNumber = "+" + phoneNumber;
        }
      }

      data.put("attributes", attributes);
      attributes.put("properties", properties);

      getCfvValues(properties, values);

      contactJson.put("data", data);

      if (isUpdate) {
        String klaviyoProfileId = getKlaviyoProfileId(contact.getEmail());
        data.put("id", klaviyoProfileId);
        ResponseEntity<String> resp = PATCH(url + "/" + klaviyoProfileId, contactJson.toString()); //TODO: Change this to work with new approach
        if (resp.getStatusCode().value() != 200) {
          JSONObject errorResp = new JSONObject(resp.getBody());
          JSONArray errors = errorResp.getJSONArray("errors");
          String errorMessage = "";
          for (int i = 0; i < errors.length(); i++) {
            JSONObject error = errors.getJSONObject(i);
            errorMessage += error.getString("detail");
          }
          log.error("KLAVIYO: Error adding contact {}", errorMessage);
          throw new Exception(errorMessage);
        }
      }
      else {
        HttpResponse resp = POST(url, IOUtils.toInputStream(contactJson.toString(), StandardCharsets.UTF_8));
        if (resp.getResponseCode() != 201) {
          JSONObject errorResp = resp.getJSON();
          JSONArray errors = errorResp.getJSONArray("errors");
          String errorMessage = "";
          for (int i = 0; i < errors.length(); i++) {
            JSONObject error = errors.getJSONObject(i);
            errorMessage += error.getString("detail");
          }
          log.error("KLAVIYO: Error adding contact {}", errorMessage);
          throw new Exception(errorMessage);
        }
        JSONObject dataResp = resp.getJSON();
        JSONObject dataJson = dataResp.getJSONObject("data");
        String klaviyoId = dataJson.getString("id");

        JSONObject subscribeEmailProfileRequestBody = generateSubscribeEmailProfilesRequestBody(klaviyoId, contact.getEmail(), phoneNumber);
        String subscribeUrl = apiUrl + "/profile-subscription-bulk-create-jobs/";
        // Subscribe the contact/profile to Email messaging, also adds them to the list
        resp = POST(subscribeUrl, IOUtils.toInputStream(subscribeEmailProfileRequestBody.toString(), (Charset) null));
        if (resp.getResponseCode() != 202) {
          JSONObject errorResp = resp.getJSON();
          JSONArray errors = errorResp.getJSONArray("errors");
          String errorMessage = "";
          for (int i = 0; i < errors.length(); i++) {
            JSONObject error = errors.getJSONObject(i);
            errorMessage += error.getString("detail");
          }
          log.error("KLAVIYO: Error subscribing contact to email {}", errorMessage);
          throw new Exception(errorMessage);
        }

        JSONObject subscribeSmsProfileRequestBody = generateSubscribeSmsProfilesRequestBody(klaviyoId, contact.getEmail(), phoneNumber);
        // Subscribe the contact/profile to Email messaging, also adds them to the list
        resp = POST(subscribeUrl, IOUtils.toInputStream(subscribeSmsProfileRequestBody.toString(), (Charset) null));
        if (resp.getResponseCode() != 202) {
          JSONObject errorResp = resp.getJSON();
          JSONArray errors = errorResp.getJSONArray("errors");
          String errorMessage = "";
          for (int i = 0; i < errors.length(); i++) {
            JSONObject error = errors.getJSONObject(i);
            errorMessage += error.getString("detail");
          }
          log.error("KLAVIYO: Error subscribing contact to SMS {}", errorMessage);
          throw new Exception(errorMessage);
        }
      }

      //log.info("KLAVIYO: Successfully posted contactId="+ contactId + ", url="+url);
    } catch (Exception e) {
      String msg = "KLAVIYO: Error in posting contactId="+ contactId + ", msg=" +e.getMessage() + ", url="+url;
      log.error(msg);
    }
  }

  // Used to set the project id on the profile/contact in Klaviyo, called when a project is created
  public void updateProjectId(Long contactId, Long projectId) {
    // Return if token is not set
    if (ObjectUtils.isEmpty(basicToken) || ObjectUtils.isEmpty(basicToken == null) || basicToken.length() < 5) {
      return;
    }
    // Check the lead source to see if this is a Klaviyo contact
    if (!isKlaviyoContact(contactId)) {
      return;
    }

    GenesysService.CustomContact contact = genesysService.getContact(contactId, true);

    String url = apiUrl + "/profiles";
    JSONObject contactJson = new JSONObject();
    JSONObject attributes = new JSONObject();
    JSONObject properties = new JSONObject();
    JSONObject data = new JSONObject();

    data.put("type", "profile");

    try {
      properties.put("project_id", projectId);
      attributes.put("properties", properties);
      data.put("attributes", attributes);

      contactJson.put("data", data);

      String klaviyoProfileId = getKlaviyoProfileId(contact.getEmail());
      data.put("id", klaviyoProfileId);
      ResponseEntity<String> resp = PATCH(url + "/" + klaviyoProfileId, contactJson.toString());
      if (resp.getStatusCode().value() != 200) {
        JSONObject errorResp = new JSONObject(resp.getBody());
        JSONArray errors = errorResp.getJSONArray("errors");
        String errorMessage = "";
        for (int i = 0; i < errors.length(); i++) {
          JSONObject error = errors.getJSONObject(i);
          errorMessage += error.getString("detail");
        }
        log.error("KLAVIYO: Error adding contact {}", errorMessage);
        throw new Exception(errorMessage);
      }

      //log.info("KLAVIYO: Successfully posted contactId="+ contactId + ", url="+url);
    } catch (Exception e) {
      String msg = "KLAVIYO: Error in posting contactId="+ contactId + ", msg=" +e.getMessage() + ", url="+url;
      log.error(msg);
    }
  }

  // Used to create the request body for subscribing to email
  private JSONObject generateSubscribeEmailProfilesRequestBody(String klaviyoId, String email, String phoneNumber) {
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
    emailList.put("id", "RdueKz");

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
    smsList.put("id", "SnT5Dr");

    list.put("data", smsList);

    subscriberProfile.put("data", data);
    return subscriberProfile;
  }

  private void getCfvValues(JSONObject properties, List<CustomFieldValue> values) {
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
      } else if (cfv.getIntArrayValue() != null && !cfv.getIntArrayValue().isEmpty()) {
        for (ListOfValue lov : cfv.getListOfValues()) {
          List<Integer> selectedValueIds = cfv.getIntArrayValue();
          if (selectedValueIds.contains(lov.getId().intValue())) {
            if (value.length() > 0) {
              value += ", ";
            }

            value += lov.getName();
          }
        }
      }

      if (cfv.getFieldName() != null) {
        if (cfv.getFieldName().equals("Lead Source")) {
          properties.put("lead_source", value);
        } else if (cfv.getFieldName().equals("Lead Source Detail")) {
          properties.put("lead_source_detail", value);
        } else if (cfv.getFieldName().equals("Lead Status")) {
          properties.put("lead_status", value);
        } else if (cfv.getFieldName().equals("Lead Level")) {
          properties.put("lead_level", cfv.getIntValue() == null ? "" : cfv.getIntValue().toString());
        }
      }
    }
  }

  private boolean isKlaviyoContact(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    Optional<String> leadSource =
      sqlCache.getBySql(
        KlaviyoQuery.getLeadSource, params, new SingleColumnRowMapper<>(String.class));
    if (leadSource.isPresent() && DIGITAL_LEAD_SOURCES.contains(leadSource.get())) {
      return true;
    }
    else {
      return false;
    }
  }

  // Get Klaviyo's internal id for a contact
  private String getKlaviyoProfileId(String email) throws Exception {
    try {
      String filterParam = String.format("?filter=equals(email,\"%s\")", email);
      String url = apiUrl + "/profiles" + filterParam;
      HttpResponse resp = GET(url);
      if (resp.getResponseCode() != 200) {
        JSONObject errorResp = resp.getJSON();
        JSONArray errors = errorResp.getJSONArray("errors");
        String errorMessage = "";
        for (int i = 0; i < errors.length(); i++) {
          JSONObject error = errors.getJSONObject(i);
          errorMessage += error.getString("detail");
        }
        log.error("KLAVIYO: Error getting Klaviyo contact profile Id {}", errorMessage);
        throw new Exception(errorMessage);
      }
      JSONObject dataResp = resp.getJSON();
      JSONArray dataJsonArray = dataResp.getJSONArray("data");
      JSONObject data = dataJsonArray.getJSONObject(0);
      return data.getString("id");
    } catch (Exception e) {
      String errorMessage = "Error getting Klaviyo contact profile Id:" + e.getMessage();
      log.error("KLAVIYO: " + errorMessage);
      throw new Exception(errorMessage);
    }
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

  private ResponseEntity<String> PATCH(String url, String content) throws Exception {
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

    return response;
  }
}
