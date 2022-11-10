package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class AttachmentType {
  private Long id, keyPatternId, companyId;
  private String attachmentType, keyPattern;
  private Boolean archived;
  private List<CustomFieldGroup> customFieldGroups;
}
