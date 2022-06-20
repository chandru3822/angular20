package com.albatross.api.security;

import com.albatross.api.v1.flow.model.FeatureAccessControl;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;

@RequiredArgsConstructor
public final class FeatureAccessControlGrantedAuthority implements GrantedAuthority {
  private final FeatureAccessControl featureAccessControl;

  @Override
  public String getAuthority() {
    return featureAccessControl.getFeatureCode() + "_" + featureAccessControl.getAccessCode();
  }

  public String getFeatureCode() {
    return this.featureAccessControl.getFeatureCode();
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj) {
      return true;
    }
    return obj instanceof FeatureAccessControlGrantedAuthority
        && this.getFeatureCode()
            .equals(((FeatureAccessControlGrantedAuthority) obj).getFeatureCode());
  }
}
