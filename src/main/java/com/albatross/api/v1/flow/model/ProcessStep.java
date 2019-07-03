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
public class ProcessStep {

  private Long id, processId, parentCompanyId, companyId, orgId, createdById, modifiedById;
  private String orgName, processStepName;
  private Boolean archived;
  private Date dateCreated, dateModified;
}

