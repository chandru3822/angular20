package com.albatross.api.v1.company.blueraven.models.ahj;

import com.albatross.api.v1.flow.model.User;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Getter
@Setter
public class AhjInspectionDetail extends AhjInspection {
    private List<AhjLink> schedulingLinks, fotLinks, resultsLinks;
    private List<AhjRequirement> installationRequirements;
    private List<AhjNoteTemplate> noteTemplates;
    private List<AhjContact> utilityServiceDeptContacts, schedulingContacts, obtainingResultsContacts,
                             feeContacts;
    private List<User> servicingFots;
}
