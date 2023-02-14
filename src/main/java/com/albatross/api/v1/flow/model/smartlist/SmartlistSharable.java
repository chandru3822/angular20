package com.albatross.api.v1.flow.model.smartlist;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
public class SmartlistSharable {

  private Long id, smartlistId, orgId, userPositionId, createdById, modifiedById;

  private String name, position;

  private Boolean archived, isUser, isOrg;

  private Timestamp dateCreated, dateModified;

}
