package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class VirtualResourceCapacitySchedule {
    private Long id, companyId, orgId, maxCapacity;
    private Date startTime, endTime;
    private Boolean archived;
}
