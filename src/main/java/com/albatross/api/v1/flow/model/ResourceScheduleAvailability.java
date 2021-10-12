package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class ResourceScheduleAvailability {

  private Long id, resourceScheduleId, resourceSlotScheduleId, dayOfWeekId;
  private String startTime, endTime, dayOfWeek;
  private List<Long> excludedResourceSlotTimeIds;
  private Boolean archived, useSlotSchedule, daylightSavings;
}
