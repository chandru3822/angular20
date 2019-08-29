package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.User;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjPermitDetail extends AhjPermit {
    private List<AhjLink> submissionLinks, followUpLinks;
    private List<AhjChecklistItem> submissionChecklist, revisionChecklist, asBuiltChecklist;
    private List<AhjNote> notes;
    private List<AhjContact> submissionContacts, followUpContacts, printLocations;
    private List<User> servicingFots;
}