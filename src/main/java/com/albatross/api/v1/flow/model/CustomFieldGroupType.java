package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CustomFieldGroupType {

  private Long id, objectTypeId, groupOrder, processStepId;
  // originalGroupName used for frontend validation (without having to loop to populate it on frontend)
  private String groupName, objectType, originalGroupName;
  private Boolean archived;

  List<CustomField> customFields;
}

