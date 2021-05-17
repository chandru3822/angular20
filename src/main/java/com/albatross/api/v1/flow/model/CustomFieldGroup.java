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

  private Long id, companyObjectTypeId, objectTypeId, companyObjectTypeTabId, groupOrder, processStepId, eventId, eventTypeId, uniqueBehaviorTypeId, companyObjectTypeTabDisplayOrder;
  // originalGroupName used for frontend validation (without having to loop to populate it on frontend)
  private String groupName, objectType, originalGroupName, eventType, tabName;
  private Boolean archived;

  // This list is used when looking at custom field ASSIGNMENTS to a group
  private List<CustomField> customFields;

  // This list is used when looking at custom field VALUES in a group
  //@TODO: @randa, maybe CustomFieldValue should inherit from CustomField to keep it more DRY?
  private List<CustomFieldValue> customFieldValues;

  // This list is used when saving a new group as a schedulable group, which by default will have a specified set of fields
  private List<CustomField> schedulingFields;

  // todo: ask unicorn boy about this - can't update dom value of key not already stored on object. re: object types -> custom field groups -> edit group name
  private Boolean edit = false;
  private Boolean showColor = false;
}

