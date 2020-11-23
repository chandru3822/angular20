package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepLink extends Link {

  private Long linkId, createdById, modifiedById, processStepId, displayOrder;
  private Date dateCreated, dateModified;
}

