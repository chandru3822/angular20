package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

import java.util.Date;
import java.util.List;

/**
 * Created by randa on 4/13/17.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CommissionPlan {

    @Id
    private Long id;

    private Long active_users, status_id, statusId, activeUsers, positionId;
    private String name, description, status_type;
    private double total;
    private List users;
    private BackdatedPlanApprovalCredentials backdateApprovalCreds;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date startDate, endDate;
}
