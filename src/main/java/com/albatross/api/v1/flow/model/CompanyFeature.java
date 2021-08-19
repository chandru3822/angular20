package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CompanyFeature {

  private Long id, companyId, featureId;
  private String featureName, featureCode;
  private Boolean archived, hidden;
  //i know this is BAD, but i'm just trying to patch this really quickly to not take so freaking long!
  private boolean dirty = false;

  private List<FeatureAccessControl> accessControl;

}

