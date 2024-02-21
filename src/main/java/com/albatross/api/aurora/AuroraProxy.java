package com.albatross.api.aurora;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.AuroraQuery;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import jakarta.annotation.PostConstruct;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import jakarta.validation.constraints.NotBlank;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.util.*;
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
  private final String host = "https://api.aurorasolar.com";
  private final SqlCache sqlCache;

  private WebClient client;

  @Value(value = "${aurora.api.tenantId}")
  private String tenantId;

  @Value(value = "${aurora.api.token}")
  private String token;

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

  public DesignSummary getDesignSummary(@NotBlank String designId) throws IOException {
    try {
      ResponseEntity<String> res = client
        .get()
        .uri("/v2/tenants/%s/designs/%s/summary".formatted(tenantId, designId))
        .header("Authorization", "Bearer " + token)
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
        .uri("/v2/tenants/%s/designs/%s/roof_summary".formatted(tenantId, designId))
        .header("Authorization", "Bearer " + token)
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

  public String getDesignId(Long ppsId, Long cfgaId) {
    return sqlCache.queryForObjectOptionalBySql(AuroraQuery.getIdByProjectProcessStepId, Map.of("ppsId", ppsId, "cfgaId", cfgaId), String.class)
                   .orElse(null);
  }

  public class DesignSummary {
    @Getter private final JsonNode fields;

    @Getter private final Map<Integer, Face> faces;

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
    @Getter private final List<SolarArray> arrays;

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
}
