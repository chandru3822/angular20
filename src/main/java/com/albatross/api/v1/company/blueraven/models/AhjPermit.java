package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;
import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjPermit {
    private Long id;

    private Double averagePermitFee;
    private String engineeringLetterRequired,
            printLocation, stampedPlan,
            businessLicense, contractorLicense, otherLicense,
            submissionNote, revisionNote, asBuiltNote, deliveryNote,
            approvalTimeline, documentsAvailable, depositAmount, asBuiltFeeAmount, followUpFeeAmount, deliveryFeeAmount, revisionFeeAmount;
    private Date businessLicenseExpirationDate, contractorLicenseExpirationDate, otherLicenseExpirationDate;

    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;
}
