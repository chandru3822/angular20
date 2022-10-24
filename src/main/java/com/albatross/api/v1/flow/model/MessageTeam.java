package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class MessageTeam {
  private Long id;
  private String teamName;
  private Boolean archived;
}
