package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserPosition {

    private Long id, userId, positionId, orgId;
    private String position;
    private String startDate, endDate;
    private Boolean archived, primaryFlag;
    private List<UserOrgHierarchy> hierarchy;
}
