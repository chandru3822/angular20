package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.OwningPosition;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStep {

  private Long id, companyProcessId, companyId, createdById, modifiedById;
  // originalProcessStepName used for frontend validation (without having to loop to populate it on frontend)
  private String processStepName, originalProcessStepName;
  private Boolean archived, nonAdminAdd;
  private Date dateCreated, dateModified;

  private List<CustomFieldGroup> customFieldGroups;
  private List<ProcessStepAttachmentType> attachmentTypes;
  private List<ProcessStepLink> links;

  private List<OwningPosition> owningPositions;

  private List<ProcessStepWorkQueueType> workQueueTypes;
  private List<ProcessStepCompanyProcessStepStatusType> companyProcessStepStatusTypes;
}

