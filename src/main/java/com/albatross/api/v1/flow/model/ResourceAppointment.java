package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class ResourceAppointment {

  private Long id, companyId, userId, orgId, duration;
  private String description, recurrence, recurringEventId, recurringEventEndType;
  private Date startTime, endTime, recurringStartTime, recurringEndTime;
  private Boolean archived, allDay, repeat;

  //i am having trouble with date comparisons of different types and converting back and forth. going to just use a string for comparison for now _rn
  String startTimeString, endTimeString;
}
