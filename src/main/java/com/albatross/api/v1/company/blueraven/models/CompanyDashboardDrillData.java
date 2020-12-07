package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;

@Data
public class CompanyDashboardDrillData {
    private Long projectId;
    private String customerName, state, sourceName, appointmentOutcome;
    private Date appointmentDate, installationAgreementSignedDate, siteSurveyVerifiedDate,
                 finalDesignCreatedDate, finalDesignSentToHomeownerDate, finalDesignSignedDate,
                 planSetCreatedDate, permitPackCompleteDate, permitSubmittedDate,
                 permitApprovedDate, installationScheduledDate, installationDate,
                 installationCloseoutDate, substantialCompletionDate, ahjInspectionScheduledDate,
                 ahjReinspectionScheduledDate, ahjInspectionDate, ahjReinspectionDate,
                 ahjFinalInspectionVerifiedDate, verifiedInspectionApprovalReceivedByUtilityDate,
                 ahjInspectionApprovalSubmittedDate, finalCompletionSubmittedDate;
}
