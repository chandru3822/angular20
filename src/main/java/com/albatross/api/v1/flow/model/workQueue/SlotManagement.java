package com.albatross.api.v1.flow.model.workQueue;
import lombok.Data;

import java.util.List;


@Data
public class SlotManagement {
  private Long positionid;
  private List<Long> scheduleId;

}
