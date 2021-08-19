package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.VersusLeadEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class VerseWebhookService {
  @Value(value = "${verse.api.key}")
  private String apiKey;

  private final SqlCache sqlCache;

  public ResponseEntity updateContactLeadStatus(VersusLeadEvent versusLeadEvent) throws Exception {
    String msg = "";

    try {
      String event = versusLeadEvent.getEvent();
      String leadStatus = "";
      // Determine lead status based on Event and Title from Verse
      if (event.equals("lead_created")) {
        leadStatus = "New";
      }
      else if (event.equals("lead_activity")) {
        String title = versusLeadEvent.getTitle();
        if (title.equals("Qualified Lead")) {
          leadStatus = "Scheduled";
        }
        else if (title.equals("Unqualified Lead")) {
          leadStatus = "Unqualified";
        }
      }

      String leadStatusId = checkIfCustomFieldDropdownValueExists(696, leadStatus);
      if (!leadStatusId.equals("null")) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("dateValue", null);
        params.put("timestampValue", null);
        params.put("booleanValue", null);
        params.put("textValue", null);
        params.put("numericValue", null);
        params.put("intValue", Long.parseLong(leadStatusId));
        params.put("intArrayValue", null);
        params.put("customFieldGroupAssignmentId", 399L);
        params.put("sourceId", Long.parseLong(versusLeadEvent.getExternalLeadId()));
        // Sales Dev Lead's user ID
        params.put("userId", 2371412L);
        sqlCache.update("customFieldValues.contact.upsertCustomFieldValue", params);
        msg = "VERSE: Contact Id " + versusLeadEvent.getExternalLeadId() + " lead status successfully updated";
      }
      else {
        msg = "VERSE: Unable to update Contact Id " + versusLeadEvent.getExternalLeadId() + " lead status due to unknown lead status";
      }

      log.info(msg);
      return ResponseEntity.status(HttpStatus.ACCEPTED).body(msg);
    } catch (Exception e) {
      msg = "VERSE: Failed to update Lead Status.";
      log.error(msg, e);
      throw new Exception(msg, e);
    }
  }

  public void postContact(HashMap<String, Object> contactMap) {
    JSONObject params = new JSONObject();
    params.put("firstName", contactMap.get("first_name"));
    params.put("lastName", contactMap.get("last_name"));
    params.put("email", contactMap.get("email"));
    params.put("phoneNumber", contactMap.get("phone"));
    params.put("type", "Solar");
    params.put("street", contactMap.get("street1"));
    params.put("city", contactMap.get("city"));
    params.put("state", contactMap.get("state"));
    params.put("postalCode", contactMap.get("postal_code"));
    params.put("zapierLeadId", contactMap.get("id"));
    params.put("channelWebsite", contactMap.get("lead_source_detail"));

    Map<String, String> headers = new HashMap<>();
    headers.put("X-API-KEY", apiKey);
    headers.put("Content-Type", "application/json");
    headers.put("Accept", "application/json");
    try {
      HttpResponse resp = HttpUtils.call("POST", "https://api.verse.io/v1/zapier", headers, new ByteArrayInputStream(params.toString().getBytes()));
    } catch (Exception e) {
      String msg = "VERSE: Failed to post Contact to Verse.";
      log.error(msg, e);
    }
  }

  private String checkIfCustomFieldDropdownValueExists(Integer listOfValueId, String customFieldDropdownValue) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("listOfValueId", listOfValueId);
      params.put("customFieldDropdownValue", customFieldDropdownValue);

      Optional<String> customFieldDropdownValueId = sqlCache.queryForObjectOptional("ricochetWebhook.checkIfCustomFieldDropdownValueExists", params, String.class);
      return customFieldDropdownValueId.orElse("null");
  }
}
