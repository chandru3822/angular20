package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.RicochetLead;
//import com.albatross.api.v1.flow.services.RicochetWebhookService;
import lombok.extern.slf4j.Slf4j;
//import org.springframework.beans.factory.annotation.Autowired;
import org.apache.commons.codec.binary.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/webhook/ricochet")
@Slf4j
public class RicochetWebhookController {
    @Value(value = "${ricochet.apiKey}")
    private String apiKey;

//    @Autowired
//    private RicochetWebhookService ricochetWebhookService;

    @ResponseStatus(HttpStatus.ACCEPTED)
    @PostMapping(value = "/lead")
    public ResponseEntity saveLead(@RequestBody RicochetLead lead, @RequestHeader("Authorization") String authHeader) throws Exception {
        if (!StringUtils.equals(authHeader, apiKey))
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid authorization configured");

        log.info(
            "Received new contact information from Ricochet. " +
                "uniqueIdentifier: {}, " +
                "status: {}, " +
                "leadOwner: {}, " +
                "firstName: {}, " +
                "lastName: {}, " +
                "mobile: {}, " +
                "email: {}, " +
                "street1: {}, " +
                "city: {}, " +
                "zip: {}, " +
                "state: {}, " +
                "lead_source: {}, " +
                "lead_source_detail: {}, " +
                "hubspotId: {}",
                lead.getUniqueIdentifier() != null ? lead.getUniqueIdentifier() : "null",
                lead.getStatus() != null ? lead.getStatus() : "null",
                lead.getLeadOwner() != null ? lead.getLeadOwner() : "null",
                lead.getCustomer().getFirstName() != null ? lead.getCustomer().getFirstName() : "null",
                lead.getCustomer().getLastName() != null ? lead.getCustomer().getLastName() : "null",
                lead.getCustomer().getPhone1() != null ? lead.getCustomer().getPhone1() : "null",
                lead.getCustomer().getEmail() != null ? lead.getCustomer().getEmail() : "null",
                lead.getCustomer().getAddress().getAddress1() != null ? lead.getCustomer().getAddress().getAddress1() : "null",
                lead.getCustomer().getAddress().getCity() != null ? lead.getCustomer().getAddress().getCity() : "null",
                lead.getCustomer().getAddress().getZip() != null ? lead.getCustomer().getAddress().getZip() : "null",
                lead.getCustomer().getAddress().getState() != null ? lead.getCustomer().getAddress().getState() : "null",
                lead.getLead_source() != null ? lead.getLead_source() : "null",
                lead.getLead_source_detail() != null ? lead.getLead_source_detail() : "null",
                lead.getHubspotId() != null ? lead.getHubspotId() : "null"
        );

//        ricochetWebhookService.saveLead(lead);

        return ResponseEntity.status(HttpStatus.ACCEPTED).body("Just testing connection to Ricochet.");
    }
}
