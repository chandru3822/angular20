package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Customer  {

  private Long id, companyId;
  private String firstName, lastName, fullName, email, phone;
}
