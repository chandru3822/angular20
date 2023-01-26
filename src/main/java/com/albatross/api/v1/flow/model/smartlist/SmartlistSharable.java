package com.albatross.api.v1.flow.model.smartlist;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class SmartlistSharable {

  private Long id;

  private String name, position;

  private Boolean isUser, isOrg;

}
