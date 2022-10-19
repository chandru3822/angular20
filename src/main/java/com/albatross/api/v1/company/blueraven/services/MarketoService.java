package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.MarketoProject;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.Lists;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;;
import org.springframework.http.*;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.annotation.PostConstruct;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

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

    private final SqlCache sqlCache;

    private final ObjectMapper om;

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
                                           .timeout(Duration.ofSeconds(30))
                                           .onErrorMap(TimeoutException.class, e -> new HttpTimeoutException("Problems communicating with Marketo while AUTHENTICATING: " + e.getMessage()))
                                           .block();

        try {
            JSONObject authResponse = new JSONObject(res.getBody());
            accessToken = authResponse.getString("access_token");
        } catch (Exception e) {
            log.error("MARKETO: Unable to authenticate. err: " + e.getMessage());
        }
    }

    public JSONArray pushData(List<Map<String, Object>> leads) {

        Map<String, Object> body = new HashMap<>();
        body.put("input", leads);
        body.put("lookupField", "projectId");

        try {

            authenticate();

            //@TODO: This is blocking. If issues arise for this feature, might need to make async
            ResponseEntity<String> res = client.post()
                                                   .uri("/rest/v1/leads.json")
                                                   .header("Authorization", "Bearer " + accessToken)
                                                   .body(Mono.just(body), Map.class)
                                                   .retrieve()
                                                   .toEntity(String.class)
                                                   .timeout(Duration.ofSeconds(30))
                                                   .onErrorMap(TimeoutException.class, e -> new HttpTimeoutException("Problems communicating with Marketo while PUSHING data: " + e.getMessage()))
                                                   .block();

            JSONObject resultBody = new JSONObject(res.getBody());

            if (!resultBody.getBoolean("success")) {
                JSONObject error = resultBody.getJSONArray("errors").getJSONObject(0);
                if (error.getLong("code") == 602) {
                    // @TODO: Infinite retries might become an issue
                    // retry
                    pushData(leads);
                }

                throw new RuntimeException("Unable to push data: Marketo says something failed");
            }

            return resultBody.getJSONArray("result");
        } catch (Exception e) {
            throw new RuntimeException(String.format("MARKETO: Unable to push data: %s", e.getMessage()));
        }
    }

    public List<Long> getMarketoIdsByProjectId(List<Long> projectIds) {

        final String projectIdsCsv = projectIds.stream().map(String::valueOf).collect(Collectors.joining(","));

        try {
            authenticate();
            ResponseEntity<String> res = client.get()
                                               .uri(uriBuilder -> uriBuilder
                                                   .path("/rest/v1/leads.json")
                                                   .queryParam("fields", "id")
                                                   .queryParam("filterType", "projectId")
                                                   .queryParam("filterValues", projectIdsCsv)
                                                   .build()
                                               )
                                               .header("Authorization", "Bearer " + accessToken)
                                               .retrieve()
                                               .toEntity(String.class)
                                               .timeout(Duration.ofSeconds(30))
                                               .onErrorMap(TimeoutException.class, e -> new HttpTimeoutException("Problems communicating with Marketo while FETCHING data: " + e.getMessage()))
                                               .block();

            JSONObject rawResponse = new JSONObject(res.getBody());

            if (!rawResponse.getBoolean("success")) {
                JSONObject error = rawResponse.getJSONArray("errors").getJSONObject(0);
                if (error.getLong("code") == 602) {
                    // @TODO: Infinite retries might become an issue
                    // retry
                    getMarketoIdsByProjectId(projectIds);
                }

                throw new RuntimeException("Unable to push data: Marketo says something failed");
            }

            JSONArray result = rawResponse.getJSONArray("result");
            List<Long> marketoIds = new ArrayList<>();

            for(int i = 0; i < result.length(); i++) {
                JSONObject json = result.getJSONObject(i);
                if (json.has("id")) {
                    marketoIds.add(json.getLong("id"));
                }
            }

            return marketoIds;
        } catch (Exception e) {
            throw new RuntimeException(String.format("MARKETO: Unable to fetch IDs from Marketo: %s", e.getMessage()));
        }
    }

    public JSONArray removeFromMarekto(List<Long> marketoIds) {

        final String marketoIdsCsv = marketoIds.stream().map(String::valueOf).collect(Collectors.joining(","));

        authenticate();
        ResponseEntity<String> res = client.post()
                                           .uri(uriBuilder -> uriBuilder
                                               .path("/rest/v1/leads/delete.json")
                                               .queryParam("id", marketoIdsCsv)
                                               .build()
                                           )
                                           .header("Authorization", "Bearer " + accessToken)
                                           .contentType(MediaType.APPLICATION_JSON)
                                           .body(BodyInserters.empty())
                                           .retrieve()
                                           .toEntity(String.class)
                                           .timeout(Duration.ofSeconds(30))
                                           .onErrorMap(TimeoutException.class, e -> new HttpTimeoutException("Problems communicating with Marketo while REMOVING data: " + e.getMessage()))
                                           .block();

        JSONObject resultBody = new JSONObject(res.getBody());

        if (!resultBody.getBoolean("success")) {
            JSONObject error = resultBody.getJSONArray("errors").getJSONObject(0);
            if (error.getLong("code") == 602) {
                // @TODO: Infinite retries might become an issue
                // retry
                removeFromMarekto(marketoIds);
            }

            throw new RuntimeException("MARKETO: Unable remove IDs: Marketo says something failed");
        }

        return resultBody.getJSONArray("result");
    }

    public Map<String, Object> projectToLead(MarketoProject project) {
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
        lead.put("leadSource", project.getLeadSource());
        lead.put("leadStatus", project.getLeadStatus());
        return lead;
    }

    public String formatDateTime(Object rawDate) {
        if (rawDate == null) {
            return null;
        }

        try {
            LocalDateTime date = LocalDateTime.parse(rawDate.toString(), DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss[.n]"));
            return date + "+00:00";
        } catch (Exception e) {
            throw new RuntimeException("Unable to parse given datetime for Marketo");
        }
    }

    public MarketoProject getProject(Long projectId) {
        return sqlCache.get("marketo.getProject", Map.of("projectId", projectId), MarketoProject.class)
                       .orElse(null);
    }

    public void pushDailyUpdatedProjects() {

        // upsert projects
        List<Long> projectIds = sqlCache.query("marketo.projectIdsPreviousDayStatusChange", null, new SingleColumnRowMapper<>(Long.class));
        List<MarketoProject> projects = sqlCache.query("marketo.getProjects", Map.of("projectIds", projectIds), MarketoProject.class);
        List<Map<String, Object>> leads = new ArrayList<>();

        projects.forEach(p -> {
            if (!p.getDoNotSolicitReview()) {
                Map<String, Object> lead = projectToLead(p);

                lead.put("projectStatus", p.getProjectStatusType());

                if (p.getCompanyProjectStatusTypeId() == 64) {
                    lead.put("finalDesignApprovedDate", p.getFinalDesignApprovedDate());
                } else if (p.getCompanyProjectStatusTypeId() == 66) {
                    lead.put("installationStartTime", formatDateTime(p.getInstallationStartTime()));
                }

                leads.add(lead);
            }
        });

        List<List<Map<String, Object>>> sizedLeads = Lists.partition(leads, 300);
        sizedLeads.forEach(l -> {
            try {
                pushData(l);
            } catch (Exception e) {
                final List<String> errorIds = l.stream().map(lead -> lead.get("projectId").toString()).toList();
                log.error(String.format("MARKETO: Error in cron while PUSHING data for projects: %s", errorIds));
            }
        });

        // remove projects
        List<Long> deleteProjectIds = sqlCache.query("marketo.projectsToRemove", null, new SingleColumnRowMapper<>(Long.class));
        List<List<Long>> sizedDeleteProjectIds = Lists.partition(deleteProjectIds, 300);
        List<Long> marketoIds = new ArrayList<>();
        sizedDeleteProjectIds.forEach(l -> {
            marketoIds.addAll(getMarketoIdsByProjectId(l));
        });

        List<List<Long>> sizedRemoveIds = Lists.partition(marketoIds, 300);
        sizedRemoveIds.forEach(l -> {
            try {
                removeFromMarekto(l);
            } catch (Exception e) {
                log.error(String.format("MARKETO: Error in cron while REMOVING data for projects: %s", l));
            }
        });

        // push reactivated projects
        List<Long> reactivatedProjectIds = sqlCache.query("marketo.projectsToReactivate", null, new SingleColumnRowMapper<>(Long.class));
        List<MarketoProject> reactivatedProjects = sqlCache.query("marketo.getProjects", Map.of("projectIds", reactivatedProjectIds), MarketoProject.class);
        List<Map<String, Object>> reactivatedLeads = new ArrayList<>();

        reactivatedProjects.forEach(p -> {
            if (!p.getDoNotSolicitReview()) {
                Map<String, Object> lead = projectToLead(p);

                //fill all marketo fields with current values
                lead.put("projectStatus", p.getProjectStatusType());
                lead.put("closerAppointmentStartTime", formatDateTime(p.getCloserAppointmentStartTime()));
                lead.put("installationStartTime", formatDateTime(p.getInstallationStartTime()));
                lead.put("substantialCompletionDate", p.getSubstantialCompletionDate());
                lead.put("inspectionStartTime", formatDateTime(p.getInspectionStartTime()));
                lead.put("inspectionPassedDate", p.getInspectionPassedDate());
                lead.put("energizedDate", p.getEnergizedDate());
                lead.put("finalDesignApprovedDate", p.getFinalDesignApprovedDate());

                reactivatedLeads.add(lead);
            }
        });

        List<List<Map<String, Object>>> sizedReactivatedLeads = Lists.partition(reactivatedLeads, 300);
        sizedReactivatedLeads.forEach(l -> {
            try {
                pushData(l);
            } catch (Exception e) {
                final List<String> errorIds = l.stream().map(lead -> lead.get("projectId").toString()).toList();
                log.error(String.format("MARKETO: Error in cron while REACTIVATING data for projects: %s", errorIds));
            }
        });
    }
}
