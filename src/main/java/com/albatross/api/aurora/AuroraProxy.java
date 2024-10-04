package com.albatross.api.aurora;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.AuroraQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import jakarta.annotation.PostConstruct;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.stream.StreamSupport;

import static com.google.common.base.Preconditions.checkArgument;
import static java.util.stream.Collectors.groupingBy;

// @TODO: this class should probably be renamed to 'AuroraService' and moved to the brs service
// folder to match convention
@Slf4j
@Service
@RequiredArgsConstructor
public class AuroraProxy {
    private final ObjectMapper om = new ObjectMapper();
    //  private final String host = "https://api.aurorasolar.com";
    private final SqlCache sqlCache;

    private WebClient client;

    @Value(value = "${aurora.api.host}")
    private String host;

    @Value(value = "${app.env}")
    private String appEnv;

    @Value(value = "${aurora.api.tenantId}")
    private String tenantId;

    //todo: after the next release we should be able to update the aurora standard token then have prod start usign that instead of the restricted token
    @Value(value = "${aurora.api.token}")
    private String token;

  @Value(value = "${aurora.api.tokenV2022}")
  private String tokenV2022;

    @PostConstruct
    public void init() {
        client = WebClient.create(host);
    }

    ///////////////////////////////////////////////////////////////////////////
    // data objects for returning design summary info
    ///////////////////////////////////////////////////////////////////////////
    private static Optional<JsonNode> getField(JsonNode root, String... path) {
        Optional<JsonNode> node = Optional.of(root);
        for (String field : path) node = node.map(n -> n.get(field));
        return node;
    }

    private String getProjectAddress(String street1, String city, String state, String postalCode ) {
        return Stream.of(street1, city, state, postalCode)
                .map(Object::toString)
                .collect(Collectors.joining(", "))
                .trim();
    }

  public void updateAuroraProjectOwner(String projectId, String auroraUserId) {
    AuroraProjectDTO project = new AuroraProjectDTO();
    project.setOwnerId(auroraUserId);

    RestClient client2 = RestClient.builder().baseUrl(host).build();
    ResponseEntity<AuroraProjectDTO> res = client2
      .put()
      .uri("/tenants/%s/projects/%s".formatted(tenantId, projectId))
      .header("Authorization", "Bearer " + tokenV2022)
      .body(project)
      .contentType(MediaType.APPLICATION_JSON)
      .retrieve()
      .toEntity(AuroraProjectDTO.class);

    if (res != null && res.getStatusCode() != HttpStatus.OK) {
      throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
    }
  }

  public AuroraUserListDTO getUserList() throws IOException {
    try {
      ResponseEntity<AuroraUserListDTO> res = client
        .get()
        .uri("/tenants/%s/users".formatted(tenantId))
        .header("Authorization", "Bearer " + tokenV2022)
        .retrieve()
        .toEntity(AuroraUserListDTO.class)
        .timeout(Duration.ofSeconds(30))
        .onErrorMap(Exception.class, e -> e)
        .block();

      return res.getBody();
    } catch (Exception e) {
      String msg = "AURORA: Failed to find user list";
      log.debug(msg, e);
      throw new IOException(msg, e);
    }
  }

  public AuroraDesignListDTO getDesignsForProject(@NotBlank String projectId) throws IOException {
    try {
      ResponseEntity<AuroraDesignListDTO> res = client
        .get()
        .uri("/tenants/%s/projects/%s/designs".formatted(tenantId, projectId))
        .header("Authorization", "Bearer " + tokenV2022)
        .retrieve()
        .toEntity(AuroraDesignListDTO.class)
        .timeout(Duration.ofSeconds(30))
        .onErrorMap(Exception.class, e -> e)
        .block();

      return res.getBody();
    } catch (Exception e) {
      String msg = "AURORA: Failed to find designs for project " + projectId;
      log.debug(msg, e);
      throw new IOException(msg, e);
    }
  }

  public AssetList getDesignAssets(@NotBlank String designId) throws IOException {
    try {
      ResponseEntity<String> res = client
        .get()
        .uri("/tenants/%s/designs/%s/assets".formatted(tenantId, designId))
        .header("Authorization", "Bearer " + tokenV2022)
        .retrieve()
        .toEntity(String.class)
        .timeout(Duration.ofSeconds(30))
        .onErrorMap(Exception.class, e -> e)
        .block();

//      return res.getBody();
      return new AssetList(res.getBody());
    } catch (Exception e) {
      String msg = "AURORA: Failed to find assets for design " + designId;
      log.debug(msg, e);
      throw new IOException(msg, e);
    }
  }

