package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.company.blueraven.services.SolargrafProjectRequest;
import com.albatross.api.v1.company.blueraven.services.SolargrafProjectResponse;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
public class SolargrafService {

  private HttpHeaders headers;
  @PostConstruct
  public void init() {
    headers = new HttpHeaders();
    headers.set("Authorization", apiKey);
    headers.setContentType(MediaType.APPLICATION_JSON);
  }

  @Value("${solargraf.api.token}")
  private String apiKey;

  @Value("${solargraf.api.url:https://public-api.solargraf.com}")
  private String apiUrl;

  private final RestTemplate restTemplate = new RestTemplate();
  // Removed unused ObjectMapper

  public SolargrafProjectResponse createProject(SolargrafProjectRequest request) {
    try {
      Map<String, Object> projectData = new HashMap<>();
      projectData.put("name", request.getName());
      projectData.put("address", request.getAddress());

      HttpEntity<Map<String, Object>> entity = new HttpEntity<>(projectData, headers);

      ResponseEntity<Map> response = restTemplate.postForEntity(
        apiUrl + "/projects",
        entity,
        Map.class
      );

      return processResponse(response, "Project created successfully", "Failed to create project");

    } catch (Exception e) {
      return new SolargrafProjectResponse(null, false, "Error: " + e.getMessage());
    }
  }



  public SolargrafProjectResponse cloneProposal(String originalProposalId, SolargrafProjectRequest newProjectData) {
    try {
      Map<String, Object> attributes = new HashMap<>();
      attributes.put("name", newProjectData.getName());

      Map<String, Object> data = new HashMap<>();
      data.put("attributes", attributes);

      Map<String, Object> requestBody = new HashMap<>();
      requestBody.put("data", data);

      String apiEndpoint = String.format("%s/v1/projects/%d/proposals/%s/clone",
        this.apiUrl, newProjectData.getProjectId(), originalProposalId);

      HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

      ResponseEntity<Map> response = restTemplate.postForEntity(
        apiEndpoint,
        entity,
        Map.class
      );

      log.debug("Clone proposal response: {}", response);

      return processResponse(response, "Proposal cloned successfully", "Failed to clone proposal");

    } catch (Exception e) {
      return new SolargrafProjectResponse(null, false, "Error cloning proposal: " + e.getMessage());
    }
  }

  private SolargrafProjectResponse processResponse(ResponseEntity<Map> response, String successMessage, String failureMessage) {
    if (response.getStatusCode() == HttpStatus.CREATED) {
      Map<String, Object> responseBody = response.getBody();
      String projectUrl = (String) responseBody.get("project_url");
      return new SolargrafProjectResponse(projectUrl, true, successMessage);
    } else {
      return new SolargrafProjectResponse(null, false, failureMessage);
    }
  }
}
