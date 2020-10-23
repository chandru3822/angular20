package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.flow.model.RicochetLead;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.apache.http.HttpStatus;
import org.apache.http.client.config.CookieSpecs;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;

import static java.nio.charset.StandardCharsets.UTF_8;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class HubspotWebhookService {
    private final RequestConfig requestConfig = RequestConfig.custom().setCookieSpec(CookieSpecs.STANDARD).build();
    private final CloseableHttpClient client = HttpClients.custom().setDefaultRequestConfig(requestConfig).build();

    public void postLeadToRicochet(RicochetLead lead) throws Exception {
        try {
            String RICOCHET_URL = "https://leads.ricochet.me/api/v1/lead/create/hubspot?token=***REMOVED***";
            HttpPost req = new HttpPost(RICOCHET_URL);

            JSONObject contact = new JSONObject();
            contact.put("hubspotId", lead.getHubspotId());
            contact.put("lead_source", lead.getLead_source());
            contact.put("status", lead.getStatus());
            contact.put("leadOwner", lead.getLeadOwner());
            contact.put("lead_source_detail", lead.getLead_source_detail());

            JSONObject customer = new JSONObject();
            customer.put("First Name", lead.getCustomer().getFirstName());
            customer.put("Last Name", lead.getCustomer().getLastName());
            customer.put("Phone1", lead.getCustomer().getPhone1());
            customer.put("Email", lead.getCustomer().getEmail());

            JSONObject address = new JSONObject();
            address.put("Zip", lead.getCustomer().getAddress().getZip());

            customer.put("address", address);
            contact.put("customer", customer);

            req.setEntity(new StringEntity(contact.toString()));
            req.setHeader("Accept", "application/json");
            req.setHeader("Content-type", "application/json");

            log.info("Preview of lead information that will be sent: {}", contact.toString());
            log.info("Sending HTTP POST request to Ricochet with HubSpot contact / lead information...");

            try (CloseableHttpResponse resp = client.execute(req)) {
                if (resp.getStatusLine().getStatusCode() != HttpStatus.SC_OK) {
                    String msg = "Received unexpected response code from Ricochet post: " + resp.getStatusLine().getStatusCode();
                    log.error(msg);

                    try {
                        log.error(
                            "Response body from Ricochet post: {}",
                            IOUtils.toString(resp.getEntity().getContent(), UTF_8)
                        );
                    } catch (IOException ignored) {}

                    throw new Exception(msg);
                }
            }
            log.info("HTTP POST request made to Ricochet with HubSpot contact / lead information was successful.");
        } catch (Exception e) {
            String msg = "Failed to post HubSpot contact / lead information to Ricochet.";
            log.error(msg, e);
            throw new Exception(msg, e);
        }
    }
}
