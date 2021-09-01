package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class CloserAppointmentResult {

  private Long userId, userPositionId;
  private String userFirstName, userLastName, userFullName, userEmail;
  private Date appointmentStartTime, appointmentEndTime;
  private Boolean success;
}
