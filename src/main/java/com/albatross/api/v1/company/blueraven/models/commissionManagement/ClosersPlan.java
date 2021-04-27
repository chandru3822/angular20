package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

import java.util.Date;
import java.util.List;

@Getter
@Setter
public class ClosersPlan {

    @Id
    private Long id, userId, commissionPlanId, overridePlanId, userStatusTypeId;
    private String name;
    private String commissionPlan, commissionDescription, overridePlan, overrideDescription;

    private List<ReceivingPlan> receivingPlans;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date hireDate;

    private boolean hasCommissionPlanGap;

    private Boolean isActiveUser;
}
