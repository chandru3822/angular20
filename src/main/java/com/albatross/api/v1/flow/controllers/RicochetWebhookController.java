package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.RicochetLead;
//import com.albatross.api.v1.flow.services.RicochetWebhookService;
import lombok.extern.slf4j.Slf4j;
//import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/webhook/ricochet")
@Slf4j
public class RicochetWebhookController {
//    @Autowired
//    private RicochetWebhookService ricochetWebhookService;

    @ResponseStatus(HttpStatus.ACCEPTED)
    @PostMapping(value = "/lead")
    public void saveLead(@RequestBody RicochetLead lead) throws Exception {
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
                "hubspotId: {}, ",
                lead.getUniqueIdentifier(),
                lead.getStatus(),
                lead.getLeadOwner(),
                lead.getCustomer().getFirstName(),
                lead.getCustomer().getLastName(),
                lead.getCustomer().getPhone1(),
                lead.getCustomer().getEmail(),
                lead.getCustomer().getAddress().getAddress1(),
                lead.getCustomer().getAddress().getCity(),
                lead.getCustomer().getAddress().getZip(),
                lead.getCustomer().getAddress().getState(),
                lead.getLead_source(),
                lead.getLead_source_detail(),
                lead.getHubspotId()
        );

//        ricochetWebhookService.saveLead(lead);
    }
}
