package com.albatross.api.v1.flow.model.smartlistv1;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class SmartlistLogic {

  private Long id, smartlistId, smartlistRequirementId, operationTypeId, sqlOrder, createdById, modifiedById, displayOrder;

  private String operationType, operationCode;

  private Timestamp dateCreated, dateModified;

  private Boolean archived;
}
