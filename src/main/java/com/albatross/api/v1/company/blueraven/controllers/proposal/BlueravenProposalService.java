package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class BlueravenProposalService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldGroupService blueravenCustomFieldGroupService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Page<ProposalProject> getProposalProjects(String query, Pageable pageable) {
    securityService.validateCompanyAccess(3L);
    HashMap<String, Object> params = new HashMap<>();
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ProposalProject> results = sqlCache.query("proposal.getProjects", params, ProposalProject.class);
    Integer count = sqlCache.queryForObject("proposal.getProjectsCount", params, Integer.class);

    Page<ProposalProject> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  public List<ProposalDesign> getProposalDesigns(Long projectId) {
    securityService.validateCompanyAccess(3L);
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    List<ProposalDesign> results = sqlCache.query("proposal.getDesigns", params, new ProposalDesignMapper<>(ProposalDesign.class, om));
    return results;
  }

  public Optional<Proposal> getProposal(Long proposalId) {
    securityService.validateCompanyAccess(3L);
    HashMap<String, Object> params = new HashMap<>();
    params.put("proposalId", proposalId);

    Optional<Proposal> result = sqlCache.get("proposal.get", params, new ProposalMapper<>(Proposal.class, om));

    // handle custom list of values
    result.ifPresent(proposal -> blueravenCustomFieldGroupService.handleCustomListOfValue(proposal.getCustomFieldGroups(), 3L, proposal.getProjectId()));

    return result;
  }

  public Optional<Proposal> updateProposal(Long proposalId, List<CustomFieldValue> cfvs) {
    securityService.validateCompanyAccess(3L);

    blueravenCustomFieldValueService.updateCustomFieldValues(cfvs, proposalId, ObjectType.PROPOSAL.textValue());

    return getProposal(proposalId);
  }

  public Optional<Proposal> addProposal(Proposal proposal) {
    securityService.validateCompanyAccess(3L);

    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", proposal.getProjectProcessStepId());
    params.put("userId", user.getId());

    Long id = sqlCache.updateReturningId("proposal.insert", params, "id").longValue();
    return getProposal(id);
  }

  public static class ProposalDesignMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProposalDesignMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Proposal>> proposalsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "proposals",
        new JsonCollectionDeserializer(proposalsRef, objectMapper));

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
      TypeReference<List<CustomFieldGroup>> cfgRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "customFieldGroups",
        new JsonCollectionDeserializer(cfgRef, objectMapper));

    }
  }

}
