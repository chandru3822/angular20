package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.Attachment;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class ProposalDesign {
  private Long projectId, projectProcessStepId, processStepId, processStepStatusTypeId;
  private Long offset, imageIndex = 0L;
  private String dateCreated, dateModified, dueDate, processStepName, companyProcessStepStatusType, comments;
  private List<Proposal> proposals;
  private List<Attachment> attachments;
}
