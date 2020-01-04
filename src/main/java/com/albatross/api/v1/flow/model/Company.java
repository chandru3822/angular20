package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class Company {

  private Long id, parentCompanyId;
  private String companyName, awsBucket, abbreviation, logoPresignedUrl;
}
