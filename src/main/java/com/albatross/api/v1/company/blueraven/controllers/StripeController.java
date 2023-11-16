package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.enums.StripeCompany;
import com.albatross.api.v1.company.blueraven.services.StripeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;


@RestController
@RequestMapping(value = "/api/v1/company/blueraven/stripe")
@Slf4j
public class StripeController {
    @Autowired
    private StripeService stripeService;

    //since this is only accessed via actions I am going to turn off this endpoint for added security
//    @PostMapping(value = "/charge/{projectId}/event/{ppsEventId}", produces = MediaType.APPLICATION_JSON_VALUE)
//    public ResponseEntity<String> chargeProject(@PathVariable Long projectId,
//                                                @PathVariable Long ppsEventId) {
//        try {
//            String url = stripeService.chargeProject(projectId, ppsEventId);
//            if (url != null) {
//                return ResponseEntity.ok(url);
//            }
//            else {
//                return ResponseEntity.badRequest().body("Failed charge");
//            }
//
//        } catch (Exception e) {
//            return ResponseEntity.badRequest().body("Failed charge");
//        }
//
//    }

    @PostMapping(value = "/setPaymentId", produces = MediaType.APPLICATION_JSON_VALUE)
    public void setStripePaymentId(@RequestParam String stripeSessionId,
                                   @RequestParam Long projectId) {
        stripeService.setStripePaymentId(stripeSessionId, projectId);
    }

    @PostMapping(value = "/createCheckoutSession/breeze", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, String> createCheckoutSession(@RequestParam(required = false) String customerEmail) {
        return stripeService.createEmbeddedCheckoutSession(StripeCompany.BREEZE.keyPrefix, customerEmail);
    }

}
