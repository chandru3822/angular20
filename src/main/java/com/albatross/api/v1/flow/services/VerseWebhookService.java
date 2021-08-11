package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.VersusLeadEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class VerseWebhookService {
  private final SqlCache sqlCache;

  private final SecurityService securityService;

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

      User currentUser = securityService.getCurrentUser();
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
        params.put("userId", currentUser.getId());
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


  private String checkIfCustomFieldDropdownValueExists(Integer listOfValueId, String customFieldDropdownValue) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("listOfValueId", listOfValueId);
      params.put("customFieldDropdownValue", customFieldDropdownValue);

      Optional<String> customFieldDropdownValueId = sqlCache.queryForObjectOptional("ricochetWebhook.checkIfCustomFieldDropdownValueExists", params, String.class);
      return customFieldDropdownValueId.orElse("null");
  }
}
