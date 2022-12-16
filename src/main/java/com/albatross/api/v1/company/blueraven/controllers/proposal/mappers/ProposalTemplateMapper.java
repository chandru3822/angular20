package com.albatross.api.v1.company.blueraven.controllers.proposal.mappers;

import com.albatross.api.convert.JsonObjectDeserializer;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTheme;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.List;

public class ProposalTemplateMapper extends BeanPropertyRowMapper<ProposalTemplate> {
  private final ObjectMapper objectMapper;

  public ProposalTemplateMapper(ObjectMapper objectMapper) {
    super(ProposalTemplate.class);
    this.objectMapper = objectMapper;
  }

  @Override
  protected void initBeanWrapper(BeanWrapper bw) {
    super.initBeanWrapper(bw);

    final TypeReference<ProposalTheme> proposalThemeTypeReference = new TypeReference<>() {
    };
    final TypeReference<List<ProposalTemplateBlock>> blockTypeReference = new TypeReference<>() {
    };
    bw.registerCustomEditor(
      ProposalTheme.class,
      "theme",
      new JsonObjectDeserializer<>(proposalThemeTypeReference, objectMapper));
    bw.registerCustomEditor(
      List.class, "blocks", new JsonObjectDeserializer<>(blockTypeReference, objectMapper));
  }
}
