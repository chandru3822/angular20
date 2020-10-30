package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class RecurringResourceAppointment {

  private Long companyId, userId, orgId, duration;
  private String description, recurrence, recurringEventId, recurringEventEndType;
  private Date recurringStartTime, recurringEndTime;
  private Boolean repeat, allDay;
  private List<ResourceAppointment> appointments;
}
