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
    companyId, systemListId;

  private String name, objectType, processStepName, eventName, customFieldSqlKey, customFieldSql, customFieldSqlSmartlist, projectDetailsColumn;

  private Timestamp dateCreated, dateModified;

  private Boolean archived, hasListValues, allowMultiple;

  private List<Long> systemListOptionIds;

  private List<ListOfValue> listOfValues;

  //These fields are used for smartlist generation
  @JsonIgnore
  private String referenceTable, referenceColumn, joinTable, joinColumn, valueReferenceTable, ppsTable, ppsEventTable, userPositionTable;

  //The system list ID of the custom field attached to this event's resource field
  @JsonIgnore
  private Long eventResourceSystemListId;
}
