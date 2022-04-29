package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import lombok.Data;

import java.io.Serializable;

@Data
public class ProposalTheme implements Serializable {
  private Long id;
  private String name;
  private Object themeClasses;
  private Object themeStyle;
}
