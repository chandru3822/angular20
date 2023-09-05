package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import com.albatross.api.v1.company.blueraven.models.Proposal;
import org.springframework.core.io.Resource;

import java.util.Map;

public record ProposalResource(Resource resource, Proposal proposal, Map<String, Object> context) {
}
