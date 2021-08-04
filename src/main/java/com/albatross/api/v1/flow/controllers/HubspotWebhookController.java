package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.HubspotContact;
import com.albatross.api.v1.flow.model.RicochetLead;
import com.albatross.api.v1.flow.services.HubspotWebhookService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/webhook/hubspot")
@Slf4j
public class HubspotWebhookController {
    @Autowired
    private HubspotWebhookService hubspotWebhookService;

    @ResponseStatus(HttpStatus.ACCEPTED)
    @PostMapping(value = "/contact")
    public void saveContact(@RequestBody HubspotContact contact) throws Exception {
        /*log.info(
            "HUBSPOT: Received new contact information from HubSpot. " +
                "hubspotId: {}, " +
                "First Name: {}, " +
                "Last Name: {}, " +
                "Phone1: {}, " +
                "Email: {}, " +
                "Zip: {}",
                contact.getVid(),
                contact.getProperties().getFirstname().getValue(),
                contact.getProperties().getLastname().getValue(),
                contact.getProperties().getPhone().getValue(),
                contact.getProperties().getEmail().getValue(),
                contact.getProperties().getZip().getValue()
        );*/

        log.info(
          "HUBSPOT: Received new contact information from HubSpot. {}" +
          contact.toString()
        );

        RicochetLead lead = new RicochetLead();
        lead.setHubspot_id(contact.getVid());
        lead.setStatus("New");
        lead.setLeadOwner(null);

        if (contact.getProperties().getLead_source() != null && !contact.getProperties().getLead_source().getValue().equals("")) {
            log.info("HUBSPOT: (Additional contact information from HubSpot) " +
                         "lead_source: {}", contact.getProperties().getLead_source().getValue());
            lead.setLead_source(contact.getProperties().getLead_source().getValue());
        } else {
            lead.setLead_source("Organic");
        }

        if (contact.getProperties().getLead_source_detail() != null && !contact.getProperties().getLead_source_detail().getValue().equals("")) {
            log.info("HUBSPOT: (Additional contact information from HubSpot) " +
                         "lead_source_detail: {}", contact.getProperties().getLead_source_detail().getValue());
            lead.setLead_source_detail(contact.getProperties().getLead_source_detail().getValue());
        } else {
            lead.setLead_source_detail("DigitalOrganic");
        }

        RicochetLead.Customer customer = new RicochetLead.Customer();
        customer.setFirstName(contact.getProperties().getFirstname().getValue());
        customer.setLastName(contact.getProperties().getLastname().getValue());
        customer.setPhone1(contact.getProperties().getPhone().getValue());
        customer.setEmail(contact.getProperties().getEmail().getValue());

        RicochetLead.Address address = new RicochetLead.Address();
        address.setZip(contact.getProperties().getZip().getValue());
        address.setAddress1(contact.getProperties().getAddress() != null ? contact.getProperties().getAddress().getValue() : "");
        address.setCity(contact.getProperties().getCity() != null ? contact.getProperties().getCity().getValue() : "");
        address.setState(contact.getProperties().getState() != null ? contact.getProperties().getState().getValue() : "");

        customer.setAddress(address);
        lead.setCustomer(customer);

        // handles saving lead information to database
        Long contactId = hubspotWebhookService.saveLead(lead);

        if (contactId != null) {
          lead.setContactId(contactId);
        }
    }
}
