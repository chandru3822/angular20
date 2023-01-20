package com.albatross.api.security;

import com.albatross.api.v1.flow.model.UserAccountDetails;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.expression.SecurityExpressionRoot;
import org.springframework.security.access.expression.method.MethodSecurityExpressionOperations;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

import java.util.Arrays;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
public class CustomSecurityExpressionRoot extends SecurityExpressionRoot
  implements MethodSecurityExpressionOperations {

  private static Long SYS_ADMIN_ID = 1L;
  private Object filterObject;
  private Object returnObject;

  /**
   * Creates a new instance
   *
   * @param authentication the {@link Authentication} to use. Cannot be null.
   */
  public CustomSecurityExpressionRoot(Authentication authentication) {
    super(authentication);
  }

  public boolean hasFeatureAccessLevel(String... featureAccessLevels) {
    final var principal = this.getPrincipal();
    if (principal instanceof final UserAccountDetails details) {
      final var authorities =
        details
          .getAuthorities().stream().map(GrantedAuthority::getAuthority).toList();
      final boolean anyMatch = Arrays.stream(featureAccessLevels).anyMatch(authorities::contains);
      final boolean isSystemAdminUser = Objects.equals(details.getHighestCompanyId(), SYS_ADMIN_ID);
      return anyMatch || isSystemAdminUser;
    }

    return false;
  }

  /**
   * Allows access if they have any level of access to the provided feature (ideally used on a class level as a catch-all)
   *
   * @param featureAccess
   * @return
   */
  public boolean hasFeatureAccess(String... featureAccess) {
    final var principal = this.getPrincipal();
    if (principal instanceof final UserAccountDetails details) {

      final var features =
        details
          .getAuthorities().stream().filter(FeatureAccessControlGrantedAuthority.class::isInstance)
          .map(FeatureAccessControlGrantedAuthority.class::cast)
          .map(FeatureAccessControlGrantedAuthority::getFeatureCode)
          .collect(Collectors.toSet());
      final boolean anyMatch = Arrays.stream(featureAccess).anyMatch(features::contains);
      final boolean isSystemAdminUser = Objects.equals(details.getHighestCompanyId(), SYS_ADMIN_ID);
      return anyMatch || isSystemAdminUser;
    }

    return false;
  }

  public boolean hasCompanyAccess(Long companyId) {
    final var principal = this.getPrincipal();
    if (principal instanceof final UserAccountDetails details) {
      //return true if the user is a 7oak employee or if the company id matches
      return Objects.equals(details.getHighestCompanyId(), SYS_ADMIN_ID) ||
               Objects.equals(details.getCompanyId(), companyId);
    }

    return false;
  }

  public boolean hasRootLevelAccess() {
    final var principal = this.getPrincipal();
    if (principal instanceof final UserAccountDetails details) {
      return Objects.equals(details.getHighestCompanyId(), SYS_ADMIN_ID);
    }

    return false;
  }

  @Override
  public Object getFilterObject() {
    return this.filterObject;
  }

  @Override
  public void setFilterObject(Object filterObject) {
    this.filterObject = filterObject;
  }

  @Override
  public Object getReturnObject() {
    return this.returnObject;
  }

  @Override
  public void setReturnObject(Object returnObject) {
    this.returnObject = returnObject;
  }

  @Override
  public Object getThis() {
    return this;
  }
}
