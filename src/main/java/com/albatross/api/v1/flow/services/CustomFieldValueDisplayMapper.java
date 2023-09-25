package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonObjectDeserializer;
import com.albatross.api.v1.flow.model.CustomFieldValueDisplay;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.List;

@RequiredArgsConstructor
class CustomFieldValueDisplayMapper extends BeanPropertyRowMapper<CustomFieldValueDisplay> {
  private final ObjectMapper om;

  public CustomFieldValueDisplayMapper(Class<CustomFieldValueDisplay> mappedClass, ObjectMapper objectMapper) {
    super(mappedClass);
    this.om = objectMapper;
  }

  @Override
  protected void initBeanWrapper(BeanWrapper bw) {
    TypeReference<List<Integer>> customFieldValueRef = new TypeReference<>() {
    };
    bw.registerCustomEditor(List.class, "intArrayValue",
      new JsonObjectDeserializer<>(customFieldValueRef, om));
  }
}
