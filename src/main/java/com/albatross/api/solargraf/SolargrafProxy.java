package com.albatross.api.solargraf;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.SolargrafQuery;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class SolargrafProxy {
    private final ObjectMapper om = new ObjectMapper();

    private final SqlCache sqlCache;

    private WebClient client;

    @Value(value = "${solargraf.api.host}")
    private String host;

    @Value(value = "${solargraf.api.token}")
    private String token;


  private static Optional<JsonNode> getField(JsonNode root, String... path) {
    Optional<JsonNode> node = Optional.of(root);
    for (String field : path) node = node.map(n -> n.get(field));
    return node;
  }

    @PostConstruct
    public void init() {
        client = WebClient.create(host);
    }

    public SolargrafPanelArrays getSolargrafPanelArrays(@NotBlank String solargrafId) throws IOException {
        try {
            ResponseEntity<String> res = client
                    .get()
                    .uri("/v1/projects/%s/panel-arrays".formatted(solargrafId))
                    .header("Authorization", "Api-Key " + token)
                    .retrieve()
                    .toEntity(String.class)
                    .timeout(Duration.ofSeconds(30))
                    .onErrorMap(Exception.class, e -> e)
                    .block();

            if (res != null && res.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
            }

            return new SolargrafPanelArrays(res.getBody());
        } catch (Exception e) {
            String msg = "SOLARGRAF: Failed to get panel arrays " + solargrafId;
            log.debug(msg, e);
            throw new IOException(msg, e);
        }
    }

  public SolargrafMaterials getSolargrafMaterials(@NotBlank String solargrafId) throws IOException {
    try {
      ResponseEntity<String> res = client
        .get()
        .uri("/v1/projects/%s/materials".formatted(solargrafId))
        .header("Authorization", "Api-Key " + token)
        .retrieve()
        .toEntity(String.class)
        .timeout(Duration.ofSeconds(30))
        .onErrorMap(Exception.class, e -> e)
        .block();

      if (res != null && res.getStatusCode() != HttpStatus.OK) {
        throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
      }

      return new SolargrafMaterials(res.getBody());
    } catch (Exception e) {
      String msg = "SOLARGRAF: Failed to get panel arrays " + solargrafId;
      log.debug(msg, e);
      throw new IOException(msg, e);
    }
  }

    public SolargrafStorage getSolargrafStorage(@NotBlank String solargrafId) throws IOException {
        try {
            ResponseEntity<String> res = client
                    .get()
                    .uri("/v1/projects/%s/proposals".formatted(solargrafId))
                    .header("Authorization", "Api-Key " + token)
                    .retrieve()
                    .toEntity(String.class)
                    .timeout(Duration.ofSeconds(30))
                    .onErrorMap(Exception.class, e -> e)
                    .block();

            if (res != null && res.getStatusCode() != HttpStatus.OK) {
                throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
            }

            return new SolargrafStorage(res.getBody());
        } catch (Exception e) {
            String msg = "SOLARGRAF: Failed to get panel arrays " + solargrafId;
            log.debug(msg, e);
            throw new IOException(msg, e);
        }
    }

  public SolargrafProductions getSolargrafProduction(@NotBlank String solargrafId) throws IOException {
    try {
      ResponseEntity<String> res = client
        .get()
        .uri("/v1/projects/%s/productions".formatted(solargrafId))
        .header("Authorization", "Api-Key " + token)
        .retrieve()
        .toEntity(String.class)
        .timeout(Duration.ofSeconds(30))
        .onErrorMap(Exception.class, e -> e)
        .block();

      if (res != null && res.getStatusCode() != HttpStatus.OK) {
        throw new RuntimeException("Received unexpected response code " + res.getStatusCodeValue());
      }

      return new SolargrafProductions(res.getBody());
    } catch (Exception e) {
      String msg = "SOLARGRAF: Failed to get Productions " + solargrafId;
      log.debug(msg, e);
      throw new IOException(msg, e);
    }
  }

    public String getSolargrafId(Long ppsId, Long cfgaId) {
        return sqlCache.queryForObjectOptionalBySql(SolargrafQuery.getIdByProjectProcessStepId, Map.of("ppsId", ppsId, "cfgaId", cfgaId), String.class)
                .orElse(null);
    }

    public class SolargrafPanelArrays {
        @Getter
        private final JsonNode fields;

      SolargrafPanelArrays(String data) throws IOException {
            this.fields = om.readTree(data);

            JsonNode arrays =
                    getField(fields, "data")
                            .orElseThrow(
                                    () -> new IllegalArgumentException("Response missing required field 'data'"));

        }
    }

    public class SolargrafStorage {
        @Getter
        private final JsonNode fields;

        SolargrafStorage(String data) throws IOException {
            this.fields = om.readTree(data);

            JsonNode arrays =
                    getField(fields, "data")
                            .orElseThrow(
                                    () -> new IllegalArgumentException("Response missing required field 'data'"));

        }
    }

  public class SolargrafProductions {
    @Getter
    private final JsonNode fields;

    SolargrafProductions(String data) throws IOException {
      this.fields = om.readTree(data);

      JsonNode arrays =
        getField(fields, "data")
          .orElseThrow(
            () -> new IllegalArgumentException("Response missing required field 'data'"));

    }
  }

  public class SolargrafMaterials {
    @Getter
    private final JsonNode fields;

    SolargrafMaterials(String data) throws IOException {
      this.fields = om.readTree(data);

      JsonNode arrays =
        getField(fields, "data")
          .orElseThrow(
            () -> new IllegalArgumentException("Response missing required field 'data'"));

    }
  }

   }
