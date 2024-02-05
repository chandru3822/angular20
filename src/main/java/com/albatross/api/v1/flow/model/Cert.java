package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.Date;

/**
 * Created by randanunn on 12/17/19.
 * !Describe Purpose!
 */
@Getter
@Setter
public class Cert {

  private Long id;
  private String certName, notes;
  private LocalDate expirationDate;
  private Boolean archived, thirtyDayNoticeSent;

}

