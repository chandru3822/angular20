package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CompanyProcessStepStatusType {

  private Long id, companyId, processStepStatusTypeId, createdById, modifiedById;
  private String processStepStatusType, rootProcessStepStatusType;
  private Boolean archived, isDefault;

  // This status type ID represents what status to change current active steps to (when changing the new status to active)
  private Long cancelledCompanyProcessStepStatusTypeId;
}

