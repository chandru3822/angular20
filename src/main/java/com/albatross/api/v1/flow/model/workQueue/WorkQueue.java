package com.albatross.api.v1.flow.model.workQueue;

import lombok.Data;

import java.util.Map;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueue {
    private Long workQueueTypeId, workQueueCategoryId, companyId, workQueueCount, smartlistId,
      shortWindow, longWindow, expectedCycle;
    private String workQueueType, color;
    private Boolean archived, inverseExpectation, useEventData;
    //dont remove this. used for work queue metric population on frontend
    private Map<Object, Object> metrics = Map.of();
}
