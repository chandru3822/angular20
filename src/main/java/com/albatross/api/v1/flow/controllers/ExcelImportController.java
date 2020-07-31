package com.albatross.api.v1.flow.controllers;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.albatross.api.aurora.AuroraProxy;
import com.albatross.api.utils.Params;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.util.Assert;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.albatross.api.v1.flow.model.User;
import com.albatross.api.security.SecurityService;

import com.albatross.api.utils.SqlCache;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Maps;

import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import static org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR;

/**
 * Created by John on 6/8/20.
 */
@Slf4j
@RestController
@RequestMapping(value = "/api/v1/excel")
public class ExcelImportController {

  @Autowired
  private AuroraProxy aurora;

  @Autowired
  private SqlCache cache;

  @Autowired
  private NamedParameterJdbcTemplate jdbc;

  @Autowired
  private SecurityService security;

  @Autowired
  ObjectMapper om;

  @GetMapping("/excelId")
  public Long getUniqueIdForExcel() {
    String sql = cache.getByKey("excel.import.sqlId");
    Long id = jdbc.queryForObject(sql, Maps.newHashMap(), Long.class);
    return id;
  }

   @GetMapping("/baseConfirm/{baseId}")
   public ResponseEntity getUniqueIdForExcel(@PathVariable("baseId") Long projectId, @RequestHeader Map<String, String> headers) {
       debugPrintHeaders(headers);
       String sql = cache.getByKey("excel.import.validateProjectId");
       try {
           Map<String, Object> result = jdbc.queryForObject(sql, new Params("projectId", projectId).buildNullable(), new ColumnMapRowMapper());
           return ResponseEntity.ok(result);
       } catch(IncorrectResultSizeDataAccessException e) {
           if( e.getActualSize() < 1 ){
               log.info("Could not find project identified by Project id {}.", projectId);
               return ResponseEntity.notFound().build();
           }
           log.error("Encountered error retrieving project with Project id {}", projectId, e);
           return ResponseEntity.status(INTERNAL_SERVER_ERROR).body("Encountered error retrieving project with Project id " + projectId);
       } catch(Exception e) {
           log.error("Encountered error retrieving project with Project id {}", projectId, e);
           return ResponseEntity.status(INTERNAL_SERVER_ERROR).body("Encountered error retrieving project with Project id " + projectId);
       }
   }

  private void debugPrintHeaders(Map<String, String> headers) {
    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    log.debug(headers + "; " + headers);
    log.debug("Received request for ExcelId:\n{}", baos.toString());
  }

    @GetMapping("/baseConfirm/{baseId}/proposals/{proposalId}")
    public ResponseEntity<String> getProposalData(@PathVariable("baseId") Long projectId,
                                                  @PathVariable("proposalId") Long proposalId) {
        Map <String, Object> params = ImmutableMap.of("projectId", projectId,
            "proposalId", proposalId);

        String sql = cache.getByKey("excel.import.loadProposal");
        List<String> results = jdbc.queryForList(sql, params, String.class);

        if (results.isEmpty()) {
            String msg = "Found no proposals for " + params;
            log.warn(msg);
            return ResponseEntity.notFound().build();
        } else if(results.size() > 1) {
            log.warn("Found {} proposals for params {}. Returning the most recent.",
                results.size(), params);
        }

        return ResponseEntity.ok(results.get(0));
    }

