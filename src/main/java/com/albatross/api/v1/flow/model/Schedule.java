package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Schedule {

  private Long id;
  private String schedule;
  private Boolean archived;

}

