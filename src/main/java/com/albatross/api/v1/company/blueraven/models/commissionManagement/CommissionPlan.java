package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

import java.util.Date;
import java.util.List;

@Getter
@Setter
public class CommissionPlan {

  @Id private Long id;

  private Long statusId, activeUsers, positionId;
  private String name, description, statusType;
  private double total;
  private List<Long> users;
  private BackdatedPlanApprovalCredentials backdateApprovalCreds;

  @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
  private Date startDate, endDate;
}
