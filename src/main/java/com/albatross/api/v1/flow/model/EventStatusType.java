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
public class EventStatusType {

  private Long id, companyId, resourceCustomFieldId;
  private String eventName;
  private Boolean archived;
  private List<CustomFieldGroup> customFieldGroups;
  private List<EventCompanyEventStatusType> companyEventStatusTypes;
}

