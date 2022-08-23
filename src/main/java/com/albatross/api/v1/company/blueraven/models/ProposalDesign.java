package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.Attachment;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class ProposalDesign {

  private Long projectId, projectProcessStepId, processStepStatusTypeId;
  private Long offset, imageIndex = 0L;
  private String projectName, dateCreated, dueDate, companyProcessStepStatusType;
  private List<Proposal> proposals;
  private List<Attachment> attachments;
}
