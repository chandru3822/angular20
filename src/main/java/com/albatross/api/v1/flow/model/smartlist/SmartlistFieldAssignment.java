package com.albatross.api.v1.flow.model.smartlist;

import com.albatross.api.v1.flow.model.CustomField;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SmartlistFieldAssignment extends SmartlistSuperField {

  //@TODO humes: customField brings in fields making some direct fields on this class redundant. Remove the direct redundant fields

  private Long systemListTypeId;

  private CustomField customField;

  @Deprecated //@TODO: turns out this field wasn't needed. Remove it's use from `buildProcessStepSql` function
  @JsonIgnore
  private String valueEventReferenceTable;
}
