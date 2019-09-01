package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Lead {

  // reminder that Customer and Lead are the same thing, just a different status type
  private Long id;
  private Boolean archived;
}

