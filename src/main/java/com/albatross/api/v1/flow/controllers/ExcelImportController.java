package com.albatross.api.v1.flow.controllers;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.ExcelImportQuery;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.ProjectService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.util.Assert;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

import static org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR;

// @TODO: This class should probably be in brs and not flow

@Slf4j
@Validated
@RestController
@RequestMapping(value = "/api/v1/excel")
@RequiredArgsConstructor
public class ExcelImportController {

  private final ObjectMapper om;
  private final AuroraProxy aurora;
  private final SqlCache cache;
  private final NamedParameterJdbcTemplate jdbc;
  private final SecurityService security;
  private final ProjectService projectService;

  @GetMapping("/excelId")
  public Long getUniqueIdForExcel() {
    return jdbc.queryForObject(ExcelImportQuery.sqlId, Map.of(), Long.class);
  }

  @GetMapping("/baseConfirm/{baseId}")
  public ResponseEntity getUniqueIdForExcel(
    @PathVariable("baseId") Long projectId, @RequestHeader Map<String, String> headers) {
    debugPrintHeaders(headers);
    try {
      Map<String, Object> result =
        jdbc.queryForObject(
          ExcelImportQuery.validateProjectId, Map.of("projectId", projectId), new ColumnMapRowMapper());
      return ResponseEntity.ok(result);
    } catch (IncorrectResultSizeDataAccessException e) {
      if (e.getActualSize() < 1) {
        log.error("EXCEL_IMPORT: Could not find project identified by Project id {}.", projectId);
        return ResponseEntity.notFound().build();
      }

      log.error(
        "EXCEL_IMPORT: Encountered error retrieving project with Project id {}", projectId, e);
      return ResponseEntity.status(INTERNAL_SERVER_ERROR)
        .body("Encountered error retrieving project with Project id " + projectId);
    } catch (Exception e) {
      log.error(
        "EXCEL_IMPORT: Encountered error retrieving project with Project id {}", projectId, e);
      return ResponseEntity.status(INTERNAL_SERVER_ERROR)
        .body("Encountered error retrieving project with Project id " + projectId);
    }
  }

  private void debugPrintHeaders(Map<String, String> headers) {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    log.debug(headers + "; " + headers);
    log.debug("Received request for ExcelId:\n{}", baos);
  }

  @GetMapping("/baseConfirm/{baseId}/proposals/{proposalId}")
  public ResponseEntity<String> getProposalData(
    @PathVariable("baseId") Long projectId, @PathVariable Long proposalId) {
    Map<String, Object> params = Map.of("projectId", projectId, "proposalId", proposalId);

    List<String> results = jdbc.queryForList(ExcelImportQuery.loadProposal, params, String.class);

    if (results.isEmpty()) {
      String msg = "EXCEL_IMPORT: Found no proposals for " + params;
      log.warn(msg);
      return ResponseEntity.notFound().build();
    } else if (results.size() > 1) {
      log.warn(
        "EXCEL_IMPORT: Found {} proposals for params {}. Returning the most recent.",
        results.size(),
        params);
    }

    return ResponseEntity.ok(results.get(0));
  }

