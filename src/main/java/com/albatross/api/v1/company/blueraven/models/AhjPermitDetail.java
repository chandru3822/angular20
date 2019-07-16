package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.User;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjPermitDetail extends AhjPermit {
    private List<AhjLink> links, followUpLinks;
    private List<AhjChecklistItem> checklist, revisionChecklist, asBuiltChecklist;
    private List<AhjNote> notes;
    private List<AhjContact> contacts, followUpContacts, printLocations;
    private List<User> servicingFots;
}