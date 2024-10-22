package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;

import java.io.Serializable;

@Data
public class ProposalObjectCategory implements Serializable {
  private Long id;
  private String objectCategory;
}
