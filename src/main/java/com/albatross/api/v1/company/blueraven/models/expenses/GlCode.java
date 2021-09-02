package com.albatross.api.v1.company.blueraven.models.expenses;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by Joseph Canto on 2020-02-07.
 */
@Getter
@Setter
public class GlCode {
  private Long id;
  private String code, description;
  private Boolean archived;
}
