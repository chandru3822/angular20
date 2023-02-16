package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.CompanyEventStatusType;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
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
  private Boolean archived, readonly;
  private List<CompanyEventStatusType> companyEventStatusTypes;
  private List<ProcessStepEventAction> processStepEventActions;
  private List<ProcessStepEventWorkQueueType> workQueueTypes;
  private List<WhiteListedPosition> readonlyWhiteListPositions;
}

