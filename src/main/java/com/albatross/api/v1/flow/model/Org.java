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
public class Org {

  private Long id, companyId, parentOrgId, orgTypeId, orgLevelId, stateId;
  private String orgName, orgType, parentOrgName, title; //title used for scheduling tool (@randa why am I using this instead of orgName?)
  private Boolean activeFlag, owningOrg, useSchedule;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}

