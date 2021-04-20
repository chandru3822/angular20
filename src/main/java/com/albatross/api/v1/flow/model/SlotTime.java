package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Getter
@Setter
public class SlotTime {

  private Long id, resourceSlotScheduleId;
  private String startTime, endTime;
  private Boolean archived;

}

