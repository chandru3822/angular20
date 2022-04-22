package com.albatross.api.v1.flow.model.org;

import com.albatross.api.v1.flow.model.CustomFieldGroup;
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


  private Long id, companyId, parentOrgId, orgTypeId, orgLevelId, companyStateId, stateId, parentOrgTypeId, defaultAppointmentLength, orgId, companyTimezoneId;
  private String orgName, orgType, parentOrgName, title; //title used for scheduling tool
  private Boolean activeFlag, schedulable, availableToChildren, showType, archived;

  //when getting orgs for scheduling, I had to "type" the id by putting a 1 in front of it. this field should only be used in the scheduling tool
  private Long masterId;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}

