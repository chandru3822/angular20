package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.flow.model.project.Project;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.annotation.PostConstruct;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class MarketoService {

    private String accessToken;

    private WebClient client;

    @Value("${marketo.host:}")
    private String host;

    @Value("${marketo.clientId:}")
    private String clientId;

    @Value("${marketo.secret:}")
    private String secret;

    @PostConstruct
    public void init() {
        client = WebClient.create(host);
    }

    /*
      @TODO: We call this function before every other Marketo API call to ensure auth token is valid. If an issues iss caused by this,
             we can check time since last token refresh (Marketo tokens are good for 5 min) and only refresh when expiration is close
     */
    private void authenticate() {
        final String url = String.format("%s/identity/oauth/token?grant_type=client_credentials&client_id=%s&client_secret=%s", host, clientId, secret);
        WebClient client = WebClient.create();
        //@TODO: This is blocking. If issues arise for this feature, might need to make async
        ResponseEntity<String> res = client.get()
                                           .uri(url)
                                           .retrieve()
                                           .toEntity(String.class)
                                           .block();

        try {
            JSONObject authResponse = new JSONObject(res.getBody());
            accessToken = authResponse.getString("access_token");
        } catch (Exception e) {
            log.error("MARKETO: Unable to authenticate. err: " + e.getMessage());
        }
    }

    public String pushData(Map<String, Object> lead) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("input", List.of(lead));
            body.put("lookupField", "projectId");

            authenticate();

            //@TODO: This is blocking. If issues arise for this feature, might need to make async
            ResponseEntity<String> res = client.post()
                                                   .uri("/rest/v1/leads.json")
                                                   .header("Authorization", "Bearer " + accessToken)
                                                   .body(Mono.just(body), Map.class)
                                                   .retrieve()
                                                   .toEntity(String.class)
                                                   .block();

            JSONObject resultBody = new JSONObject(res.getBody());
            JSONArray results = resultBody.getJSONArray("result");
            JSONObject status = results.getJSONObject(0);
            return status.getString("status");
        } catch (Exception e) {
            throw new RuntimeException(String.format("MARKETO: Unable to push data: %s", e.getMessage()));
        }
    }

//    @Async
//    public Future<Long> getContactIdByProjectId(Long projectId) {
//        authenticate();
//        ResponseEntity<String> res = client.get()
//                                           .uri(uriBuilder -> uriBuilder
//                                               .path("/rest/v1/leads.json")
//                                               .queryParam("fields", "id,projectId,lastName,firstName,email,updatedAt,createdAt")
//                                               .queryParam("filterType", "projectId")
//                                               .queryParam("batchSize", 1)
//                                               .queryParam("filterValues", projectId)
//                                               .build()
//                                           )
//                                           .header("Authorization", "Bearer " + accessToken)
//                                           .retrieve()
//                                           .toEntity(String.class)
//                                           .block();
//
//        JSONObject rawResponse = new JSONObject(res.getBody());
//        JSONObject json = (JSONObject) rawResponse.getJSONArray("result").get(0);
//
//        return new AsyncResult<>(json.getLong("contactId"));
//    }

    public Map<String, Object> projectToLead(Project project) {
        Map<String, Object> lead = new HashMap<>();
        lead.put("projectId", project.getId());
        lead.put("firstName", project.getFirstName());
        lead.put("lastName", project.getLastName());
        lead.put("address", project.getStreet1());
        lead.put("state", project.getState());
        lead.put("country", project.getCountry());
        lead.put("postalCode", project.getPostalCode());
        lead.put("phone", project.getPhone());
        lead.put("email", project.getEmail());
        return lead;
    }

    public String formatDateTime(Object rawDate) {
        try {
            LocalDateTime date = LocalDateTime.parse(rawDate.toString(), DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss[.n]"));
            return date + "+00:00";
        } catch (Exception e) {
            throw new RuntimeException("Unable to parse given datetime for Marketo");
        }
    }
}
