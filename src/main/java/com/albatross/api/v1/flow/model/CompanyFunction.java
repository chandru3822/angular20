package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CompanyFunction {

  private Long id, dbFunctionId, returnDataTypeId, dbFunctionTypeId, companyId;
  private String companyFunctionName, companyName;
  private Boolean archived;
  private List<CompanyFunctionParam> companyFunctionParams;
}

