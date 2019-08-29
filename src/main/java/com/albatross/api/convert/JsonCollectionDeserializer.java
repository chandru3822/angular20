package com.albatross.api.convert;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;

import java.beans.PropertyEditorSupport;
import java.io.IOException;
import java.lang.reflect.ParameterizedType;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@RequiredArgsConstructor
public class JsonCollectionDeserializer<E> extends PropertyEditorSupport {

  private final TypeReference<?> typeReference;
  private final ObjectMapper objectMapper;

  @Override
  public void setValue(Object value) {
    if (value == null) {

      if (ParameterizedType.class.isAssignableFrom(this.typeReference.getType().getClass())) {
        Class type = (Class) ((ParameterizedType) this.typeReference.getType()).getRawType();
        if (List.class.isAssignableFrom(type)) {
          value = new ArrayList<>();
        } else if (Set.class.isAssignableFrom(type)) {
          value = new HashSet<>();
        }
      }
    } else {
      try {
        value = this.objectMapper.readValue(value.toString(), this.typeReference);
      } catch (IOException e) {
        throw new RuntimeException("Could not deserialize collection of " + this.typeReference.getType().toString(), e);
      }
    }

    super.setValue(value);
  }
}
