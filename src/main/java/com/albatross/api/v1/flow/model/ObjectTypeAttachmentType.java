package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.Date;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
public class ObjectTypeAttachmentType {

  private Long id, attachmentTypeId, createdById, modifiedById, companyId, displayOrder, primaryId;
  private String attachmentType;
  private Boolean archived, readOnly, linkable, focused, allowUpload, hasFieldsAssigned;
  private Date dateCreated, dateModified;
  private List<CustomFieldGroup> customFieldGroups;
  private List<Long> objectCategoryIds;
}

