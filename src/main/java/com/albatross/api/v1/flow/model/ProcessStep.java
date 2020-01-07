package com.albatross.api.v1.flow.model;

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

  private Long id, processId, companyId, orgId, createdById, modifiedById, workTypeId;
  // originalProcessStepName used for frontend validation (without having to loop to populate it on frontend)
  private String orgName, processStepName, originalProcessStepName;
  private Boolean archived;
  private Date dateCreated, dateModified;

  private List<CustomFieldGroup> customFieldGroups;
  private List<ProcessStepAttachmentType> attachmentTypes;
  private List<ProcessStepLink> links;
}

