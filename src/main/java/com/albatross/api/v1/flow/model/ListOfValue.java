package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/** Created by randanunn on 2019-05-20. !Describe Purpose! */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
public class ListOfValue {

  private Long id, parentId, createdById, modifiedById, displayOrder;
  private String name, code;
  private Boolean archived = false;
  private Date dateCreated, dateModified;

  //this field is only used when in the BRS custom field side of things. but i refactored to only use one model for list of value and now i cant remember why i did that so i am just putting this field here
  private Boolean showOther;
}
