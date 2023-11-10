package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.v1.company.blueraven.models.ProposalCommissionDetail;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.List;

public class ProposalCommissionMapper<T> extends BeanPropertyRowMapper<T> {
  private final ObjectMapper objectMapper;

  public ProposalCommissionMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
    super(mappedClass);
    this.objectMapper = objectMapper;
  }

  @Override
  protected void initBeanWrapper(BeanWrapper bw) {
    TypeReference<List<ProposalCommissionDetail>> commissionDetailRef = new TypeReference<>() {
    };
    bw.registerCustomEditor(
      List.class,
      "commissionDetails",
      new JsonCollectionDeserializer(commissionDetailRef, objectMapper));
  }
}
