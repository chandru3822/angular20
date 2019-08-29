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

  private Long id, processId, companyId, orgId, createdById, modifiedById;
  // originalProcessStepName used for frontend validation (without having to loop to populate it on frontend)
  private String orgName, processStepName, originalProcessStepName;
  private Boolean archived;
  private Date dateCreated, dateModified;

  private List<CustomFieldGroupType> customFieldGroupTypes;
  private List<ProcessStepAttachmentType> attachmentTypes;
  private List<ProcessStepLink> links;
}

