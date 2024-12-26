package com.albatross.api.v1.flow.model.project;

import com.albatross.api.v1.flow.model.ListOfValue;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@NoArgsConstructor
public class ChildProjectHeader {

  private Long customFieldGroupAssignmentId, dataTypeId, companySystemListId;
  private String fieldName, dataType, customFieldSqlKey, customFieldSql;
  private Boolean allowNow, sortListValuesAlphabetically, hasListValues;
  private List<Long> systemListOptionIds;
  private List<ListOfValue> listOfValues;

}
