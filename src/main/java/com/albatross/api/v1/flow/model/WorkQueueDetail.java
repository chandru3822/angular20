package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-08-01.
 */

@Data
public class WorkQueueDetail {
    private Long processStepId, companyId, projectProcessStepId, projectId, contactId, processStepWorkQueueTypeId, daysInQueue;
    private String projectName, workQueueType, processStepName, owner, lastUpdated;
    private List<OwningPosition> owningPositions;
    private List<ProjectProcessStep> activeProcessSteps;
    private List<Note> notes;

    //one day i will become a good developer and understand why i can't set these types of values in vue without them existing in the first place!
    private Boolean showNotesModal = false;
}
