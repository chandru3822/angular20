package com.albatross.api.aurora;

import com.albatross.api.utils.SqlCache;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import com.google.common.net.UrlEscapers;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.ToString;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.digest.HmacAlgorithms;
import org.apache.commons.codec.digest.HmacUtils;
import org.apache.commons.text.StringSubstitutor;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.StreamSupport;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkState;
import static java.time.ZoneOffset.UTC;
import static java.util.stream.Collectors.groupingBy;
import static org.apache.commons.lang3.StringUtils.isNotBlank;

// @TODO: this class should probably be renamed to 'AuroraService' and moved to the brs service
// folder to match convention
@Slf4j
@Service
@RequiredArgsConstructor
public class AuroraProxy {
  private final ObjectMapper om = new ObjectMapper();
  private final CloseableHttpClient httpClient = HttpClients.createDefault();
  private final String host = "https://api.aurorasolar.com";
  private final SqlCache sqlCache;

  @Value(value = "${aurora.api.tenantId}")
  private String tenantId;

  @Value(value = "${aurora.api.key}")
  private String apiKey;

  @Value(value = "${aurora.api.secret}")
  private String apiSecret;

  private static String useTemplate(String template, Map<String, ? extends Object> vals) {
    StringSubstitutor subs = new StringSubstitutor(vals);
    return subs.replace(template);
  }

  private static String useTemplate(String template, String... vals) {
    checkArgument(vals.length % 2 == 0, "must provide even number of values");
    ImmutableMap.Builder<String, String> builder = ImmutableMap.builder();
    for (int i = 0; i < vals.length; i += 2) builder.put(vals[i], vals[i + 1]);

    return useTemplate(template, builder.build());
  }

  ///////////////////////////////////////////////////////////////////////////
  // data objects for returning design summary info
  ///////////////////////////////////////////////////////////////////////////
  private static Optional<JsonNode> getField(JsonNode root, String... path) {
    Optional<JsonNode> node = Optional.of(root);
    for (String field : path) node = node.map(n -> n.get(field));
    return node;
  }

  public DesignSummary getDesignSummary(String designId) throws IOException {
    checkRequiredFields();
    checkArgument(isNotBlank(designId), "designId cannot be blank");

    AuroraRequest req = createGetDesignSummaryRequest(designId);
    log.debug("AURORA: the summary request {}", req);
    try (CloseableHttpResponse resp = httpClient.execute(req.toHttpRequest())) {
      int statusCode = resp.getStatusLine().getStatusCode();
      checkArgument(
          statusCode == HttpStatus.SC_OK, "Received unexpected response code " + statusCode);
      InputStream content = resp.getEntity().getContent();
      log.debug("AURORA: starting build design summary");
      return new DesignSummary(content);
    } catch (Exception e) {
      String msg = "AURORA: Failed to get design summary for design " + designId;
      log.error(msg, e);
      throw new IOException(msg, e);
    }
  }

  public String getTenantsProjects(int pageNumber) throws IOException {
    String uri = useTemplate("/v2/tenants/${tenant_id}/projects", "tenant_id", tenantId);
    AuroraRequest req =
        new AuroraRequest(HttpMethod.GET, uri, "page=" + pageNumber + "&per_page=250\n");
    log.debug("AURORA: the tenants request {}", req);
    try (CloseableHttpResponse resp =
        httpClient.execute(req.toHttpRequestWithParams("?page=" + pageNumber + "&per_page=250"))) {
      int statusCode = resp.getStatusLine().getStatusCode();
      checkArgument(
          statusCode == HttpStatus.SC_OK, "Received unexpected response code " + statusCode);
      log.debug("AURORA: starting project str builder...");
      InputStream content = resp.getEntity().getContent();
      BufferedReader bR = new BufferedReader(new InputStreamReader(content));
      String line = "";
      StringBuilder responseStrBuilder = new StringBuilder();
      while ((line = bR.readLine()) != null) {
        log.debug("AURORA: read tenant line - this might go too crazy: {}", line);
        responseStrBuilder.append(line);
      }
      content.close();
      log.debug("AURORA: closing project str builder...");
      return responseStrBuilder.toString();
    } catch (Exception e) {
      String msg = "AURORA: Failed to get tenants projects";
      // If 503, server is unavailable, try again
      if (e.getMessage().contains("503")) {
        return getTenantsProjects(pageNumber);
      }
      log.error(msg, e);
      throw new IOException(msg, e);
    }
  }

