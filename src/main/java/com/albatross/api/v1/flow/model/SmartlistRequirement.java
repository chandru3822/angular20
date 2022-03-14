package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class SmartlistRequirement extends SmartlistSuperField {

  //@TODO humes: should probably make this have a field of type SmartlistField since it uses most of those fields anyways

  private Long operatorTypeId, dataTypeRequirementId, listOfValueId, systemListOptionId, customSqlOptionId;

  private String requirementValue, secondaryRequirementValue, operatorType;

  private Boolean immutable, isCustomValue;

  private List<Long> listOfValueIds;

  private List<ListOfValue> availableListOfValues;

  private DataTypeRequirement dataTypeRequirement;

  //Used for smartlist generation
  @JsonIgnore
  private String valueReferenceTable, valueEventReferenceTable;

  @JsonIgnore
  private CustomField customField;
}
