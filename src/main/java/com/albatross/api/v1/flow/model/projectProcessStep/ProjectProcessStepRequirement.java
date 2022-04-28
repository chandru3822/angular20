package com.albatross.api.v1.flow.model.projectProcessStep;

import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.processStep.ProcessStepRequirement;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
public class ProjectProcessStepRequirement extends ProcessStepRequirement {

  private Boolean booleanValue, hasListValues;

  private Timestamp timestampValue, dateValue;

  // `timeZone` is the project's timezone
  private String textValue, timeZone;

  private BigDecimal numericValue;

  private Long intValue, dataTypeRequirementId, listOfValueId, projectId;

  private List<Integer> intArrayValue;

  private List<CompanyFunctionParam> companyFunctionParams;
}
