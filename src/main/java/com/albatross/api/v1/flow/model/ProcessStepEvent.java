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
public class ProcessStepEvent {

  private Long id, processStepId, eventId, initialCompanyEventStatusTypeId, uniqueBehaviorTypeId, displayOrder;
  private String eventName, initialEventStatusType, processStepName;
  private Boolean archived;
  private List<CompanyEventStatusType> companyEventStatusTypes;
  private List<ProcessStepEventAction> processStepEventActions;
  private List<ProcessStepEventWorkQueueType> workQueueTypes;
}

