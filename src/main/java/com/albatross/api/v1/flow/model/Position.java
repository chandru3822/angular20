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

  private Long id, orgTypeId;
  private String position, orgType;
  private Boolean archived, schedulable, availableToChildren;

  private Boolean edit = false;

  private List<CompanyFeature> companyFeatures;

}

