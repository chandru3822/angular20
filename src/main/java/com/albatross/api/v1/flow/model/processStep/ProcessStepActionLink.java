package com.albatross.api.v1.flow.model.processStep;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepActionLink {

  private Long id, processStepActionId, linkId, createdById, modifiedById;
  private String link, url;
  private Boolean archived;
}

