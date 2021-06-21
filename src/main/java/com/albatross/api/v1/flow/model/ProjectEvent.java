package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
public class ProjectEvent {

  //@randa todo //eventTypeId will be going away
    private Long projectProcessStepEventId, projectProcessStepId, processStepId, projectId, eventTypeId, eventStatusTypeId, companyEventStatusTypeId;
    private String processStepName, resourceName, eventName, eventType, phone, mobile, eventStatusType, lastUpdated, dateCreated;
    private Timestamp start, end;
}