  public String getProjectDesigns(String projectId) throws IOException {
    String uri =
        useTemplate(
            "/v2/tenants/${tenant_id}/projects/${project_id}/designs",
            "tenant_id",
            tenantId,
            "project_id",
            projectId);
    AuroraRequest req = new AuroraRequest(HttpMethod.GET, uri, null);
    log.debug("AURORA: the projects request {}", req);
    try (CloseableHttpResponse resp = httpClient.execute(req.toHttpRequest())) {
      int statusCode = resp.getStatusLine().getStatusCode();
      checkArgument(
          statusCode == HttpStatus.SC_OK, "Received unexpected response code " + statusCode);
      log.debug("AURORA: starting project str builder...");
      InputStream content = resp.getEntity().getContent();
      BufferedReader bR = new BufferedReader(new InputStreamReader(content));
      String line = "";
      StringBuilder responseStrBuilder = new StringBuilder();
      while ((line = bR.readLine()) != null) {
        log.debug("AURORA: read project line - this might go too crazy: {}", line);
        responseStrBuilder.append(line);
      }
      content.close();
      log.debug("AURORA: closing project str builder...");
      return responseStrBuilder.toString();
    } catch (Exception e) {
      String msg = "AURORA: Failed to get tenants projects";
      log.error(msg, e);
      throw new IOException(msg, e);
    }
  }

  private void checkRequiredFields() {
    checkState(
        isNotBlank(tenantId), "tenantId cannot be blank; perhaps it didn't inject correctly?");
    checkState(isNotBlank(apiKey), "apiKey cannot be blank; perhaps it didn't inject correctly?");
    checkState(
        isNotBlank(apiSecret), "apiSecret cannot be blank; perhaps it didn't inject correctly?");
  }

  private AuroraRequest createGetDesignSummaryRequest(String designId) {
    String uri =
        useTemplate(
            "/v2/tenants/${tenant_id}/designs/${design_id}/summary",
            "tenant_id",
            tenantId,
            "design_id",
            designId);
    return new AuroraRequest(HttpMethod.GET, uri, null);
  }

  public String getDesignId(Long ppsId, Long cfgaId) {
    return sqlCache.queryForObjectOptional("aurora.getIdByProjectProcessStepId", Map.of("ppsId", ppsId, "cfgaId", cfgaId), String.class)
      .orElse(null);
  }

  ///////////////////////////////////////////////////////////////////////////
  // class encapsulating making requests to Aurora
  ///////////////////////////////////////////////////////////////////////////
  @ToString(onlyExplicitlyIncluded = true)
  private class AuroraRequest {
    private final DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private final HttpMethod httpMethod;
    private final String endpoint;
    private final ZonedDateTime timestamp;
    @ToString.Exclude private final String signature;

    AuroraRequest(HttpMethod httpMethod, String endpoint, String params) {
      this.httpMethod = httpMethod;
      this.endpoint = endpoint;
      this.timestamp = ZonedDateTime.now(UTC);
      this.signature = signature(apiSecret, params);
    }

    HttpUriRequest toHttpRequest() {
      String uri =
          useTemplate(
              "${url}?AuroraKey=${key}&Timestamp=${timestamp}&Signature=${sig}",
              "url",
              host + endpoint,
              "key",
              apiKey,
              "timestamp",
              uriEscape(getFormattedTimestamp()),
              "sig",
              signature);
      return new HttpGet(uri);
    }

    HttpUriRequest toHttpRequestWithParams(String params) {
      String uri =
          useTemplate(
              "${url}&AuroraKey=${key}&Timestamp=${timestamp}&Signature=${sig}",
              "url",
              host + endpoint + params,
              "key",
              apiKey,
              "timestamp",
              uriEscape(getFormattedTimestamp()),
              "sig",
              signature);
      return new HttpGet(uri);
    }

    private String signature(String secretKey, String params) {
      String msg = toSignatureString(params);
      byte[] bs = new HmacUtils(HmacAlgorithms.HMAC_SHA_256, secretKey).hmac(msg);

      return uriEscape(Base64.getEncoder().encodeToString(bs));
    }

