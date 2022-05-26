package com.albatross.api.v1.flow.model.projectProcessStep;

import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.Owner;
import lombok.Data;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;

@Data
public class ProjectProcessStep {

  //@TODO: This repeats a lot of the stuff the ProcessStep model does and should probably inherit from it

  private Long projectProcessStepId, processStepId, projectId, processStepStatusTypeId, processStepProcessId, companyProcessStepStatusTypeId,
    parentProjectProcessStepId, companyProjectStatusTypeId, projectStatusTypeId;

  private String processStepName, processStepStatusType;

  private Date dateCreated;

  private LocalDate lastUpdated, processStepCompleteDate;

  private Boolean main;

  private List<ProjectProcessStepAction> actions, banners;

  private Owner owner;

  //so far this is only used for saving
  // @TODO: Move saving this to the CustomFieldValue controller so this prop can be killed (like how the project level fields are updated)
  List<CustomFieldGroup> customFieldGroups;

  private List<ProjectProcessStepRequirement> autoTriggeredActionRequirements;
  private List<ProjectProcessStepEvent> projectProcessStepEvents;
}
