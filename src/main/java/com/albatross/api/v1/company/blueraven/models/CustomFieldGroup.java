package com.albatross.api.v1.company.blueraven.models;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class CustomFieldGroup {

  private Long id, objectTypeId, groupOrder;
  private String groupName, objectType;
  private Boolean archived;

  // todo: cant remember what this is
  // This list is used when looking at custom field ASSIGNMENTS to a group
  private List<CustomField> customFields;

  // This list is used when looking at custom field VALUES in a group
  private List<CustomFieldValue> customFieldValues;

  // randa is dumb and struggles with updating certain values in the dom when they aren't on the obj
  // to begin with
  private Boolean edit = false;
}
