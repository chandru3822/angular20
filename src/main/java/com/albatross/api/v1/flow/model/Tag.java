package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 10/1/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Tag {

  private Long id, tagTypeId;
  private String tagName, fontColor, bgColor;
  private Boolean archived;

}

