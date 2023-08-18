package com.albatross.api.v1.flow.model.project;

import com.albatross.api.v1.flow.model.Attachment;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@NoArgsConstructor
public class ProjectStatusField {

  //id = companyProjectStatusTypeId
  private Long id, projectStatusTypeId, displayOrder;

  private String description, projectStatusType, rootProjectStatusType, iconTag;

  private List<AssignedField> assignedFields;

  @Data
  public static class AssignedField {
    Long id, dataTypeId;
    String fieldValue, fieldName;
  }
}
