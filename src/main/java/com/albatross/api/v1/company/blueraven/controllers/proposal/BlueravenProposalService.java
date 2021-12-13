package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.Proposal;
import com.albatross.api.v1.company.blueraven.models.ProposalDesign;
import com.albatross.api.v1.company.blueraven.models.ProposalProject;
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
  private final ObjectMapper om;;

  public Page<ProposalProject> getProposalProjects(String query, Pageable pageable) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ProposalProject> results = sqlCache.query("proposals.getProjects", params, ProposalProject.class);
    Integer count = sqlCache.queryForObject("proposals.getProjectsCount", params, Integer.class);

    Page<ProposalProject> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  public List<ProposalDesign> getProposalDesigns(Long projectId) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    List<ProposalDesign> results = sqlCache.query("proposals.getDesigns", params, new ProposalDesignMapper<>(ProposalDesign.class, om));
    return results;
  }

  public Optional<Proposal> getProposal(Long proposalId) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("proposalId", proposalId);

    Optional<Proposal> result = sqlCache.get("proposals.get", params, Proposal.class);
    return result;
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

}
