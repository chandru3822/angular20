package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class CloserAppointmentRequest {

  private Long projectId, projectProcessStepId;
  private Date appointmentTime, startTime, endTime;
  private List<Integer> users;
}
