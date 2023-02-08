package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.HubspotLead;
import com.albatross.api.v1.company.blueraven.services.queries.HubspotWebhookQuery;
import com.albatross.api.v1.flow.services.mapbox.MapboxApiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class HubspotWebhookService {
    private final MapboxApiService mapboxApiService;
    private final SqlCache sqlCache;
    private final ContactLeadService contactLeadService;

    public Long saveLead(HubspotLead lead) {
        log.debug("HUBSPOT: Saving new HubSpot contact information to database...");

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
            List<Double> coordinates = mapboxApiService.getLatLong(lead.getCustomer().getAddress().getAddress1(), lead.getCustomer().getAddress().getCity(), lead.getCustomer().getAddress().getState(), lead.getCustomer().getAddress().getZip());
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

        Long contactId = sqlCache.updateBySqlReturningId(HubspotWebhookQuery.saveLead, params, "id").longValue();

        // saves 'Lead Status', 'Lead Source', 'Lead Source Detail', and 'Hubspot ID'
        contactLeadService.processHubspotCustomFieldValues(lead, contactId, 2371412L);

        log.debug("HUBSPOT: New HubSpot contact information was successfully saved to database for Contact ID={} / Hubspot ID={}",  contactId , lead.getHubspot_id());
        return contactId;
    }
}
