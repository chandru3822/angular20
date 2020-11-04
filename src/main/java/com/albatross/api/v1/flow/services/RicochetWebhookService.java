package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.RicochetLead;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class RicochetWebhookService {
    private final SqlCache sqlCache;

    private final CustomFieldValueService customFieldValueService;

    public ResponseEntity saveLead(RicochetLead lead) throws Exception {
        try {
            Long contactId = getContactIdByRicochetLeadId(lead.getUniqueIdentifier().toString());

            HashMap<String, Object> params = new HashMap<>();
            params.put("leadOwnerEmail", lead.getLeadOwner());
            params.put("firstName", lead.getCustomer().getFirstName());
            params.put("lastName", lead.getCustomer().getLastName());
            params.put("mobile", lead.getCustomer().getPhone1());
            params.put("email", lead.getCustomer().getEmail());
            params.put("street1", lead.getCustomer().getAddress().getAddress1());
            params.put("city", lead.getCustomer().getAddress().getCity());
            params.put("postalCode", lead.getCustomer().getAddress().getZip());
            params.put("stateAbbreviation", lead.getCustomer().getAddress().getState());

            if (contactId == null) {
                contactId = sqlCache.updateReturningId("ricochetWebhook.insertLead", params, "id").longValue();
            } else {
                contactId = sqlCache.updateReturningId("ricochetWebhook.updateLead", params, "id").longValue();
            }

            processCustomFieldValues(lead, contactId);

            String msg = "Ricochet lead info has been successfully saved for contact_id " + contactId + ".";
            log.info(msg);
            return ResponseEntity.status(HttpStatus.ACCEPTED).body(msg);
        } catch (Exception e) {
            String msg = "Failed to save Ricochet lead info.";
            log.error(msg, e);
            throw new Exception(msg, e);
        }
    }

    private Long getContactIdByRicochetLeadId(String ricochetLeadId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("ricochetLeadId", ricochetLeadId);

        return sqlCache.queryForObject("ricochetWebhook.getContactIdByRicochetLeadId", params, Long.class);
    }

    private void processCustomFieldValues(RicochetLead lead, Long contactId) {
        // checks to see if the custom field dropdown values already exist in the database
        Integer leadStatusId = checkIfCustomFieldDropdownValueExists(696, lead.getStatus(), lead.getLeadOwner());
        Integer leadSourceId = checkIfCustomFieldDropdownValueExists(520, lead.getLead_source(), lead.getLeadOwner());
        Integer leadSourceDetailId = checkIfCustomFieldDropdownValueExists(543, lead.getLead_source_detail(), lead.getLeadOwner());

        HashMap<String, Object> params = new HashMap<>();
        params.put("leadOwnerEmail", lead.getLeadOwner());

        /* If the custom field dropdown values don't already exist in the database, then they are inserted below. This
         * allows us to obtain an ID for each custom field dropdown value, whether or not it existed beforehand. */
        if (leadStatusId == null) {
            params.put("listOfValueId", 696);
            params.put("customFieldDropdownValue", lead.getStatus());

            leadStatusId = sqlCache.updateReturningId("ricochetWebhook.insertCustomFieldDropdownValue", params, "id").intValue();
        }

        if (leadSourceId == null) {
            params.put("listOfValueId", 520);
            params.put("customFieldDropdownValue", lead.getLead_source());

            leadSourceId = sqlCache.updateReturningId("ricochetWebhook.insertCustomFieldDropdownValue", params, "id").intValue();
        }

        if (leadSourceDetailId == null) {
            params.put("listOfValueId", 543);
            params.put("customFieldDropdownValue", lead.getLead_source_detail());

            leadSourceDetailId = sqlCache.updateReturningId("ricochetWebhook.insertCustomFieldDropdownValue", params, "id").intValue();
        }

        // prepares the custom field value objects
        CustomFieldValue leadStatus = new CustomFieldValue();
        leadStatus.setIntValue(leadStatusId.longValue());

        CustomFieldValue leadSource = new CustomFieldValue();
        leadSource.setIntValue(leadSourceId.longValue());

        CustomFieldValue leadSourceDetail = new CustomFieldValue();
        leadSourceDetail.setIntValue(leadSourceDetailId.longValue());

        CustomFieldValue ricochetLeadId = new CustomFieldValue();
        ricochetLeadId.setTextValue(lead.getUniqueIdentifier().toString());

        CustomFieldValue hubspotId = new CustomFieldValue();
        hubspotId.setTextValue(lead.getHubspotId().toString());

        // adds all of the custom field value objects to a list
        List<CustomFieldValue> customFieldValues = new ArrayList<>();
        customFieldValues.add(leadStatus);
        customFieldValues.add(leadSource);
        customFieldValues.add(leadSourceDetail);
        customFieldValues.add(ricochetLeadId);
        customFieldValues.add(hubspotId);

        // sets the customFieldGroupAssignmentId to 103 for all of the custom field value objects
        customFieldValues.forEach(customFieldValue -> customFieldValue.setCustomFieldGroupAssignmentId(103L));

        // processes the custom field value updates
        customFieldValueService.updateCustomFieldValues(customFieldValues, contactId, "contact");
    }

    private Integer checkIfCustomFieldDropdownValueExists(Integer listOfValueId, String customFieldDropdownValue, String leadOwnerEmail) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("listOfValueId", listOfValueId);
        params.put("customFieldDropdownValue", customFieldDropdownValue);
        params.put("leadOwnerEmail", leadOwnerEmail);

        return sqlCache.queryForObject("ricochetWebhook.checkIfCustomFieldDropdownValueExists", params, Integer.class);
    }
}
