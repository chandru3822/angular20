package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.RicochetLead;
import com.albatross.api.v1.flow.services.RicochetWebhookService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.apache.commons.codec.binary.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static org.apache.commons.lang3.StringUtils.isBlank;

@RestController
@RequestMapping(value = "/webhook/ricochet")
@Slf4j
public class RicochetWebhookController {
    @Value(value = "${ricochet.api.key}")
    private String apiKey;

    @Autowired
    private RicochetWebhookService ricochetWebhookService;

    @ResponseStatus(HttpStatus.ACCEPTED)
    @PostMapping(value = "/lead")
    public ResponseEntity saveLead(@RequestBody RicochetLead lead, @RequestHeader("Authorization") String authHeader) throws Exception {
        String msg;

        if (!StringUtils.equals(authHeader, (apiKey))) {
            msg = "Invalid authorization configured";
            log.error(msg);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Error: " + msg);
        }

        if (lead.getUniqueIdentifier() == null) {
            msg = "Ricochet Lead ID is missing";
            log.error(msg);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
        }

        if (lead.getCustomer().getLastName().isBlank()) {
            msg = "Last name cannot be blank";
            log.error(msg);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
        }

        if (!lead.getCustomer().getAddress().getZip().isBlank() && lead.getCustomer().getAddress().getZip().length() > 10) {
            msg = "Character limit exceeded for provided Zip \"" + lead.getCustomer().getAddress().getZip() + "\". The maximum number of characters allowed is 10.";
            log.error(msg);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Error: " + msg);
        }

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
                "hubspot_id: {}",
                lead.getUniqueIdentifier() != null ? lead.getUniqueIdentifier() : "null",
                !isBlank(lead.getStatus()) ? lead.getStatus() : "null",
                !isBlank(lead.getLeadOwner()) ? lead.getLeadOwner() : "null",
                !isBlank(lead.getCustomer().getFirstName()) ? lead.getCustomer().getFirstName() : "null",
                !isBlank(lead.getCustomer().getLastName()) ? lead.getCustomer().getLastName() : "null",
                !isBlank(lead.getCustomer().getPhone1()) ? lead.getCustomer().getPhone1() : "null",
                !isBlank(lead.getCustomer().getEmail()) ? lead.getCustomer().getEmail() : "null",
                !isBlank(lead.getCustomer().getAddress().getAddress1()) ? lead.getCustomer().getAddress().getAddress1() : "null",
                !isBlank(lead.getCustomer().getAddress().getCity()) ? lead.getCustomer().getAddress().getCity() : "null",
                !isBlank(lead.getCustomer().getAddress().getZip()) ? lead.getCustomer().getAddress().getZip() : "null",
                !isBlank(lead.getCustomer().getAddress().getState()) ? lead.getCustomer().getAddress().getState() : "null",
                !isBlank(lead.getLead_source()) ? lead.getLead_source() : "null",
                !isBlank(lead.getLead_source_detail()) ? lead.getLead_source_detail() : "null",
                lead.getHubspot_id() != null ? lead.getHubspot_id() : "null"
        );

        return ricochetWebhookService.saveLead(lead);
    }
}
