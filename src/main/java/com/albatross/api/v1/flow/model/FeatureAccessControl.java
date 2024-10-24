package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
public class FeatureAccessControl implements Serializable {

  private Long id, accessControlId, companyFeatureId, featureId;
  private String accessLevel, accessCode, featureName, featureCode;
  private boolean archived, enabled, hidden, usedByFeature;
  private boolean dirty = false;
}
