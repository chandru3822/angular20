package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Utility {

  private Long id, companyId;
  private String utilityCompany;
  private List<UtilityState> utilityStates;
  private Boolean archived, active;

}
