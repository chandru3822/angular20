package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter @Setter
public class MessageTemplate {
  private Long id;
  private String title, message;
  private List<Long> teamIds;
  private Boolean archived;
}
