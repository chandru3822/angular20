package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCode {

  private Long id, postalCodeZoneId;
  private String postalCode;
  private Boolean archived, postalCodeZoneArchived;
  private List<User> users;
}
