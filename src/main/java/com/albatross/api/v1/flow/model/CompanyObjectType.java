package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CompanyObjectType {

  private Long id, flowTypeId, companyId, objectTypeId, companyObjectTypeId;
  private String objectType;
  private Boolean archived;
}

