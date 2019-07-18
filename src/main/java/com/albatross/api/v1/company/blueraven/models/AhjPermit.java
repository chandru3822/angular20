package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjPermit {
    private Long id;

    private Long submittalTypeId, revisionSubmittalTypeId, asBuiltSubmittalTypeId, deliveryPickupTypeId,
                 submissionPaymentTypeId, revisionPaymentTypeId, asBuiltPaymentTypeId, followUpPaymentTypeId, deliveryPaymentTypeId,
                 hoaApprovalRequiredTypeId, nemApprovalRequiredTypeId;
    private Double averagePermitFee;
    private String engineeringLetterRequired,
            printLocation, stampedPlan, paymentMethod,
            businessLicense, contractorLicense, otherLicense,
            submissionNote, revisionNote, asBuiltNote, deliveryNote,
            submittalTypeOther, revisionSubmittalTypeOther, asBuiltSubmittalTypeOther, deliveryPickupTypeOther,
            submissionPaymentTypeOther, revisionPaymentTypeOther, asBuiltPaymentTypeOther, followUpPaymentTypeOther, deliveryPaymentTypeOther,
            approvalTimeline, documentsAvailable, depositAmount, asBuiltFeeAmount, followUpFeeAmount, deliveryFeeAmount, revisionFeeAmount,
            hoaApprovalRequiredTypeOther, nemApprovalRequiredTypeOther;
    private Date businessLicenseExpirationDate, contractorLicenseExpirationDate, otherLicenseExpirationDate;
}