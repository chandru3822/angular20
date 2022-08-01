package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
public class CustomFieldWithDefault extends CustomField {

  private Long defaultFieldId;

}
