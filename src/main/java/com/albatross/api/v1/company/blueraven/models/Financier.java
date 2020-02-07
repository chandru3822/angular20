package com.albatross.api.v1.company.blueraven.models;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class Financier {
  private Long id, createdById, modifiedById;
  private String name, submissionMethod;
  private Boolean archived;
  private Date dateCreated, dateModified;
}
