package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class FeatureAccessControl {

  private Long id, accessControlId, companyFeatureId, featureId;
  private String accessLevel, accessCode, featureName, featureCode;
  private boolean archived, enabled, hidden;
  private boolean dirty = false;

}

