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
public class DbFunction {

  private Long id, returnDataTypeId, dbFunctionTypeId;
  private String functionName, functionType, returnDataType, displayName;
  private Boolean archived, runInBackend;
  private List<DbFunctionParam> dbFunctionParams;
  private List<CompanyFunction> companyFunctions;
}

