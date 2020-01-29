package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueue {
    private Long workQueueTypeId, workQueueCategoryId, companyId, workQueueCount;
    private String workQueueType;
    private Boolean archived;
}
