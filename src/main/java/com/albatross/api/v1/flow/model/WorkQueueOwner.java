package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueOwner {
    private Long userPositionId, userId;
    private String firstName, lastName, fullName;
}
