package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.company.blueraven.services.SolargrafProjectRequest;
import com.albatross.api.v1.company.blueraven.services.SolargrafProjectResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.util.HashMap;
import java.util.Map;

@Service
public class SolargrafService {

  @Value("${solargraf.api.token}")
  private String apiKey;

  @Value("${solargraf.api.url:https://api.solargraf.com}")
  private String apiUrl;

  private final RestTemplate restTemplate = new RestTemplate();
  // Removed unused ObjectMapper

  public SolargrafProjectResponse createProject(SolargrafProjectRequest request) {
    try {
      HttpHeaders headers = createHeaders();

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
      HttpHeaders headers = createHeaders();

      Map<String, Object> cloneData = new HashMap<>();
      cloneData.put("source_proposal_id", originalProposalId);
      cloneData.put("name", newProjectData.getName());
      cloneData.put("address", newProjectData.getAddress());

      HttpEntity<Map<String, Object>> entity = new HttpEntity<>(cloneData, headers);

      ResponseEntity<Map> response = restTemplate.postForEntity(
        apiUrl + "/proposals/clone",
        entity,
        Map.class
      );

      return processResponse(response, "Proposal cloned successfully", "Failed to clone proposal");

    } catch (Exception e) {
      return new SolargrafProjectResponse(null, false, "Error cloning proposal: " + e.getMessage());
    }
  }

  private HttpHeaders createHeaders() {
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    headers.setBearerAuth(apiKey);
    return headers;
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
