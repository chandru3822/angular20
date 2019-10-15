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

  private Long id, companyId, parentOrgId, orgTypeId, orgLevelId;
  private String orgName, orgType, parentOrgName;
  private Boolean activeFlag, owningOrg;

  //so far this is only used for saving
  List<CustomFieldGroup> customFieldGroups;
}

