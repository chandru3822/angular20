package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Proposal;
import com.albatross.api.v1.flow.model.ProposalLog;
import com.albatross.api.v1.flow.model.ProposalLogExportTemplate;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Adder;
import com.albatross.api.v1.flow.model.propTool.Panel;
import com.albatross.api.v1.flow.services.propTool.PanelService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import com.google.common.collect.Maps;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProposalService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  @Autowired
  private PanelService panelService;

  private final NamedParameterJdbcTemplate jdbc;
  private final SqlCache cache;

  public Optional<Proposal> generateProposal(Proposal prop) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", prop.getProjectId());
    params.put("customerName", prop.getCustomerName());
    params.put("address", prop.getAddress());
    params.put("city", prop.getCity());
    params.put("companyStateId", prop.getCompanyStateId());
    params.put("zipCode", prop.getZipCode());
    params.put("phone", prop.getPhone());
    params.put("email", prop.getEmail());
    params.put("utilityCompanyId", prop.getUtilityCompanyId());

    params.put("productId", prop.getProductId());
    params.put("loanTerm", prop.getLoanTerm());
    params.put("interestRate", prop.getInterestRate());
    params.put("downPayment", prop.getDownPayment());
    params.put("promotion", prop.getPromotion());

    params.put("numberOfEcobees", prop.getNumberOfEcobees());
    params.put("numberOfLeds", prop.getNumberOfLeds());
    params.put("monitor", prop.getMonitor());

    params.put("auroraDesignId", prop.getAuroraDesignId());
    params.put("yearOutput", prop.getYearOutput());
    params.put("numberOfPanels", prop.getNumberOfPanels());
    params.put("panelId", prop.getPanelId());
    params.put("inverterId", prop.getInverterId());

    params.put("proposalCreatedBy", prop.getProposalCreatedBy());
    params.put("qaCompletedBy", prop.getQaCompletedBy());
    params.put("notes", prop.getNotes());


    // TODO: TOTAL SYSTEM PRICE = ???
    params.put("totalSystemPrice", 0);
    // TODO: OFFSET =  =AggLookups!$B$15 <-- Loan
    params.put("offsetVal", 0);
    Optional<Panel> panel = panelService.getPanel(prop.getPanelId());
    Double productionFactor = 0.0;
    if (panel.isPresent()) {
      productionFactor = prop.getYearOutput() / (prop.getNumberOfPanels() * panel.get().getWattage());
    }
    params.put("productionFactor", productionFactor);

    Long id;
    if(null != prop.getId()) {
      id = prop.getId();
      params.put("modifiedById", user.getId());
      params.put("id", id);
      sqlCache.update("propToolProposal.update", params);

      if (prop.getAddersChanged()) {
        params.put("proposalId", id);
        sqlCache.update("propToolProposal.deleteAdders", params);
        for (Adder adder: prop.getAdders()) {
          params.put("proposalId", id);
          params.put("adderId", adder.getId());
          sqlCache.update("propToolProposal.insertAdder", params);
        }
      }
    } else {
      Long proposalNumber = jdbc.queryForObject(cache.getByKey("propToolProposal.import.sqlId"), Maps.newHashMap(), Long.class);

      params.put("createdById", user.getId());
      params.put("companyId", user.getCompanyId());
      params.put("proposalNumber", proposalNumber);

      id = sqlCache.updateReturningId("propToolProposal.insert", params, "id").longValue();

      for (Adder adder: prop.getAdders()) {
        params.put("proposalId", id);
        params.put("adderId", adder.getId());
        sqlCache.update("propToolProposal.insertAdder", params);
      }
    }


    return getProposal(id);
  }

  public List<Proposal> getProposalsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Proposal> results = sqlCache.query("propToolProposal.getAllForCompany", params, new ProposalService.ProposalMapper<>(Proposal.class, om));
    return results;
  }

  public Optional<Proposal> getProposal(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Proposal> results = sqlCache.get("propToolProposal.getOne", params, new ProposalService.ProposalMapper<>(Proposal.class, om));
    return results;
  }

  public Page<Proposal> searchProposals(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());
    List<Proposal> proposals = sqlCache.query("propToolProposal.search", params, new ProposalService.ProposalMapper<>(Proposal.class, om));
    Integer total = sqlCache.queryForObject("propToolProposal.searchCount", params, Integer.class);
    return new PageImpl<>(proposals, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), total);
  }

  public ResponseEntity exportProposalLog(String startDate, String endDate) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("startDate", java.sql.Date.valueOf(startDate));
    params.put("endDate", java.sql.Date.valueOf(endDate));

    List<ProposalLog> results = sqlCache.query("propToolProposal.exportProposalLog", params, ProposalLog.class);

    // set up CSV writing
    CsvMapper mapper = new CsvMapper();
    CsvSchema schema = mapper.typedSchemaFor(ProposalLogExportTemplate.class).withHeader();
    ObjectWriter writer = mapper.writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    // get proposal log deets and write to CSV
    try (SequenceWriter outToBuffer = writer.writeValues(buffer)) {
      // first, get deets
      Collection<ProposalLogExportTemplate> details = Collections2.transform(
        results,
        ProposalLogExportTemplate::from);

      // next, write them to a buffer so we can identify errors before writing across the network
      outToBuffer.writeAll(details);
      outToBuffer.flush();

      // finally, write to network because no errors were encountered
      return ResponseEntity.ok(buffer.toString(StandardCharsets.UTF_8));
    } catch (IOException e) {
      log.error("PROP: Encountered error while writing proposal log to CSV", e);
      return ResponseEntity.status(500)
        .body("Encountered error while writing proposal log export to CSV");
    }
  }

  public static class ProposalMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProposalMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Adder>> propAdderRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "adders",
        new JsonCollectionDeserializer(propAdderRef, objectMapper));
    }
  }

}
