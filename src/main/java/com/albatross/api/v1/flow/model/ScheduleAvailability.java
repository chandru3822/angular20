package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;

/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ScheduleAvailability {

  private Long resourceId, dayOfWeekId, systemListTypeId;
  private String rendering, title;
  private Boolean allDay;
  private Timestamp start, end;

}

