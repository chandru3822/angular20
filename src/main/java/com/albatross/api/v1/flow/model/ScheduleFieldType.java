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
public class ScheduleFieldType {

  private Long id, requiredDataTypeId;
  private String fieldType;
  private Boolean archived;
  private List<CustomField> availableCustomFields;
}

