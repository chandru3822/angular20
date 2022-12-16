package com.albatross.api.v1.company.blueraven.controllers.proposal.mappers;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.List;

public class ProposalMapper<T> extends BeanPropertyRowMapper<T> {
  private final ObjectMapper objectMapper;

  public ProposalMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
    super(mappedClass);
    this.objectMapper = objectMapper;
  }

  @Override
  protected void initBeanWrapper(BeanWrapper bw) {
    TypeReference<List<CustomFieldGroup>> cfgRef = new TypeReference<>() {
    };
    bw.registerCustomEditor(
      List.class, "customFieldGroups", new JsonCollectionDeserializer(cfgRef, objectMapper));
  }
}
