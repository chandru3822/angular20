package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

import java.util.Date;

@Getter
@Setter
@JsonIgnoreProperties(ignoreUnknown = true)
public class PlanUser {

    @Id
    private Long id, userId;
    private Date startDate, endDate;
    private BackdatedPlanApprovalCredentials approvalCreds;
}
