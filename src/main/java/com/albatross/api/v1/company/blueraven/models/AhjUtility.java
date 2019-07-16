package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Data
public class AhjUtility {
    private Long id;

    private Long ahjUtilityId, ahjId, stateId, metroAreaId, acDisconnectRequired, pvProductionMeterRequired,
        meterCanTapsAllowed, pvAcSwapLocations, utilityWarningLabelsOverride;
    private String name, metroArea, state, timelinesAndStages, regulatedBy, monthlyFacilityCharge,
        populationOfService, netMeteringRate, rebateRates, utilityRateNotes, customerSignatureInstructions,
        expectedApprovalTimeline, rejectionInstructions, notes, submissionInstructions, overviewOfSubmissionProcess,
        timelines, ptoFollowupInstructions, finalCompletionInstructions;
    private Boolean active, archived;

    //type table stuff
    private Long rebateProgramTypeId, signatureRequiredPriorTypeId, signatureRequestedAtTypeId,
        customerSignatureResubmissionTypeId, whenToCreateApplicationTypeId, submissionMethodTypeId,
        interconnectionFeeTypeId, utilityMethodTypeId, inspectionSubmissionTypeId, utilityInspectionRequiredTypeId,
        followupMethodTypeId;

    private String rebateProgramTypeOther, signatureRequiredPriorTypeOther, signatureRequestedAtTypeOther,
        customerSignatureResubmissionTypeOther, whenToCreateApplicationTypeOther, submissionMethodTypeOther,
        interconnectionFeeTypeOther, utilityMethodTypeOther, inspectionSubmissionTypeOther, utilityInspectionRequiredTypeOther,
        followupMethodTypeOther;
}