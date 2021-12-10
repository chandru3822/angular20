package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class SmartlistFieldAssignment {

  //@TODO humes: customField brings in fields making some direct fields on this class redundant. Remove the direct redundant fields

  private Long id, smartlistId, smartlistFieldId, customFieldGroupAssignmentId, createdById, modifiedById,
      displayOrder, processStepId, eventId, processStepEventId, dataTypeId, objectTypeId, companySystemListId, systemListTypeId, smartlistSystemListId,
      companyId, systemListId;

  private String name, objectType, processStepName, eventName, customFieldSqlKey, projectDetailsColumn;

  private Timestamp dateCreated, dateModified;

  private Boolean archived, hasListValues, allowMultiple;

  private List<Long> systemListOptionIds;

  private List<ListOfValue> listOfValues;

  private CustomField customField;


  // The fields below are used for smartlist generation
  @JsonIgnore
  private String referenceTable, referenceColumn, valueReferenceTable, valueEventReferenceTable, joinTable, joinColumn, ppsTable, userPositionTable, ppsEventTable;

}
