package com.albatross.api.v1.flow.model;

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

  private Long id, eventId, attachmentTypeId, createdById, modifiedById, companyId, displayOrder;
  private String attachmentType;
  private Boolean archived, readOnly;
  private Date dateCreated, dateModified;
}

