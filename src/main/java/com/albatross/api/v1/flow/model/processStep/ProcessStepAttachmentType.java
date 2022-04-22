package com.albatross.api.v1.flow.model.processStep;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepAttachmentType {

  private Long id, attachmentTypeId, createdById, modifiedById, processStepId, displayOrder;
  private String attachmentType;
  private Boolean archived;
  private Date dateCreated, dateModified;
}

