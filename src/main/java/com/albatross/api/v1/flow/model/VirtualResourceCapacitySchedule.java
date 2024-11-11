package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class VirtualResourceCapacitySchedule {
    private Long id, companyId, orgId, maxCapacity, currentlyBooked;
    private String startTime, endTime;
    private Boolean archived;
}
