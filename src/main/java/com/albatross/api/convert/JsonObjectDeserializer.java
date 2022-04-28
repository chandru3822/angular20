package com.albatross.api.convert;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.postgresql.util.PGobject;

import java.beans.PropertyEditorSupport;


public class JsonObjectDeserializer<T> extends PropertyEditorSupport {
  private final TypeReference<?> typeReference;
  private final ObjectMapper objectMapper;

  public JsonObjectDeserializer(TypeReference<T> typeReference, ObjectMapper objectMapper) {
    this.typeReference = typeReference;
    this.objectMapper = objectMapper;
  }

  public JsonObjectDeserializer(ObjectMapper objectMapper) {
    this(new TypeReference<T>() {
    }, objectMapper);
  }


  @Override
  public void setValue(Object value) {
    if (value instanceof PGobject pgObj) {
      try {
        final Object omValue = objectMapper.readValue(pgObj.getValue(), typeReference);
        super.setValue(omValue);
      } catch (JsonProcessingException e) {
        throw new RuntimeException(e);
      }
    }
  }
}
