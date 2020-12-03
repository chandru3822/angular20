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

import java.util.HashMap;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class RicochetWebhookService {
    private final SqlCache sqlCache;

    private String mapLeadStatus(String leadStatus) {
        switch (leadStatus) {
            case "Aged Database (Temp.)":
                return "Aged Database (Temp.)";
            case "Attempted Contact":
                return "Attempted Contact";
            case "Cold - Never Contacted":
            case "Cold - Not Interested":
                return "Cold";
            case "Email Preferred":
                return "Email Preferred";
            case "":
            case "Low Income/Low Credit Check-in":
            case "New":
            case "New Home/Moving 3 month check-in":
            case "Not statused yet":
            case "Re-targeted Setter Gen 1st Try":
            case "Re-targeted Setter Gen 2nd Try":
            case "Renting/Non - Homeowner Check-in":
            case "Scheduled":
                return "New";
            case "Re-Contact":
                return "Re-Contact";
            case "Re-engaged - CNC":
                return "Re-engaged - CNC";
            case "Re-engaged - CNI":
                return "Re-engaged - CNI";
            case "Referrals - Energized":
                return "Referrals - Energized";
            case "Referrals - Energized 3 mo. Follow up":
                return "Referrals - Energized 3 mo. Follow up";
            case "Referrals - Energized 6 mo. Follow up":
                return "Referrals - Energized 6 mo. Follow up";
            case "Referrals - Installed":
                return "Referrals - Installed";
            case "Unqualified - Already Has Solar":
            case "Unqualified - Bad Contact Info":
            case "Unqualified - DNC":
            case "Unqualified - Duplicate":
            case "Unqualified - Low Credit":
            case "Unqualified - Low Income":
            case "Unqualified - Low Power Bill":
            case "Unqualified - New Home/Moving":
            case "Unqualified - Non-English":
            case "Unqualified - Out of Service Area":
            case "Unqualified - Property Type Not Eligible":
            case "Unqualified - Renting/Non-Homeowner":
            case "Unqualified - Roof Type":
            case "Unqualified - Shading":
            case "Unqualified - Utility Provider Not Eligible":
                return "Unqualified";
            default:
                return "Lead Status of '" + leadStatus + "' not recognized";
        }
    }

    private Optional<String> getContactIdByRicochetLeadId(String ricochetLeadId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("ricochetLeadId", ricochetLeadId);

        return sqlCache.queryForObjectOptional("ricochetWebhook.getContactIdByRicochetLeadId", params, String.class);
    }

    private Long getUserIdByLeadOwnerEmail(String leadOwnerEmail) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("leadOwnerEmail", leadOwnerEmail);

        Optional<Long> userId = sqlCache.queryForObjectOptional("ricochetWebhook.getUserIdByLeadOwnerEmail", params, Long.class);
        return userId.orElse(2371412L);
    }

    private Long getUserPositionIdByUserId(Long leadOwnerUserId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("leadOwnerUserId", leadOwnerUserId);

        Optional<Long> userPositionId = sqlCache.queryForObjectOptional("ricochetWebhook.getUserPositionIdByUserId", params, Long.class);
        return userPositionId.orElse(9016L);
    }

    private Optional<String> getStateAbbreviationByStateName(String stateName) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("stateName", stateName);

        return sqlCache.queryForObjectOptional("ricochetWebhook.getStateAbbreviationByStateName", params, String.class);
    }

    private Optional<Integer> getCompanyStateIdByStateAbbreviation(String stateAbbreviation) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("stateAbbreviation", stateAbbreviation);

        return sqlCache.queryForObjectOptional("ricochetWebhook.getCompanyStateIdByStateAbbreviation", params, Integer.class);
    }

    public ResponseEntity saveLead(RicochetLead lead) throws Exception {
        try {
            if (lead.getStatus() == null) lead.setStatus("New");
            String mappedLeadStatus = mapLeadStatus(lead.getStatus());

            // unrecognized lead statuses are not saved to the database
            if (mappedLeadStatus.contains("not recognized")) {
                log.error("RICOCHET: " + mappedLeadStatus);
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + mappedLeadStatus);
            } else {
                lead.setStatus(mappedLeadStatus);
            }

            HashMap<String, Object> params = new HashMap<>();
            params.put("firstName", lead.getCustomer().getFirstName());
            params.put("lastName", lead.getCustomer().getLastName());
            params.put("mobile", lead.getCustomer().getPhone1());
            params.put("email", lead.getCustomer().getEmail());
            params.put("street1", lead.getCustomer().getAddress().getAddress1());
            params.put("city", lead.getCustomer().getAddress().getCity());
            params.put("postalCode", lead.getCustomer().getAddress().getZip());

            // tries to get a user ID using the lead owner's email. If it fails, returns 2371412 (Sales Dev Lead's user ID)
            Long leadOwnerUserId = getUserIdByLeadOwnerEmail(lead.getLeadOwner());
            params.put("leadOwnerUserId", leadOwnerUserId);

            // tries to get a user position ID using the lead owner's user ID. If it fails, returns 9016 (Sales Dev Lead's user position ID)
            Long leadOwnerUserPositionId = getUserPositionIdByUserId(leadOwnerUserId);
            params.put("leadOwnerUserPositionId", leadOwnerUserPositionId);

            if (!lead.getCustomer().getAddress().getState().isBlank() && lead.getCustomer().getAddress().getState().length() > 2) {
                // tries to get the state abbreviation using the state name
                Optional<String> stateAbbreviation = getStateAbbreviationByStateName(lead.getCustomer().getAddress().getState());
                lead.getCustomer().getAddress().setState(stateAbbreviation.orElse(null));
            }

            // tries to get a company state ID using the state abbreviation
            Optional<Integer> companyStateId = getCompanyStateIdByStateAbbreviation(lead.getCustomer().getAddress().getState());
            params.put("companyStateId", companyStateId.orElse(null));

            // tries to get a company country ID using the company ID
            Optional<Integer> companyCountryId = sqlCache.queryForObjectOptional("ricochetWebhook.getCompanyCountryIdByCompanyId", null, Integer.class);
            params.put("companyCountryId", companyCountryId.orElse(null));

            // tries to get a contact ID using the Ricochet Lead ID
            Optional<String> contactId = getContactIdByRicochetLeadId(lead.getUniqueIdentifier().toString());

            // tries to get a contact ID using the provided contact info, if the previous attempt failed
            if (contactId.isEmpty()) {
                contactId = sqlCache.queryForObjectOptional("ricochetWebhook.getContactIdByContactInfo", params, String.class);
            }

            // if no contact ID was found in either check, creates a new lead/contact
            if (contactId.isEmpty()) {
                Long newContactId = sqlCache.updateReturningId("ricochetWebhook.insertLead", params, "id").longValue();

                log.info("RICOCHET: Saving for contact CONTACT_ID: {} UNIQUE: {}, LOE: {} LOUI: {} LOUPI: {}", newContactId, lead.getUniqueIdentifier(), lead.getLeadOwner(), leadOwnerUserId, leadOwnerUserPositionId);
                processCustomFieldValues(lead, newContactId, leadOwnerUserId);

                contactId = Optional.of(newContactId.toString());
            } else {
                params.put("contactId", Long.parseLong(contactId.get()));
                Long updatedContactId = sqlCache.updateReturningId("ricochetWebhook.updateLead", params, "id").longValue();

                log.info("RICOCHET: Saving for contact CONTACT_ID: {} UNIQUE: {}, LOE: {} LOUI: {} LOUPI: {}", updatedContactId, lead.getUniqueIdentifier(), lead.getLeadOwner(), leadOwnerUserId, leadOwnerUserPositionId);
                processCustomFieldValues(lead, updatedContactId, leadOwnerUserId);

                contactId = Optional.of(updatedContactId.toString());
            }

            String msg = "RICOCHET: Ricochet lead info has been successfully saved for Contact ID " + contactId.get() + " / Ricochet Lead ID " + lead.getUniqueIdentifier() + ".";
            log.info(msg);
            return ResponseEntity.status(HttpStatus.ACCEPTED).body(msg);
        } catch (Exception e) {
            String msg = "RICOCHET: Failed to save Ricochet lead info.";
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

    private void processCustomFieldValues(RicochetLead lead, Long contactId, Long leadOwnerUserId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("contactId", contactId);
        params.put("leadOwnerUserId", leadOwnerUserId);

        // if "null" is returned for leadStatusId, then we don't want to save it, b/c that means it's not one of the existing options, and we don't save new values
        String leadStatusId = checkIfCustomFieldDropdownValueExists(696, lead.getStatus());

        // handles saving 'Lead Status' custom field
        if (!leadStatusId.equalsIgnoreCase("null")) {
            CustomFieldValue leadStatus = new CustomFieldValue();
            leadStatus.setCustomFieldGroupAssignmentId(399L);
            leadStatus.setIntValue(Long.parseLong(leadStatusId));
            saveCustomFieldValue(leadStatus, contactId, leadOwnerUserId);
        }

        // handles saving 'Lead Source' custom field
        if (!lead.getLead_source().isBlank()) {
            String leadSourceId = checkIfCustomFieldDropdownValueExists(520, lead.getLead_source());
            CustomFieldValue leadSource = new CustomFieldValue();

            if (leadSourceId.equalsIgnoreCase("null")) {
                params.put("listOfValueId", 520);
                params.put("customFieldDropdownValue", lead.getLead_source());
                leadSourceId = sqlCache.updateReturningId("ricochetWebhook.insertCustomFieldDropdownValue", params, "id").toString();
            }

            leadSource.setCustomFieldGroupAssignmentId(395L);
            leadSource.setIntValue(Long.parseLong(leadSourceId));
            saveCustomFieldValue(leadSource, contactId, leadOwnerUserId);
        }

        // handles saving 'Lead Source Detail' custom field
        if (!lead.getLead_source_detail().isBlank()) {
            String leadSourceDetailId = checkIfCustomFieldDropdownValueExists(543, lead.getLead_source_detail());
            CustomFieldValue leadSourceDetail = new CustomFieldValue();

            if (leadSourceDetailId.equalsIgnoreCase("null")) {
                params.put("listOfValueId", 543);
                params.put("customFieldDropdownValue", lead.getLead_source_detail());
                leadSourceDetailId = sqlCache.updateReturningId("ricochetWebhook.insertCustomFieldDropdownValue", params, "id").toString();
            }

            leadSourceDetail.setCustomFieldGroupAssignmentId(396L);
            leadSourceDetail.setIntValue(Long.parseLong(leadSourceDetailId));
            saveCustomFieldValue(leadSourceDetail, contactId, leadOwnerUserId);
        }

        // handles saving 'Ricochet Lead ID' custom field
        CustomFieldValue ricochetLeadId = new CustomFieldValue();
        ricochetLeadId.setCustomFieldGroupAssignmentId(398L);
        ricochetLeadId.setTextValue(lead.getUniqueIdentifier().toString());
        saveCustomFieldValue(ricochetLeadId, contactId, leadOwnerUserId);

        // handles saving 'Hubspot ID' custom field
        CustomFieldValue hubspotId = new CustomFieldValue();
        hubspotId.setCustomFieldGroupAssignmentId(397L);

        if (lead.getHubspot_id() != null) {
            hubspotId.setTextValue(lead.getHubspot_id().toString());
        } else {
            hubspotId.setTextValue(null);
        }

        saveCustomFieldValue(hubspotId, contactId, leadOwnerUserId);
    }

    public void saveCustomFieldValue(CustomFieldValue cfv, Long contactId, Long leadOwnerUserId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("contactId", contactId);
        params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
        params.put("textValue", cfv.getTextValue());
        params.put("intValue", cfv.getIntValue());
        params.put("leadOwnerUserId", leadOwnerUserId);

        sqlCache.update("ricochetWebhook.upsertCustomFieldValue", params);
    }
}