  @PostMapping(value = "/import", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> importProposal(HttpServletRequest req, @RequestBody Proposal proposal) {
    log.debug("EXCEL_IMPORT: Attempting Excel Proposal Log");

    Assert.notNull(proposal, "Proposal Required");
    Assert.hasText(proposal.getSource(), "Source is required; must have text");

    String source = String.format("%s – %s", proposal.getSource(), req.getRemoteAddr());
    proposal.setSource(source);

    Map<String, Object> json = proposal.getProposal();
    Integer propId = null, projectId = null;
    if (json != null) {
      propId = (Integer) json.get("Proposal ID");
      try {
        projectId = (Integer) json.get("Base Deal ID");
      } catch (ClassCastException e) {
        projectId = Integer.parseInt((String) json.get("Base Deal ID"));
      }
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("proposal", proposal.getProposal());
    params.put("source", proposal.getSource());
    params.put("proposalId", propId);
    params.put("projectId", projectId);

    log.debug(
      "EXCEL_IMPORT: Inserting For: PROP_ID: {} PROJECT_ID: {} SOURCE: {}",
      propId,
      projectId,
      proposal.getSource());
    // check if the project id exists
    if (null != projectId) {
      Boolean projectExists = projectService.projectExists(projectId.longValue());

      if (projectExists) {
        Optional<ProposalResponse> created =
          cache.getBySql(ExcelImportQuery.insert,
            params,
            (rs, rowNum) -> {
              try {
                ProposalResponse pr = new ProposalResponse();
                pr.setId(rs.getLong("id"));
                pr.setSource(rs.getString("source"));
                pr.setProjectId(rs.getInt("project_id"));
                pr.setProposalDate(rs.getDate("proposal_date"));
                pr.setProposalId(rs.getInt("proposal_nbr"));
                pr.setProposal(om.readValue(rs.getString("proposal"), new TypeReference<>() {
                }));
                return pr;
              } catch (IOException e) {
                throw new SQLException(e);
              }
            });

        if (created.isEmpty()) {
          throw new IllegalStateException("Did not get back a created proposal_log");
        }
        log.debug("EXCEL_IMPORT: Created Excel Proposal Log ID={}", created.get().getId());

        return ResponseEntity.status(HttpStatus.CREATED).body(created.get());
      } else {
        log.error(
          "EXCEL_IMPORT: ERROR: Attempted Proposal Log Insert with invalid Project ID: {} for Proposal: {}",
          projectId,
          propId);
        throw new ResponseStatusException(
          HttpStatus.NOT_FOUND, "No Project Found with ID: " + projectId, new Exception());
      }
    } else {
      log.error("EXCEL_IMPORT: ERROR: No project id included in request");
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST, "No project id included in request", new Exception());
    }
  }

  // design stuff
  @GetMapping(value = "/design/excelId", produces = MediaType.APPLICATION_JSON_VALUE)
  public Long getUniqueIdForDesignExcel(@RequestHeader Map<String, String> headers) {
    debugPrintHeaders(headers);
    return jdbc.queryForObject(ExcelImportQuery.designSqlId, Map.of(), Long.class);
  }

  @PostMapping(value = "/design/import", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ImportResponse> designImport(HttpServletRequest req, @RequestBody Design design) {
    log.debug("EXCEL_IMPORT: Attempting Excel Design Log");

    Assert.notNull(design, "Design Required");
    User user = security.getCurrentUser();

    Assert.hasText(design.getSource(), "Source is required; must have text");
    String source =
      String.format("%s – %s – %s", user.getEmail(), design.getSource(), req.getRemoteAddr());
    design.setSource(source);

    List<Map<String, Object>> bom = design.getBom();

    Map<String, Object> originalBom = new HashMap<>();

    bom.forEach(i -> originalBom.put(i.get("name").toString(), i.get("quantity")));

    // todo: verify that the project exists and return a pretty error if it doesnt
    Long blueRavenCorporateCompanyId = 3L;
    Boolean projectExists =
      projectService.projectExistsInHierarchy(
        design.getProjectId().longValue(), blueRavenCorporateCompanyId);

    if (projectExists) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("design", design.getDesign());
      params.put("source", design.getSource());
      params.putIfAbsent("designDate", new Date());
      params.putIfAbsent("designId", design.getDesignId());
      params.putIfAbsent("projectId", design.getProjectId());
      params.putIfAbsent("originalBom", originalBom);
      try {
        params.putIfAbsent("bomWithPartNumber", om.writeValueAsString(bom));
      } catch (Exception e) {
        //noop
        log.error("EXCEL_IMPORT: " + e.getMessage());
      }
      // this is the id of the design log that got created
      Optional<DesignResponse> designLogId =
        cache.getBySql(ExcelImportQuery.designInsert,
          params,
          (rs, rowNum) -> {
            try {
              DesignResponse dr = new DesignResponse();
              dr.setId(rs.getLong("id"));
              dr.setSource(rs.getString("source"));
              dr.setProjectId(rs.getInt("project_id"));
              dr.setDesignDate(rs.getDate("design_date"));
              dr.setDesignId(rs.getInt("design_nbr"));
              dr.setOriginalBom(om.readValue(rs.getString("bom"), new TypeReference<>() {
              }));
              dr.setBom(om.readValue(rs.getString("bom_with_part_number"), new TypeReference<>() {
              }));
              return dr;
            } catch (IOException e) {
              throw new SQLException(e);
            }
          });

      if (designLogId.isEmpty()) {
        throw new IllegalStateException("EXCEL_IMPORT: Did not get back a created design_log");
      }

      log.debug("EXCEL_IMPORT: Created Excel Design Log id={}", designLogId.get().getId());

      return ResponseEntity.status(HttpStatus.CREATED).body(new ImportResponse(designLogId.get().getDesignId()));
    } else {
      log.error("EXCEL_IMPORT: Received Invalid Project ID: {}", design.getProjectId());
      // if no project found within BR corporate hierarchy return 404
      throw new ResponseStatusException(
        HttpStatus.NOT_FOUND, "Project ID Not Found.", new Exception());
    }
  }

  @PostMapping(value = "/permit/import", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<ImportResponse> permitPackImport(HttpServletRequest req, @RequestBody @Valid @NotNull PermitPack permitPack) {

    User user = security.getCurrentUser();
    String remoteAddr = req.getRemoteAddr();

    log.debug("EXCEL_IMPORT: Attempting Excel Permit Pack Log from user={} at IP={}", user.getEmail(), remoteAddr);

    Long blueRavenCorporateCompanyId = 3L;

    Boolean projectExists =
      projectService.projectExistsInHierarchy(
        permitPack.projectId, blueRavenCorporateCompanyId);

    if (!projectExists) {
      log.error("EXCEL_IMPORT: Received Invalid Project ID: {}", permitPack.projectId);
      throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Project ID Not Found.");
    }

    String source =
      String.format("%s – %s – %s", user.getEmail(), permitPack.source, remoteAddr);

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", permitPack.projectId);
    params.put("source", source);
    //note: BR sends in the design log NUMBER in the designLogId field
    params.put("designLogNumber", permitPack.designLogId);
    params.put("permitPackDate", permitPack.permitPackDate);
    params.put("design", getPGobject(permitPack.design));
    params.put("bom", getPGobject(permitPack.bom));

    int id = cache.updateBySqlReturningId(ExcelImportQuery.permitInsert, params, "permit_pack_log_nbr").intValue();

    return ResponseEntity.status(HttpStatus.CREATED).body(new ImportResponse(id));
  }

  @GetMapping(value = "/designs/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity getDesignSummary(@NonNull @PathVariable("id") String designId) {
    try {
      return ResponseEntity.ok(aurora.getDesignSummary(designId));
    } catch (Exception e) {
      String msg = "EXCEL_IMPORT: Failed to get design summary for design " + designId;
      log.error(msg, e);
      return ResponseEntity.status(500).body(msg);
    }
  }
  @GetMapping(value = "/designs/{id}/roofSummary", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity getDesignRoofSummary(@NonNull @PathVariable("id") String designId) {
    try {
      return ResponseEntity.ok(aurora.getDesignRoofSummary(designId));
    } catch (Exception e) {
      String msg = "EXCEL_IMPORT: Failed to get design roof summary for design " + designId;
      log.error(msg, e);
      return ResponseEntity.status(500).body(msg);
    }
  }

  @GetMapping(value = "/designs/{id}/rackingArrays", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity getRackingArrays(@NonNull @PathVariable("id") String designId) {
    try {
      return ResponseEntity.ok(aurora.getDesignRackingArrays(designId));
    } catch (Exception e) {
      String msg = "EXCEL_IMPORT: Failed tos get racking arrays for design " + designId;
      log.error(msg, e);
      return ResponseEntity.status(500).body(msg);
    }
  }

  private PGobject getPGobject(Object original) {

    if (original == null) {
      return null;
    }

    try {
      final PGobject pGobject = new PGobject();
      pGobject.setType("jsonb");
      pGobject.setValue(om.writeValueAsString(original));
      return pGobject;
    } catch (Exception e) {
      log.warn("Error creating PGObject for obj={}, msg={}", original, e.getMessage());
      throw new RuntimeException("Error creating object");
    }
  }

  @Data
  public static class Proposal {
    private Date proposalDate;
    private String source;
    private Integer proposalId, projectId;
    private Map<String, Object> proposal;
  }

  @Data
  public static class ProposalResponse extends Proposal {
    private Long id;
  }

  @Data
  public static class Design {
    private Date designDate;
    private String source;
    private Integer designId, projectId;
    private Map<String, Object> design;
    private List<Map<String, Object>> bom;
    private Map<String, Object> originalBom;
  }

  public record ImportResponse(@NotNull Integer id) {
  }

  public record PermitPack(@NotNull Long projectId,
                           Long designLogId,
                           @NotBlank String source,
                           Date permitPackDate,
                           @NotEmpty Map<String, Object> design,
                           @Size List<Map<String, Object>> bom) {
  }

  @Data
  public static class DesignResponse extends Design {
    private Long id;
  }
}
