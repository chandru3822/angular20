package com.albatross.api.v1.flow.model.project;

import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@NoArgsConstructor
public class ChildProject {

  private Long id;
  private String projectName;
  private List<CustomFieldValue> customFieldValues;

}
