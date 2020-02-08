package com.albatross.api.v1.company.blueraven.models.ahj;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-17.
 */
@Getter
@Setter
public class AhjUtilityDetail extends AhjUtility {
    private List<AhjLink> customerSignatureLinks, ptoLinks, ptoFollowupLinks, submissionLinks;
    private List<AhjChecklistItem> submissionChecklist, approvalChecklist, ptoChecklist, utilityInspectionChecklist;
    private List<AhjContact> contacts;
    private List<AhjRequirement> utilityRequirements;
}
