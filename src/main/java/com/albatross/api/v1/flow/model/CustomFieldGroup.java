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
public class CustomFieldGroup {

  private Long id, objectTypeId, groupOrder, processStepId;
  // originalGroupName used for frontend validation (without having to loop to populate it on frontend)
  private String groupName, objectType, originalGroupName;
  private Boolean archived;

  private List<CustomField> customFields;

  // todo: ask unicorn boy about this - can't update dom value of key not already stored on object. re: object types -> custom field groups -> edit group name
  private Boolean edit = false;
}