  @PostMapping(value = "/import", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> importProposal(HttpServletRequest req,
                                        @RequestBody Proposal proposal) {
    log.info("Attempting Excel Proposal Log");

    Assert.notNull(proposal, "Proposal Required");
    Assert.hasText(proposal.getSource(), "Source is required; must have text");

    String source = String.format("%s – %s", proposal.getSource(), req.getRemoteAddr());
    proposal.setSource(source);

    Map<String, Object> json = proposal.getProposal();
    Integer propId = null, projectId = null;
    if (json != null) {
        propId = (Integer) json.get("Proposal ID");
        projectId = (Integer) json.get("Base Deal ID");
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("proposal", proposal.getProposal());
    params.put("source", proposal.getSource());
    params.put("proposalDate", new Date());
    params.put("proposalId", propId);
    params.put("projectId", projectId);

    Optional<ProposalResponse> created = cache.get("excel.import.insert", params,
        (rs, rowNum) -> {
            try {
                ProposalResponse pr = new ProposalResponse();
                pr.setId(rs.getLong("id"));
                pr.setSource(rs.getString("source"));
                pr.setProjectId(rs.getInt("project_id"));
                pr.setProposalDate(rs.getDate("proposal_date"));
                pr.setProposalId(rs.getInt("proposal_nbr"));
                pr.setProposal(om.readValue(rs.getString("proposal"),
                    new TypeReference<Map<String, Object>>() {}));
                return pr;
            } catch (IOException e) {
                throw new SQLException(e);
            }
        });

    if (!created.isPresent()) {
      throw new IllegalStateException("Did not get back a created proposal_log");
    }

    log.info("Created Excel Proposal Log id={}", created.get().getId());

    return ResponseEntity
      .status(HttpStatus.CREATED)
      .body(created.get());
  }

  //design stuff
  @GetMapping(value = "/design/excelId", produces = MediaType.APPLICATION_JSON_VALUE)
  public Long getUniqueIdForDesignExcel(HttpServletResponse res, @RequestHeader Map<String, String> headers) {
    debugPrintHeaders(headers);
    String sql = cache.getByKey("excel.import.design.sqlId");
    Long id = jdbc.queryForObject(sql, Maps.newHashMap(), Long.class);
    return id;
  }

  @PostMapping(value = "/design/import", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity<?> designImport(HttpServletRequest req,
                                        @RequestBody Design design) {
    log.info("Attempting Excel Design Log");

    Assert.notNull(design, "Design Required");
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    Optional<String> username = Optional.ofNullable(auth.getPrincipal().toString());
    User user = username.map(security::getUser)
      .orElseThrow(() -> new IllegalArgumentException("Unknown user passed in: " + username.get()));

    Assert.hasText(design.getSource(), "Source is required; must have text");
    String source = String.format("%s – %s – %s", user.getEmail(), design.getSource(), req.getRemoteAddr());
    design.setSource(source);

    Map<String, Object> json = design.getDesign();
    Integer designId = null, projectId = null;
    if( json != null ){
      designId = (Integer) json.get("Design ID");
      projectId = (Integer) json.get("Base Deal ID");
    }

    Map<String, Object> bomJson = design.getBom();
    Iterator it = bomJson.entrySet().iterator();
    while (it.hasNext()) {
      Map.Entry entry = (Map.Entry)it.next();
      String key = entry.getKey().toString();
      if (key.trim().isEmpty()) {
        it.remove();
      }
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("design", design.getDesign());
    params.put("source", design.getSource());
    params.putIfAbsent("designDate", new Date());
    params.putIfAbsent("designId", designId);
    params.putIfAbsent("projectId", projectId);
    params.putIfAbsent("bom", bomJson);
      Optional<DesignResponse> created = cache.get("excel.import.design.insert", params,
          (rs, rowNum) -> {
              try {
                  DesignResponse dr = new DesignResponse();
                  dr.setId(rs.getLong("id"));
                  dr.setSource(rs.getString("source"));
                  dr.setProjectId(rs.getInt("project_id"));
                  dr.setDesignDate(rs.getDate("design_date"));
                  dr.setDesignId(rs.getInt("design_nbr"));
                  dr.setBom(om.readValue(rs.getString("bom"),
                      new TypeReference<Map<String, Object>>() {}));
                  return dr;
              } catch (IOException e) {
                  throw new SQLException(e);
              }
          });

    if (!created.isPresent()) {
      throw new IllegalStateException("Did not get back a created design_log");
    }

    log.info("Created Excel Design Log id={}", created.get().getId());

    return ResponseEntity
      .status(HttpStatus.CREATED)
      .body(created.get());
  }

  @GetMapping(value = "/designs/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ResponseEntity getDesignSummary(@NonNull @PathVariable("id") String designId) {
    try {
      return ResponseEntity.ok(aurora.getDesignSummary(designId));
    } catch (Exception e) {
      String msg = "Failed to get design summary for design " + designId;
      log.error(msg, e);
      return ResponseEntity.status(500).body(msg);
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
    private Map<String, Object> bom;
  }

  @Data
  public static class DesignResponse extends Design {
    private Long id;
  }
}
