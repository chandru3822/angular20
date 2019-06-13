package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CustomField {

  private Long id, companyDataTypeId, listOfValueId, companyId, fieldOrder, createdById, modifiedById;
  private String fieldName, objectType;
  private Boolean archived;
  private List<Long> selectedCustomFieldObjectTypes;
  private List<ListOfValue> dropdownOptions;
  private Date dateCreated, dateModified;
}

