package com.albatross.api.v1.flow.model.project;

import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepEvent;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class ProjectWithEvents {

  //i could probably do this in the other project model but this endpoint is only for mobile so i couldn't decide
  private Long id, contactId;
  private String projectName;

  private List<ProjectProcessStepEvent> events;
}
