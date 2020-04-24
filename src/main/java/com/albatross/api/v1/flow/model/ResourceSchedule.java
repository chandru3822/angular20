package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class ResourceSchedule {

  private Long id, companyId, userId, orgId;
  private Date startDate, endDate;
  private Boolean archived;
  private List<ResourceScheduleAvailability> resourceScheduleAvailability;
}
