package com.albatross.api.v1.company.blueraven.models.expenses;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class ReimbursementUserSearch {

  private String query;
  private List<Long> userStatusIds, areaIds, roleIds, userIds, positionIds, officeIds,
    regionIds, districtIds, departmentIds;
  private Date dateBefore, dateAfter, creditDateBefore, creditDateAfter;
  private Long userId;
  private Boolean export, primaryOnly, secondaryOnly,
    activePositionsOnly, inactivePositionsOnly,
    missingPrimary, missingPosition;

}