    /** Converts this request to the format required by Aurora's authentication. */
    private String toSignatureString(String params) {
      log.debug(
          "AURORA: sending request to method={}, endpoint={}, params={}",
          httpMethod,
          endpoint,
          params);
      return useTemplate(
          "${httpMethod}\n${endpoint}\nAuroraKey=${apiKey}\nTimestamp=${timestamp}\n"
              + ((params != null) ? (params) : ""),
          "httpMethod",
          httpMethod.name(),
          "endpoint",
          endpoint,
          "apiKey",
          apiKey,
          "timestamp",
          uriEscape(getFormattedTimestamp()),
          "sortQueryParams",
          "");
    }

    private String getFormattedTimestamp() {
      return f.format(timestamp) + " UTC";
    }

    private String uriEscape(String s) {
      return UrlEscapers.urlPathSegmentEscaper().escape(s);
    }

    private String getFullUrl() {
      return host + endpoint;
    }
  }

  public class DesignSummary {
    @Getter private final JsonNode fields;

    @Getter private final Map<Integer, Face> faces;

    DesignSummary(InputStream in) throws IOException {
      this.fields = om.readTree(in);

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

    public Integer getFaceNumber() {
      checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
      int faceNumber = arrays.get(0).getFaceNumber();
      checkArgument(
          Iterables.all(arrays, a -> a.getFaceNumber() == faceNumber),
          "not all arrays have the same face number");
      return faceNumber;
    }

    public Optional<Integer> getTotalPanelCount() {
      checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
      return arrays.stream()
          .map(SolarArray::getPanelCount)
          .filter(Optional::isPresent)
          .map(Optional::get)
          .reduce(Integer::sum);
    }

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

    public Optional<Integer> getWeightedAverageTSRF() {
      checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
      int weightedSum = 0, numPanels = 0;
      boolean missingAnyArrayValue = false;
      for (SolarArray array : arrays) {
        Optional<Integer> tsrf = array.getTotalSolarResourceFraction(),
            panels = array.getPanelCount();
        if (tsrf.isEmpty() || panels.isEmpty()) {
          missingAnyArrayValue = true;
          // checkArgument(tsrf.isPresent(), "array is missing TSRF value");
          // checkArgument(panels.isPresent(), "array is missing panel count");
          log.error("AURORA: Missing TSRF Value");
        } else {
          weightedSum += panels.get() * tsrf.get();
          numPanels += panels.get();
        }
      }
      // per judson we should return 0 instead of guessing what the values of panels and total solar
      // resource refraction access might be
      return missingAnyArrayValue ? Optional.of(0) : Optional.of(weightedSum / numPanels);
    }

    public Optional<Integer> getWeightedAverageAnnualSolarAccess() {
      checkArgument(!arrays.isEmpty(), "list of arrays cannot be empty");
      int weightedSum = 0, numPanels = 0;
      boolean missingAnyArrayValue = false;
      for (SolarArray array : arrays) {
        Optional<Integer> annualSolarAccess = array.getAnnualSolarAccess(),
            panels = array.getPanelCount();
        if (annualSolarAccess.isEmpty() || panels.isEmpty()) {
          missingAnyArrayValue = true;
          // checkArgument(annualSolarAccess.isPresent(), "array is missing annual solar access
          // value");
          // checkArgument(panels.isPresent(), "array is missing panel count");
          log.error("AURORA: Missing Annual Solar Access Value");
        } else {
          weightedSum += panels.get() * annualSolarAccess.get();
          numPanels += panels.get();
        }
      }
      // per judson we should return 0 instead of guessing what the values of panels and annual
      // solar access might be
      return missingAnyArrayValue ? Optional.of(0) : Optional.of(weightedSum / numPanels);
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

    public Optional<Integer> getPanelCount() {
      return getField(fields, "module", "count").map(JsonNode::intValue);
    }

    public Optional<Integer> getTotalSolarResourceFraction() {
      return getField(fields, "shading", "total_solar_resource_fraction", "annual")
          .map(JsonNode::intValue);
    }

    public Optional<Integer> getAnnualSolarAccess() {
      return getField(fields, "shading", "solar_access", "annual").map(JsonNode::intValue);
    }

    public Optional<Integer> getPitch() {
      return getField(fields, "pitch").map(JsonNode::intValue);
    }

    public Optional<BigDecimal> getAzimuth() {
      return getField(fields, "azimuth").map(JsonNode::decimalValue);
    }
  }
}
