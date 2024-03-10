package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class CertAdmin {

  private Long id;
  private String firstName, lastName, email;
  private Boolean archived;

}

