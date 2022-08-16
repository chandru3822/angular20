package com.albatross.api.v1.flow.model.event;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class EventAttachmentType {

  private Long id, eventId, attachmentTypeId, createdById, modifiedById, companyId, displayOrder, processStepId; //i needed the processStepId only and didn't want to make another object. sry.
  private String attachmentType;
  private Boolean archived, readOnly, hasFieldsAssigned;
  private Date dateCreated, dateModified;
}

