package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class CompanyObjectType {

  private Long id, flowTypeId, companyId, objectTypeId, companyObjectTypeId;
  private String objectType;
  private Boolean archived, statusReadOnly, ownerReadOnly;
  private List<WhiteListedPosition> statusReadOnlyWhiteListedPositions,
      ownerReadOnlyWhiteListedPositions;
}
