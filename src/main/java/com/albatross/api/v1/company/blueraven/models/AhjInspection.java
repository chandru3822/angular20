package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjInspection {
    private Long id;
    private Double inspectionFee, reInspectionFee;
    private String paymentMethod, inspectionTimeWindow, brsInspectionRep, homeownerRequiredOnSite, portalUrl, portalUsername,
        portalPassword, ladderRequired, callForTimeWindow, obtainingResultsMethod, approvalDocumentMethod, obtainingResultsPortalUrl, obtainingResultsPortalUsername,
        obtainingResultsPortalPassword, businessLicense, contractorLicense, timeWindowCallTime, timeWindow, timeWindowPhone,
        schedulingNote, technicianInstructionNote, schedulingWithCustomerNote, obtainingResultsNote, reinspectionNote, documentationNote,
        fallProtectionRequired, mpuInspectionNote;

    //custom fields
    private Long homeownerRequired, brsTechRequired;

    //stuff for the types tables
    private Long schedulingMethodTypeId, handyInformationTypeId, schedulingLeadTimeTypeId, siteAccessTypeId,
        inspectionCapacityTypeId, midpointInspectionLeadTimeTypeId, soladeckAccessTypeId, placardRequiredTypeId, roughInspectionRequiredTypeId,
        representativeRequiredOnsiteTypeId, specialEquipmentTypeId, plansRequiredTypeId, specialDocumentsTypeId,
        resultsDocumentationTypeId, reinspectionFeeTypeId;

    private String schedulingMethodTypeOther, handyInformationTypeOther, schedulingLeadTimeTypeOther, siteAccessTypeOther,
        inspectionCapacityTypeOther, requiredInspectionTypes, midpointInspectionLeadTimeTypeOther, soladeckAccessTypeOther, placardRequiredTypeOther,
        roughInspectionRequiredTypeOther, representativeRequiredOnsiteTypeOther, specialEquipmentTypeOther,
        plansRequiredTypeOther, specialDocumentsTypeOther, resultsDocumentationTypeOther, reinspectionFeeTypeOther;
}