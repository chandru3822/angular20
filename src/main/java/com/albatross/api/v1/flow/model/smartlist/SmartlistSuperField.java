package com.albatross.api.v1.flow.model.smartlist;

import com.albatross.api.v1.flow.model.ListOfValue;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.sql.Timestamp;
import java.util.List;

@Data
public class SmartlistSuperField {
  private Long id, smartlistId, smartlistFieldId, customFieldGroupAssignmentId, createdById, modifiedById,
    displayOrder, processStepId, eventId, processStepEventId, dataTypeId, objectTypeId, companySystemListId, systemListTypeId, smartlistSystemListId,
    companyId, systemListId, eventResourceSystemListId;

  private String name, objectType, processStepName, eventName, projectDetailsColumn;

  private String customFieldSqlKey, customFieldSql, customFieldSqlSmartlist;

  private Timestamp dateCreated, dateModified;

  private Boolean archived, hasListValues, allowMultiple;

  private List<Long> systemListOptionIds;

  private List<ListOfValue> listOfValues;

  private FieldUpdateType updateType;

  //These fields are used for smartlist generation
  @JsonIgnore
  private String referenceTable, referenceColumn, joinTable, joinColumn, valueReferenceTable, ppsTable, ppsEventTable, userPositionTable;
}
