package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueCategory {
    private Long id, companyId, displayOrder;
    private String workQueueCategory, color;
    private Boolean archived;
}
