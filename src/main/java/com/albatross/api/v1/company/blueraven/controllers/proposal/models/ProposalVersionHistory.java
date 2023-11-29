package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;

import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
public class ProposalVersionHistory {
    private String pk, objectType, modifiedBy;
    private boolean archived;
    private ZonedDateTime modifiedDate;
    private List<Map<String, Object>> changes = new ArrayList<>();
}
