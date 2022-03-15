package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class CloserAppointmentResult {

  private Long userId, userPositionId, companyEventStatusTypeId;
  private String userFirstName, userLastName, userFullName, userEmail;
  private Date appointmentStartTime, appointmentEndTime;
  private List<ProcessStepEventAction> eventActions;
  private Boolean success;
}
