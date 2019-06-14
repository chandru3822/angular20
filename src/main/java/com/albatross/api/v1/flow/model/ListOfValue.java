package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ListOfValue {

  private Long id, parentId, createdById, modifiedById, displayOrder;
  private String name;
  private Boolean archived = false;
  private Date dateCreated, dateUpdated;
}

