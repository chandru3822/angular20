package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;
import java.util.List;

@Data
@NoArgsConstructor
public class ProjectWithEvents {

  //i could probably do this in the other project model but this endpoint is only for mobile so i couldn't decide
  private Long id, contactId;
  private String projectName;

  private List<ProjectEvent> events;

  @Data
  public static class ProjectEvent {
    private Long projectProcessStepId, processStepId, eventTypeId;
    private String processStepName, resourceName;
    private Timestamp start, end;
  }
}
