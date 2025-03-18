package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

import java.util.Date;

@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class PlanAssignment {

    @Id
    private Long id, userId, orgId;
    private Date startDate, endDate;
    private BackdatedPlanApprovalCredentials approvalCreds;
    private String note;
}
