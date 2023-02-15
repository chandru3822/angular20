package com.albatross.api.v1.flow.model.smartlist;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
public class SmartlistAccessControl {

  private Long id, smartlistId, orgId, userPositionId, accessControlId, createdById, modifiedById;

  private String name, position, accessLevel;

  private Boolean archived, isUser, isOrg;

  private Timestamp dateCreated, dateModified;

}
