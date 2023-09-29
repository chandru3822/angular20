package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZone {

  private Long id, metroAreaId;
  private Double adderAmount;
  private String zoneName, metroArea;
  private Boolean archived;
  private List<PostalCode> postalCodes;
}
