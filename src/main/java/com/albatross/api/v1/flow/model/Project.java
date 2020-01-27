package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
public class Project {

  private Long id, processId, companyId, customerId, statusTypeId;
  private String projectName, processName, statusType;

  private LocalDate dateCreated;
}
