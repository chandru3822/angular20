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
  private Boolean archived;

  private List<FeatureAccessControl> accessControl;

}

