package com.albatross.api.v1.company.blueraven.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
public class ListOfValue {

  private Long id, parentId, createdById, modifiedById, displayOrder;
  private String name, code;
  private Boolean archived = false, showOther;
  private Date dateCreated, dateModified;
}

