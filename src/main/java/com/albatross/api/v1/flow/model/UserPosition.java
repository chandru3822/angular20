package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserPosition {

    private Long id, userId, positionId, orgId, companyStateId, stateId;
    private String position, orgName;
    private String startDate, endDate;
    private Boolean archived, primaryFlag, scheduler, schedulable, useSlotSchedule;
    private List<UserOrgHierarchy> hierarchy;
}
