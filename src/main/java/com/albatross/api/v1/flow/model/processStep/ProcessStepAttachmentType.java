package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.CustomFieldGroup;
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
public class ProcessStepAttachmentType {

  private Long id, attachmentTypeId, createdById, modifiedById, processStepId, displayOrder;
  private String attachmentType;
  private Boolean archived, linkable, focused, allowUpload, hasFieldsAssigned;
  private Date dateCreated, dateModified;
  private List<CustomFieldGroup> customFieldGroups;
}

