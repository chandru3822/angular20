package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class SmartlistFieldAssignment {

  //@TODO humes: should probably make this have a field of type SmartlistField since it uses most of those fields anyways

  private Long id, smartlistId, smartlistFieldId, customFieldGroupAssignmentId, createdById, modifiedById,
      displayOrder, processStepId, dataTypeId, objectTypeId, companySystemListId, systemListTypeId;

  private String name, objectType, processStepName, customFieldSqlKey;

  private Timestamp dateCreated, dateModified;

  private Boolean archived, hasListValues, allowMultiple;

  private List<Long> systemListOptionIds;

  private List<ListOfValue> listOfValues;

  @JsonIgnore
  private String referenceTable, referenceColumn;
}
