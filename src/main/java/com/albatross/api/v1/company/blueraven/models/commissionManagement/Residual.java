package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randa on 4/13/17.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Residual {

    private String firstName, lastName, employeeId, regionName, officeName, officeState, userPositionName,
      userFullName, userStatusType, hireDate, residualStartDate , residualPlanName;

    private Long userId, lifetimeFdc, qualifiedThisPeriodFdc, fdsNotQualified, requiredFdcPerMonth;

    private Boolean residualEarned;

    private Double percentOfResidualEarned, potentialResidual, earnedResidual, totalClawback,
      currentClawback, existingClawback, adjustmentOverride, total, qualifiedThisPeriodSystemSize, lifetimeSystemSize;
}
