package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ProcessStepCompanyProcessStepStatusType {

//  ^^ yes, i did

  private Long id, companyId, processStepId, companyProcessStepStatusTypeId, processStepStatusTypeId, createdById, modifiedById;
  private String processStepStatusType, rootProcessStepStatusType, processStepName;
  private Boolean archived, allowNonAdminUse;
}

