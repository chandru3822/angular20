package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class SystemList {

  private Long id, companyId, companySystemListId;
  private String systemList;
  private Boolean archived, hasSubOptions;
}

