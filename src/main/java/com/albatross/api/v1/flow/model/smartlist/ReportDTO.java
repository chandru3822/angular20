package com.albatross.api.v1.flow.model.smartlist;

import lombok.Data;

import java.util.List;

@Data
public class ReportDTO {
  private Smartlist smartlist;

  private List<SmartlistFieldAssignment> fields;

  private List<SmartlistRequirement> requirements;
}
