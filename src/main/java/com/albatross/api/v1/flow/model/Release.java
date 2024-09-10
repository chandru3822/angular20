package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Release {

  private Long id;
  private String releaseName;
  private Boolean archived;
  private Date stageLockDate, uatLockDate, releaseDate;

}

