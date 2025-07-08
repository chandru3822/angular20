package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.company.blueraven.services.SolargrafProjectRequest;
import com.albatross.api.v1.company.blueraven.services.SolargrafProjectResponse;
import com.albatross.api.utils.SqlCache;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
public class SolargrafService {

  @Value("${solargraf.api.token}")
  private String apiKey;

  @Value("${solargraf.api.host:'https://public-api.solargraf.com'}")
  private String apiUrl;

  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private JdbcTemplate jdbcTemplate;

  private HttpHeaders getHeaders() {
    HttpHeaders headers = new HttpHeaders();
    headers.set("Authorization", apiKey); // Do not prepend 'Api-Key '
    headers.setContentType(MediaType.APPLICATION_JSON);
    return headers;
  }

  private final RestTemplate restTemplate = new RestTemplate();
  // Removed unused ObjectMapper

  public SolargrafProjectResponse createProject(SolargrafProjectRequest request) {
    try {
      log.info("Creating Solargraf project with API key: {}",
        apiKey != null && apiKey.length() > 16 ?
          apiKey.substring(0, 8) + "..." + apiKey.substring(apiKey.length() - 8) :
          "****");
      log.info("Solargraf API host: {}", apiUrl);
      Map<String, Object> projectData = new HashMap<>();
      projectData.put("name", request.getName());
      projectData.put("address", request.getAddress());

      HttpEntity<Map<String, Object>> entity = new HttpEntity<>(projectData, getHeaders());

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
      // Create JSON structure using JSONObject
      JSONObject attributes = new JSONObject();
      attributes.put("name", newProjectData.getName());

      JSONObject data = new JSONObject();
      data.put("attributes", attributes);

      JSONObject requestBody = new JSONObject();
      requestBody.put("data", data);

      String apiPath = String.format("/v1/projects/%d/proposals/%s/clone", newProjectData.getProjectId(), originalProposalId);

      // Ensure apiUrl has proper protocol
      String baseUrl = this.apiUrl;
      if (!baseUrl.startsWith("http://") && !baseUrl.startsWith("https://")) {
        baseUrl = "https://" + baseUrl;
      }

      String fullUrl = baseUrl + apiPath;
      HttpEntity<String> entity = new HttpEntity<>(requestBody.toString(), getHeaders());

      try {
        ResponseEntity<Map> response = restTemplate.postForEntity(
          fullUrl,
          entity,
          Map.class
        );
        log.debug("Clone proposal response: {}", response);
        return processResponse(response, "Proposal cloned successfully", "Failed to clone proposal");
      } catch (org.springframework.web.client.HttpClientErrorException e) {
        log.error("Solargraf API returned error: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
        return new SolargrafProjectResponse(null, false, "Solargraf API error: " + e.getResponseBodyAsString());
      }
    } catch (Exception e) {
      return new SolargrafProjectResponse(null, false, "Error cloning proposal: " + e.getMessage());
    }
  }

  private SolargrafProjectResponse processResponse(ResponseEntity<Map> response, String successMessage, String failureMessage) {
    if (response.getStatusCode() == HttpStatus.CREATED || response.getStatusCode() == HttpStatus.OK) {
      Map<String, Object> responseBody = response.getBody();
      String projectUrl = null;
      String projectId = null;
      String proposalId = null;
      if (responseBody != null && responseBody.get("data") instanceof Map) {
        Map<String, Object> data = (Map<String, Object>) responseBody.get("data");
        Object proposalIdObj = data.get("id");
        Object attributesObj = data.get("attributes");
        if (attributesObj instanceof Map) {
          Object projectIdObj = ((Map<String, Object>) attributesObj).get("projectId");
          if (projectIdObj != null) {
            projectId = projectIdObj.toString();
          }
        }
        if (proposalIdObj != null) {
          proposalId = proposalIdObj.toString();
        }
        if (proposalId != null && projectId != null) {
          projectUrl = String.format("https://app.solargraf.com/projects/%s/proposals/%s/", projectId, proposalId);
        }
      }
      return new SolargrafProjectResponse(projectUrl, true, successMessage, projectId, proposalId);
    } else {
      Map<String, Object> responseBody = response.getBody();
      String errorMsg = failureMessage;
      if (responseBody != null && responseBody.get("message") != null) {
        errorMsg = responseBody.get("message").toString();
      } else if (responseBody != null && responseBody.get("error") != null) {
        errorMsg = responseBody.get("error").toString();
      }
      return new SolargrafProjectResponse(null, false, errorMsg);
    }
  }

  // Custom field group assignment ID for Solargraf Design ID
  private static final long SOLARGRAF_CFGA_ID = 31560L;

  // --- 1. Retrieve Solargraf Design ID from custom field ---
  public String getSolargrafDesignIdForProject(Long projectId) {
    String sql = "select ppscfv.text_value from flow.project_process_step_custom_field_value ppscfv " +
            "inner join flow.project_process_step pps on pps.id = ppscfv.project_process_step_id " +
            "where ppscfv.custom_field_group_assignment_id = ? and pps.project_id = ? and pps.main is true limit 1";
    try {
      List<String> results = jdbcTemplate.query(sql, new Object[]{SOLARGRAF_CFGA_ID, projectId}, (rs, rowNum) -> rs.getString("text_value"));
      return results.isEmpty() ? null : results.get(0);
    } catch (Exception e) {
      log.error("Error fetching Solargraf Design ID custom field", e);
      return null;
    }
  }

  // --- 2. Validate and parse the custom field value ---
  public static class SolargrafIdInfo {
    public String projectId;
    public String proposalId;
    public String url;
  }

  public SolargrafIdInfo parseSolargrafCustomFieldValue(String value) {
    SolargrafIdInfo info = new SolargrafIdInfo();
    if (value == null) return info;
    value = value.trim();
    // Check for URL
    if (value.startsWith("http")) {
      info.url = value;
      // Try to extract project and proposal IDs from URL
      Pattern urlPattern = Pattern.compile("projects/(\\d+)/proposals/([^/]+)");
      Matcher matcher = urlPattern.matcher(value);
      if (matcher.find()) {
        info.projectId = matcher.group(1);
        info.proposalId = matcher.group(2);
      }
      return info;
    }
    // Check for numeric (project ID)
    if (value.matches("^\\d+$")) {
      info.projectId = value;
      return info;
    }
    // Check for UUID (proposal/design ID)
    if (value.matches("^[a-fA-F0-9\\-]{36}$")) {
      info.proposalId = value;
      return info;
    }
    // Fallback: try to split if both present
    if (value.contains(":")) {
      String[] parts = value.split(":");
      if (parts.length == 2) {
        info.projectId = parts[0];
        info.proposalId = parts[1];
      }
    }
    return info;
  }

  // --- 3. Fetch proposals from Solargraf by project ID ---
  public List<Map<String, Object>> getProposalsFromSolargrafProject(String projectId) {
    try {
      String url = apiUrl + "/v1/projects/" + projectId + "/proposals";
      ResponseEntity<List> response = restTemplate.exchange(
        url,
        HttpMethod.GET,
        new HttpEntity<>(getHeaders()),
        List.class
      );
      return response.getBody();
    } catch (Exception e) {
      log.error("Error fetching proposals from Solargraf for project {}", projectId, e);
      return null;
    }
  }

  // --- 4. Main logic to get correct proposal/project IDs for cloning ---
  public SolargrafProjectResponse cloneProposalFromCustomField(Long projectId, SolargrafProjectRequest newProjectData) {
    try {
      String customFieldValue = getSolargrafDesignIdForProject(projectId);
      if (!StringUtils.hasText(customFieldValue)) {
        return new SolargrafProjectResponse(null, false, "No Solargraf Design ID found for project");
      }
      SolargrafIdInfo idInfo = parseSolargrafCustomFieldValue(customFieldValue);
      String solargrafProjectId = idInfo.projectId;
      String solargrafProposalId = idInfo.proposalId;
      // If only proposal ID, try to find project ID by listing all proposals
      if (solargrafProposalId != null && solargrafProjectId == null) {
        List<Map<String, Object>> proposals = getProposalsFromSolargrafProject(projectId.toString());
        if (proposals != null) {
          for (Map<String, Object> proposal : proposals) {
            if (proposal.get("id") != null && proposal.get("id").toString().equals(solargrafProposalId)) {
              solargrafProjectId = projectId.toString();
              break;
            }
          }
        }
      }
      if (solargrafProjectId == null || solargrafProposalId == null) {
        return new SolargrafProjectResponse(null, false, "Could not determine both Solargraf project and proposal IDs");
      }
      // --- Fetch publicId and installerWebQuoteUrl from Solargraf project ---
      String publicId = null;
      String installerWebQuoteUrl = null;
      try {
        String projectInfoUrl = apiUrl + "/v1/projects/" + solargrafProjectId;
        ResponseEntity<Map> projectInfoResponse = restTemplate.exchange(
          projectInfoUrl,
          HttpMethod.GET,
          new HttpEntity<>(getHeaders()),
          Map.class
        );
        Map<String, Object> projectData = (Map<String, Object>) projectInfoResponse.getBody().get("data");
        if (projectData != null) {
          Map<String, Object> attributes = (Map<String, Object>) projectData.get("attributes");
          if (attributes != null) {
            publicId = (String) attributes.get("publicId");
            installerWebQuoteUrl = (String) attributes.get("installerWebQuoteUrl");
          }
        }
      } catch (Exception e) {
        // Swallow exception or handle as needed
      }
      // Now call cloneProposal with correct IDs
      SolargrafProjectRequest req = new SolargrafProjectRequest(newProjectData.getName(), newProjectData.getAddress(), Long.valueOf(solargrafProjectId));
      SolargrafProjectResponse cloneResponse = cloneProposal(solargrafProposalId, req);
      // Attach publicId and installerWebQuoteUrl to response
      if (publicId != null) {
        // Always use the publicId for the preview link
        String previewUrl = "https://app.solargraf.com/preview/" + publicId;
        cloneResponse.setProjectUrl(previewUrl);
        cloneResponse.setMessage((cloneResponse.getMessage() == null ? "" : cloneResponse.getMessage() + " ") + "publicId=" + publicId);
      } else if (installerWebQuoteUrl != null) {
        cloneResponse.setProjectUrl(installerWebQuoteUrl);
      }
      return cloneResponse;
    } catch (Exception e) {
      log.error("[Solargraf] Exception in cloneProposalFromCustomField: " + e.getMessage(), e);
      return new SolargrafProjectResponse(null, false, "Error in Solargraf clone logic: " + e.getMessage());
    }
  }
}
