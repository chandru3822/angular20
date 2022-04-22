package com.albatross.api.v1.flow.model.workQueue;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class WorkQueueTypeEventStatus {

    private Long id, companyEventStatusTypeId,
      eventStatusTypeId, processStepEventWorkQueueTypeId;

    private String eventStatusType, rootEventStatusType, uniqueText, group, header;

    //isRoot determines if the status originated from a root status or a company status
    //disabled is cuz i am
    private Boolean archived, isRoot, disabled = false;

}
