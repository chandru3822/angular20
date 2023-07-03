package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;
import java.util.Date;

@Getter
@Setter
public class InteractionTimer {
  private long id, userId, projectId;
  private Date startTimestamp, endTimestamp;
  private String timerType, startEvent, endEvent;
}
