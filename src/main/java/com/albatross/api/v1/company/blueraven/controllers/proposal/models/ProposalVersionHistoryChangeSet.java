package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class ProposalVersionHistoryChangeSet extends ProposalVersion {
    private List<ProposalVersionHistory> history = new ArrayList<>();
}
