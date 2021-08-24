package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
public class ProjectEvent {

    private Long projectProcessStepEventId, projectProcessStepId, processStepEventId, processStepId,
      projectId, eventStatusTypeId, companyEventStatusTypeId, processStepStatusTypeId, resourceId;
    private String processStepName, resourceName, eventName, eventType, phone, mobile, eventStatusType, lastUpdated, dateCreated;
    private Timestamp start, end;
}
