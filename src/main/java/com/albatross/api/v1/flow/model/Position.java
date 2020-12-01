package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 10/1/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Position {

  private Long id, orgTypeId, orgLevelId, level;
  private String position, orgType;
  private Boolean archived, schedulable, scheduler, availableToChildren, contactOwner, projectOwner, projectOwnerReadonly;

  //until i figure out how to do a v-select with the list using one key and the value using a different key i need this:
  private Long positionId;

  private Boolean edit = false;

  private List<CompanyFeature> companyFeatures;

}

