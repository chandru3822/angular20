package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.project.Project;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.Future;

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

    private final ObjectMapper om;

    private final SqlCache sqlCache;

    @PostConstruct
    public void init() {
        client = WebClient.create(host);
    }

    private void authenticate() {
        final String url = String.format("%s/identity/oauth/token?grant_type=client_credentials&client_id=%s&client_secret=%s", host, clientId, secret);
        WebClient client = WebClient.create();
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

    @Async
    public Future<Void> pushData(Map<String, Object> lead) {
        Map<String, Object> body = new HashMap<>();
        body.put("input", List.of(lead));
        body.put("lookupField", "projectId");

        authenticate();
        ResponseEntity<String> res = client.post()
            .uri("/rest/v1/leads.json")
            .header("Authorization", "Bearer " + accessToken)
            .body(Mono.just(body), Map.class)
            .retrieve()
            .toEntity(String.class)
            .block();

        return new AsyncResult<>(null);
    }

    @Async
    public Future<Long> getContactIdByProjectId(Long projectId) {
        authenticate();
        ResponseEntity<String> res = client.get()
                                           .uri(uriBuilder -> uriBuilder
                                               .path("/rest/v1/leads.json")
                                               .queryParam("fields", "id,projectId,lastName,firstName,email,updatedAt,createdAt")
                                               .queryParam("filterType", "projectId")
                                               .queryParam("batchSize", 1)
                                               .queryParam("filterValues", projectId)
                                               .build()
                                           )
                                           .header("Authorization", "Bearer " + accessToken)
                                           .retrieve()
                                           .toEntity(String.class)
                                           .block();

        JSONObject rawResponse = new JSONObject(res.getBody());
        JSONObject json = (JSONObject) rawResponse.getJSONArray("result").get(0);

        return new AsyncResult<>(json.getLong("contactId"));
    }

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
}
