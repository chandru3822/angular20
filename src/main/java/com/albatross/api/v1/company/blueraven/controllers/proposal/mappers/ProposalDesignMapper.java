package com.albatross.api.v1.company.blueraven.controllers.proposal.mappers;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.v1.company.blueraven.models.Proposal;
import com.albatross.api.v1.flow.model.Attachment;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.List;

public class ProposalDesignMapper<T> extends BeanPropertyRowMapper<T> {
  private final ObjectMapper objectMapper;

  public ProposalDesignMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
    super(mappedClass);
    this.objectMapper = objectMapper;
  }

  @Override
  protected void initBeanWrapper(BeanWrapper bw) {
    TypeReference<List<Proposal>> proposalsRef = new TypeReference<>() {
    };
    bw.registerCustomEditor(
      List.class, "proposals", new JsonCollectionDeserializer(proposalsRef, objectMapper));

    TypeReference<List<Attachment>> attachmentsRef = new TypeReference<>() {
    };
    bw.registerCustomEditor(
      List.class, "attachments", new JsonCollectionDeserializer(attachmentsRef, objectMapper));
  }
}
