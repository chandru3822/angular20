package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class ResourceScheduleAvailability {

  private Long id, resourceScheduleId, dayOfWeekId;
  private String startTime, endTime, dayOfWeek;
  private Boolean archived;
}
