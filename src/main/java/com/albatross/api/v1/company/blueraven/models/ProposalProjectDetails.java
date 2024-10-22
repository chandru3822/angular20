package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@Data
@NoArgsConstructor
public class ProposalProjectDetails extends ProposalProject {
  //i needed some specific data so i changed from the flow project model to this one
  private String street1, city, state, postalCode, mobile;
  private Date closerAppointmentStart, closerAppointmentEnd;
  private Long ahjId, metroAreaId;
  private List<CustomFieldValue> availableModules;
}
