package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

@Getter
@Setter
public class DenyListPosition {

    private Long id, positionId, companyProcessId, denyListTypeId, createdById, modifiedById;
    private Timestamp dateCreated, dateModified;
    private Boolean archived;
}
