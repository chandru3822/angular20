package com.albatross.api.v1.company.blueraven.controllers.proposal.mappers;

import com.albatross.api.convert.JsonObjectDeserializer;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.Map;

public class ProposalTemplateBlockMapper
  extends BeanPropertyRowMapper<ProposalTemplateBlock> {
  private final ObjectMapper objectMapper;

  public ProposalTemplateBlockMapper(ObjectMapper objectMapper) {
    super(ProposalTemplateBlock.class);
    this.objectMapper = objectMapper;
  }

  @Override
  protected void initBeanWrapper(BeanWrapper bw) {
    super.initBeanWrapper(bw);

    final TypeReference<Map<String, Object>> mapTypeReference = new TypeReference<>() {
    };
    bw.registerCustomEditor(
      Object.class, "blockStyle", new JsonObjectDeserializer<>(mapTypeReference, objectMapper));
    bw.registerCustomEditor(
      Object.class, "blockValue", new JsonObjectDeserializer<>(mapTypeReference, objectMapper));
  }
}
