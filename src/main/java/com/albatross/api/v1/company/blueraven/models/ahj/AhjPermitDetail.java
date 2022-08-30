package com.albatross.api.v1.company.blueraven.models.ahj;

import com.albatross.api.v1.flow.model.User;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Getter
@Setter
public class AhjPermitDetail extends AhjPermit {
    private List<AhjLink> submissionLinks, followUpLinks;
    private List<AhjChecklistItem> submissionChecklist, revisionChecklist, asBuiltChecklist, nonStandardChecklist;
    private List<AhjNote> notes;
    private List<AhjContact> submissionContacts, followUpContacts, printLocations;
    private List<User> servicingFots;
}
