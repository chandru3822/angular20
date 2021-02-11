package com.albatross.api.v1.company.blueraven.models.ahj;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjInspection {
    private Long id, ahjId, stateId, companyStateId;
    private Double inspectionFee, reInspectionFee;
    private String paymentMethod, inspectionTimeWindow, brsInspectionRep, portalUrl, portalUsername,
                   portalPassword, ladderRequired, obtainingResultsMethod, approvalDocumentMethod,
                   obtainingResultsPortalUrl, obtainingResultsPortalUsername, obtainingResultsPortalPassword,
                   businessLicense, contractorLicense, timeWindowCallTime, timeWindow, timeWindowPhone,
                   requiredInspectionTypes, schedulingNote, technicianInstructionNote,
                   schedulingWithCustomerNote, obtainingResultsNote, reinspectionNote, documentationNote,
                   mpuInspectionNote, stateName;

    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;

    // these are only used when updates are performed for all AHJ Inspections in a specified state
    private Boolean updateAllInState;
    private List<Long> ahjIds, inspectionIds;
}
