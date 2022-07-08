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
public class ObjectTypeAttachmentType {

  private Long id, attachmentTypeId, createdById, modifiedById, companyId, displayOrder;
  private String attachmentType;
  private Boolean archived;
  private Date dateCreated, dateModified;
  private List<CustomFieldGroup> customFieldGroups;
}

