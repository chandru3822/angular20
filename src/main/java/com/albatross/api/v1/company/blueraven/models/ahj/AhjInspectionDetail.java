package com.albatross.api.v1.company.blueraven.models.ahj;

import com.albatross.api.v1.flow.model.User;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Data
public class AhjInspectionDetail extends AhjInspection {
    private List<AhjLink> schedulingLinks, fotLinks, resultsLinks;
    private List<AhjChecklistItem> failureChecklist, schedulingChecklist, obtainingResultsChecklist, reinspectionsChecklist, schedulingWithAhjChecklist, schedulingWithBrsTechnicianChecklist;
    private List<AhjRequirement> installationRequirements;
    private List<AhjBaseNoteTemplate> baseNoteTemplates;
    private List<AhjContact> utilityServiceDeptContacts, schedulingContacts, obtainingResultsContacts, feeContacts;
    private List<User> servicingFots;
}
