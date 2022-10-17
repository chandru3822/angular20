package com.albatross.api.v1.flow.model.processStep;

import com.albatross.api.v1.flow.model.MessageTeam;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepActionChildSmsTemplate {

  private Long id, processStepActionId, messageTemplateId, createdById, modifiedById, projectId;
  private String title, message;
  private List<Long> teamIds;
  private List<MessageTeam> teams;
  private Boolean archived, edit = false;
}

