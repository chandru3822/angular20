package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class ResourceAppointment {

  private Long id, companyId, userId, orgId;
  private String description;
  private Date startTime, endTime;
  private Boolean archived, allDay;
}
