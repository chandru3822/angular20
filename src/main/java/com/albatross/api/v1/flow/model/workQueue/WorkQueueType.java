package com.albatross.api.v1.flow.model.workQueue;

import com.albatross.api.v1.flow.model.WhiteListedPosition;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueType {
    private Long id, companyId, workQueueCategoryId, displayOrder,
      workQueueCategoryDisplayOrder, smartlistId, longWindow, shortWindow, longWindowDurationTypeId,
      shortWindowDurationTypeId, expectedCycle, expectedCycleDurationTypeId;
    private String workQueueType, workQueueCategory, workQueueCategoryColor,
      longWindowDurationType, shortWindowDurationType, expectedCycleDurationType;
    private List<WorkQueueTypeSchedule> schedule;
    private Double expectedTarget;
    private Boolean archived, inverseExpectation, useEventData, hidden;
  private List<WhiteListedPosition> hiddenWhiteListedPositions;
}
