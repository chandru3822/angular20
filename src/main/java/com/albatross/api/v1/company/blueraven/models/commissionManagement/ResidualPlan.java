package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by randa on 4/13/17.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ResidualPlan {

    private Long id, positionId, residualStatusId;
    private String name, description, notes, approved, statusType, position;
    private List<ResidualPlanAllocation> residualPlanAllocations;
    private List users;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date startDate, endDate;
}
