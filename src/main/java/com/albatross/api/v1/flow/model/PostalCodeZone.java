package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZone {

  private Long id, companyId;
  private String zoneName;
  private Boolean archived;
  private List<PostalCodeZoneUser> postalCodeZoneUsers;
  private List<PostalCode> postalCodes;
}
