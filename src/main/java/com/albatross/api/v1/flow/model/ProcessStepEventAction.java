package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepEventAction {

  private Long id, companyEventStatusTypeId, companyProcessStepStatusTypeId;
  private String actionName, processStepStatusType, eventStatusType;
  private Boolean archived;
  private List<ProcessStepEventActionField> requiredFields;
  private List<ProcessStepEventActionField> optionalFields;
}