    public AuroraProjectDTO createProject(com.albatross.api.v1.flow.model.project.Project flowProject, String auroraUserId) throws IOException {
        try {
            String stringProjectId = flowProject.getId().toString();
            //if not prod then wrap the projectId string in **TEST**
            String auroraProjectName = null != appEnv && appEnv.equals("prod") ? stringProjectId : "**TEST** " + stringProjectId + " **TEST**";

            AuroraProjectDTO project = new AuroraProjectDTO();
            project.setExternalProviderId(stringProjectId);
            project.setName(auroraProjectName);
            project.setOwnerId(auroraUserId);
            project.setCustomerFirstName(flowProject.getFirstName());
            project.setCustomerLastName(flowProject.getLastName());
            project.setCustomerPhone(null != flowProject.getMobile() ? flowProject.getMobile() : flowProject.getPhone());
            project.setAddress(getProjectAddress(flowProject.getStreet1(), flowProject.getCity(), flowProject.getState(), flowProject.getPostalCode()));

            RestClient client2 = RestClient.builder().baseUrl(host).build();
            ResponseEntity<AuroraProjectDTO> res = client2.post()
                                                .uri("/tenants/%s/projects".formatted(tenantId))
                                                .header("Authorization", "Bearer " + tokenV2022)
                                                .body(project)
                                                .contentType(MediaType.APPLICATION_JSON)
                                                .retrieve()
                                                .toEntity(AuroraProjectDTO.class);

            if (res != null && res.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
            }

            return res.getBody();
        } catch (Exception e) {
            String msg = "AURORA: Failed to create project for " + flowProject.getId();
            log.debug(msg, e);
            throw new IOException(msg, e);
        }
    }

    public AuroraDesignWrappedDTO createDesign(String auroraProjectId, String designName) throws IOException {
        try {

            AuroraDesignWrappedDTO design = new AuroraDesignWrappedDTO();

            design.setProjectId(auroraProjectId);
            design.setName(designName);

            RestClient client = RestClient.builder().baseUrl(host).build();
            ResponseEntity<AuroraDesignWrappedDTO> res = client.post()
                    .uri("/tenants/%s/designs".formatted(tenantId))
                    .header("Authorization", "Bearer " + tokenV2022)
                    .body(design)
                    .contentType(MediaType.APPLICATION_JSON)
                    .retrieve()
                    .toEntity(AuroraDesignWrappedDTO.class);

            if (res != null && res.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
            }

            return res.getBody();
        } catch (Exception e) {
            String msg = "AURORA: Failed to create design for project: " + auroraProjectId + " with name: " + designName;
            log.debug(msg, e);
            throw new IOException(msg, e);
        }
    }

  public AuroraDesignWrappedDTO duplicateDesign(String designId, String designName) throws IOException {
    try {
      AuroraDesignWrappedDTO design = new AuroraDesignWrappedDTO();
      design.setName(designName);

      RestClient client = RestClient.builder().baseUrl(host).build();
      ResponseEntity<AuroraDesignWrappedDTO> res = client.post()
        .uri("/tenants/%s/designs/%s/duplicate".formatted(tenantId, designId))
        .header("Authorization", "Bearer " + tokenV2022)
        .body(design)
        .contentType(MediaType.APPLICATION_JSON)
        .retrieve()
        .toEntity(AuroraDesignWrappedDTO.class);

      if (res != null && res.getStatusCode() != HttpStatus.OK) {
        throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
      }

      return res.getBody();
    } catch (Exception e) {
      String msg = "AURORA: Failed to duplicate design for design: " + designId;
      log.debug(msg, e);
      throw new IOException(msg, e);
    }
  }

