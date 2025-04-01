package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class VirtualResourceBookedEvents {
  private Long ppseId;            // ppse.id
  private Timestamp startTime;    // ppse.start_time
  private Long projectId;         // p.id
  private String state;           // s.abbreviation
  private String customerName;    // c.first_name || ' ' || c.last_name
  private Timestamp appointmentCreated;  // ppse.date_created
}
