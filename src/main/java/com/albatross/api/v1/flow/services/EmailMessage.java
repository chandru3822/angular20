package com.albatross.api.v1.flow.services;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EmailMessage {
  private String to;
  private String from;
  private String fromDisplayName;
  private String subject;
  private String content;
  private Long sentByUserId;
  private Boolean processed;
  private Long id;
  private List<Long> attachmentIds;
  private String cc;


}