    public void updateAuroraDesignWithMonthlyEnergyUsage(String auroraUserId, String projectId, List<Double> monthlyInputs)  {
        AuroraUpdateConsumptionProfileDTO acp = new AuroraUpdateConsumptionProfileDTO();
        acp.setMonthlyEnergy(monthlyInputs);
        String bodyJson;
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            bodyJson = objectMapper.writeValueAsString(acp).replace("null", "\"null\"");
        } catch (Exception e){
            log.error("AURORA: {}", e.getMessage());
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    e.getMessage(),
                    new Exception());
        }

        RestClient client2 = RestClient.builder().baseUrl(host).build();
        ResponseEntity<AuroraConsumptionProfileDTO> res = client2
                .put()
                .uri("/tenants/%s/projects/%s/consumption_profile".formatted(tenantId, projectId))
                .header("Authorization", "Bearer " + tokenV2022)
                .body(bodyJson)
                .contentType(MediaType.APPLICATION_JSON)
                .retrieve()
                .toEntity(AuroraConsumptionProfileDTO.class);

        if (res != null && res.getStatusCode() != HttpStatus.OK) {
            throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
        }
    }

    public DesignSummary getDesignSummary(@NotBlank String designId) throws IOException {
        try {
            ResponseEntity<String> res = client
                    .get()
                    .uri("/tenants/%s/designs/%s/summary".formatted(tenantId, designId))
                    .header("Authorization", "Bearer " + tokenV2022)
                    .retrieve()
                    .toEntity(String.class)
                    .timeout(Duration.ofSeconds(30))
                    .onErrorMap(Exception.class, e -> e)
                    .block();

            if (res != null && res.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
            }

            return new DesignSummary(res.getBody());
        } catch (Exception e) {
            String msg = "AURORA: Failed to get design summary for design " + designId;
            log.debug(msg, e);
            throw new IOException(msg, e);
        }
    }

    public String getDesignRoofSummary(@NotBlank String designId) throws IOException {
        try {
            ResponseEntity<String> res = client
                    .get()
                    .uri("/tenants/%s/designs/%s/roof_summary".formatted(tenantId, designId))
                    .header("Authorization", "Bearer " + tokenV2022)
                    .retrieve()
                    .toEntity(String.class)
                    .timeout(Duration.ofSeconds(30))
                    .onErrorMap(Exception.class, e -> e)
                    .block();

            if (res != null && res.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
            }

            return res.getBody();
        } catch (Exception e) {
            String msg = "AURORA: Failed to get roof summary for design " + designId;
            log.debug(msg, e);
            throw new IOException(msg, e);
        }
    }
    public String getDesignRackingArrays(@NotBlank String designId) throws IOException {
        try {
            ResponseEntity<String> res = client
                    .get()
                    .uri("/tenants/%s/designs/%s/racking_arrays".formatted(tenantId, designId))
                    .header("Authorization", "Bearer " + tokenV2022)
                    .retrieve()
                    .toEntity(String.class)
                    .timeout(Duration.ofSeconds(30))
                    .onErrorMap(Exception.class, e -> {
                      log.error("error fetching design racking arrays", e);
                      return e;
                    })
                    .block();


            if (res != null && res.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
            }
            return res.getBody();
        } catch (Exception e) {
            String msg = "AURORA: Failed to get racking arrays for design " + designId;
            log.debug(msg, e);
            throw new IOException(msg, e);
        }
    }

    public String getDesignId(Long ppsId, Long cfgaId) {
        return sqlCache.queryForObjectOptionalBySql(AuroraQuery.getIdByProjectProcessStepId, Map.of("ppsId", ppsId, "cfgaId", cfgaId), String.class)
                .orElse(null);
    }

    public class DesignSummary {
        @Getter
        private final JsonNode fields;

        @Getter
        private final Map<Integer, Face> faces;

        DesignSummary(String data) throws IOException {
            this.fields = om.readTree(data);

            JsonNode arrays =
                    getField(fields, "design", "arrays")
                            .orElseThrow(
                                    () -> new IllegalArgumentException("design missing required field 'arrays'"));
            Map<Integer, List<SolarArray>> m =
                    StreamSupport.stream(arrays.spliterator(), false)
                            .map(SolarArray::new)
                            .collect(groupingBy(SolarArray::getFaceNumber));
            this.faces = Maps.transformValues(m, Face::new);
        }

        public Optional<BigDecimal> getAnnualEnergyProduction() {
            return getField(fields, "design", "energy_production", "annual")
                    .map(JsonNode::decimalValue)
                    .map(
                            bigD ->
                                    // i.e., round half-up with zero decimal points (nearest whole number)
                                    bigD.setScale(0, RoundingMode.HALF_UP));
        }

        public Optional<String> getProjectId() {
            return getField(fields, "design", "project_id").map(JsonNode::textValue);
        }
    }

    @RequiredArgsConstructor
    public class Face {
        @Getter
        private final List<SolarArray> arrays;

        public Optional<BigDecimal> getAzimuth() {
            checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
            Optional<BigDecimal> azimuth = arrays.get(0).getAzimuth();
            checkArgument(
                    Iterables.all(arrays, a -> a.getAzimuth().equals(azimuth)),
                    "not all arrays have the same azimuth");
            return azimuth;
        }

        public Optional<Integer> getPitch() {
            checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
            Optional<Integer> pitch = arrays.get(0).getPitch();
            checkArgument(
                    Iterables.all(arrays, a -> a.getPitch().equals(pitch)),
                    "not all arrays have the same pitch");
            return pitch;
        }

        public Optional<Integer> getTotalPanelCount() {
            checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
            return arrays.stream()
                    .map(com.albatross.api.aurora.AuroraProxy.SolarArray::getPanelCount)
                    .flatMap(Optional::stream)
                    .reduce(Integer::sum);
        }

        public Optional<Integer> getWeightedAverageAnnualSolarAccess() {
            checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
            int weightedSum = 0, numPanels = 0;
            boolean missingAnyArrayValue = false;
            for (com.albatross.api.aurora.AuroraProxy.SolarArray array : arrays) {
                Optional<Integer> annualSolarAccess = array.getAnnualSolarAccess(),
                        panels = array.getPanelCount();
                if (annualSolarAccess.isEmpty() || panels.isEmpty()) {
                    missingAnyArrayValue = true;
                } else {
                    weightedSum += panels.get() * annualSolarAccess.get();
                    numPanels += panels.get();
                }
            }
            // per judson we should return 0 instead of guessing what the values of panels and annual
            // solar access might be
            return missingAnyArrayValue ? Optional.of(0) : Optional.of(weightedSum / numPanels);
        }

        public Optional<Integer> getWeightedAverageTSRF() {
            checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
            int weightedSum = 0, numPanels = 0;
            boolean missingAnyArrayValue = false;
            for (SolarArray array : arrays) {
                Optional<Integer> tsrf = array.getTotalSolarResourceFraction(),
                        panels = array.getPanelCount();
                if (tsrf.isEmpty() || panels.isEmpty()) {
                    missingAnyArrayValue = true;
                } else {
                    weightedSum += panels.get() * tsrf.get();
                    numPanels += panels.get();
                }
            }
            // per judson we should return 0 instead of guessing what the values of panels and total solar
            // resource refraction access might be
            return missingAnyArrayValue ? Optional.of(0) : Optional.of(weightedSum / numPanels);
        }

        public Integer getFaceNumber() {
            checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
            int faceNumber = arrays.get(0).getFaceNumber();
            checkArgument(
                    Iterables.all(arrays, a -> a.getFaceNumber() == faceNumber),
                    "not all arrays have the same face number");
            return faceNumber;
        }
    }

    @RequiredArgsConstructor
    public class SolarArray {
        private final JsonNode fields;

        public int getFaceNumber() {
            return getField(fields, "face")
                    .map(JsonNode::intValue)
                    .orElseThrow(
                            () -> new IllegalArgumentException("could not retrieve solar array face number"));
        }

        public Optional<Integer> getPitch() {
            return getField(fields, "pitch").map(JsonNode::intValue);
        }

        public Optional<BigDecimal> getAzimuth() {
            return getField(fields, "azimuth").map(JsonNode::decimalValue);
        }

        public Optional<Integer> getPanelCount() {
            return getField(fields, "module", "count").map(JsonNode::intValue);
        }

        public Optional<Integer> getAnnualSolarAccess() {
            return getField(fields, "shading", "solar_access", "annual").map(JsonNode::intValue);
        }

        public Optional<Integer> getTotalSolarResourceFraction() {
            return getField(fields, "shading", "total_solar_resource_fraction", "annual")
                    .map(JsonNode::intValue);
        }
    }


  public class AssetList {
    @Getter
    private final List<AuroraAssetDTO> assets;

    AssetList(String data) throws IOException {
      JsonNode jsonNode = om.readTree(data);
//      Optional<JsonNode> assetsJson = getField(json, "assets");
      String assetsString = jsonNode.get("assets").toString();

      List<AuroraAssetDTO> assetList = om.readValue(assetsString, new TypeReference<>(){});

      this.assets = assetList;
    }
  }
//
//  @RequiredArgsConstructor
//  public static class Asset {
//    private final JsonNode fields;
//
//    public Optional<String> getUrl() {
//      return getField(fields, "url").map(JsonNode::textValue);
//    }
//  }
}
