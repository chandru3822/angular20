package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Getter
@Setter
public class SlotSchedule {

  private Long id;
  private String scheduleName;
  private Boolean archived;
  private List<SlotTime> slotTimes;

}

