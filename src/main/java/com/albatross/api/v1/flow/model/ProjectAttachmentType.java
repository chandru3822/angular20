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
public class ProjectAttachmentType {

  private Long id, attachmentTypeId, createdById, modifiedById, companyId, displayOrder;
  private String attachmentType;
  private Boolean archived, readOnly, includesPsType;
  private Date dateCreated, dateModified;
  //could do the frontend if i was a better developer _rn
  private Boolean showNonPrimary = false;
}

