package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.ContactLeadService;
import com.albatross.api.v1.flow.model.HubspotLead;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class HubspotWebhookService {
    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private ContactLeadService contactLeadService;

    public Long saveLead(HubspotLead lead) {
        log.info("HUBSPOT: Saving new HubSpot contact information to database...");

        HashMap<String, Object> params = new HashMap<>();
        params.put("firstName", lead.getCustomer().getFirstName());
        params.put("lastName", lead.getCustomer().getLastName());
        params.put("phoneNumber", lead.getCustomer().getPhone1());
        params.put("postalCode", lead.getCustomer().getAddress().getZip());
        params.put("email", lead.getCustomer().getEmail());

        Long contactId = sqlCache.updateReturningId("hubspotWebhook.saveLead", params, "id").longValue();

        // saves 'Lead Status', 'Lead Source', 'Lead Source Detail', and 'Hubspot ID'
        contactLeadService.processCustomFieldValues(lead, contactId, 2371412L);

        log.info("HUBSPOT: New HubSpot contact information was successfully saved to database for Contact ID " + contactId + " / Hubspot ID " + lead.getHubspot_id());
        return contactId;
    }
}
