package com.albatross.api.v1.company.blueraven.models.ahj;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Data
public class AhjUtility {
    private Long id;

    private Long ahjUtilityId, ahjId, stateId, metroAreaId;
    private String name, metroArea, state, timelinesAndStages, regulatedBy, monthlyFacilityCharge,
        populationOfService, netMeteringRate, rebateRates, utilityRateNotes, customerSignatureInstructions,
        expectedApprovalTimeline, rejectionInstructions, notes, submissionInstructions, overviewOfSubmissionProcess,
        timelines, ptoFollowupInstructions, finalCompletionInstructions;
    private Boolean archived;


    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;
}
