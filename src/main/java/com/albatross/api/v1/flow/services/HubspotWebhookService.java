package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.ContactLeadService;
import com.albatross.api.v1.flow.model.RicochetLead;
import com.albatross.api.v1.flow.services.mapbox.MapboxApiService;
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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.StringJoiner;

import static java.nio.charset.StandardCharsets.UTF_8;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class HubspotWebhookService {
    private final RequestConfig requestConfig = RequestConfig.custom().setCookieSpec(CookieSpecs.STANDARD).build();
    private final CloseableHttpClient client = HttpClients.custom().setDefaultRequestConfig(requestConfig).build();
    private final MapboxApiService mapboxApiService;

    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private ContactLeadService contactLeadService;

    @Value(value = "${ricochet.api.token}")
    private String token;

    public void postLeadToRicochet(RicochetLead lead) throws Exception {
        try {
            String RICOCHET_URL = "https://leads.ricochet.me/api/v1/lead/create/"+lead.getLead_source_detail()+"?token=" + token;
            HttpPost req = new HttpPost(RICOCHET_URL);

            JSONObject contact = new JSONObject();
            contact.put("hubspot_id", lead.getHubspot_id());

            if (lead.getContactId() != null) {
              contact.put("contactId", lead.getContactId());
            }

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
            address.put("State", lead.getCustomer().getAddress().getState());
            address.put("City", lead.getCustomer().getAddress().getCity());
            address.put("Address1", lead.getCustomer().getAddress().getAddress1());

            customer.put("address", address);
            contact.put("customer", customer);

            req.setEntity(new StringEntity(contact.toString()));
            req.setHeader("Accept", "application/json");
            req.setHeader("Content-type", "application/json");

            log.info("HUBSPOT: Preview of contact information that will be sent: {}", contact.toString());
            log.info("HUBSPOT: Sending HTTP POST request to Ricochet with HubSpot contact information...");

            try (CloseableHttpResponse resp = client.execute(req)) {
                if (resp.getStatusLine().getStatusCode() != HttpStatus.SC_OK) {
                    String msg = "HUBSPOT: Received unexpected response code from Ricochet post: " + resp.getStatusLine().getStatusCode();
                    log.error(msg);

                    try {
                        log.error(
                            "HUBSPOT: Response body from Ricochet post: {}",
                            IOUtils.toString(resp.getEntity().getContent(), UTF_8)
                        );
                    } catch (IOException ignored) {}

                    throw new Exception(msg);
                }
            }
            log.info("HUBSPOT: HTTP POST request made to Ricochet with HubSpot contact information was successful.");
        } catch (Exception e) {
            String msg = "HUBSPOT: Failed to post HubSpot contact information to Ricochet.";
            log.error(msg, e);
            throw new Exception(msg, e);
        }
    }

    public Long saveLead(RicochetLead lead) {
        log.info("HUBSPOT: Saving new HubSpot contact information to database...");

        HashMap<String, Object> params = new HashMap<>();
        params.put("firstName", lead.getCustomer().getFirstName());
        params.put("lastName", lead.getCustomer().getLastName());
        params.put("phoneNumber", lead.getCustomer().getPhone1());
        params.put("postalCode", lead.getCustomer().getAddress().getZip());
        params.put("street1", lead.getCustomer().getAddress().getAddress1());
        params.put("city", lead.getCustomer().getAddress().getCity());
        params.put("email", lead.getCustomer().getEmail());

        Double latitude = null, longitude = null;
        //even if the state value is null, try to get a valid lat/long if there is at least an address and a city
        if(null != lead.getCustomer() && null != lead.getCustomer().getAddress()) {
          try {
            List<Double> coordinates = mapboxApiService.getLatLong(stringifyAddress(lead.getCustomer().getAddress().getAddress1(), lead.getCustomer().getAddress().getCity(), lead.getCustomer().getAddress().getState(), lead.getCustomer().getAddress().getZip()));
            if (!coordinates.isEmpty() && null != coordinates.get(0) && null != coordinates.get(1)) {
              //1 = lat, 0 = long
              latitude = coordinates.get(1);
              longitude = coordinates.get(0);
            }
          } catch (Exception ex) {
            log.error("CONTACT: Exception when attempting to get geo location.");
          }
        }

      //these will just insert as null unless a valid geo location was found from above
      params.put("latitude", latitude);
      params.put("longitude", longitude);

        Long contactId = sqlCache.updateReturningId("hubspotWebhook.saveLead", params, "id").longValue();

        // saves 'Lead Status', 'Lead Source', 'Lead Source Detail', and 'Hubspot ID'
        contactLeadService.processHubspotCustomFieldValues(lead, contactId, 2371412L);

        log.info("HUBSPOT: New HubSpot contact information was successfully saved to database for Contact ID " + contactId + " / Hubspot ID " + lead.getHubspot_id());
        return contactId;
    }

    public String stringifyAddress(String street1, String city, String state, String postalCode) {
      StringJoiner sj = new StringJoiner(", ");
      sj.add(street1);
      sj.add(city);
      sj.add(state + " " + postalCode);

      return sj.toString();
    }
}
