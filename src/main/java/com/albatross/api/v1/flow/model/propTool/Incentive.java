package com.albatross.api.v1.flow.model.propTool;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class Incentive {

  private Long id, incentiveCategoryId, incentiveTypeId;
  private String incentiveCategory, incentiveType;
  private Boolean archived, active;
  private Double amount;
  private Date startDate, endDate;

  //i'm trying to reuse this as much as possible. but sometimes incentiveEntityId = companyCountryId, companyStateId or utilityStateId
  private Long incentiveEntityId;
  private String incentiveEntityName;

  // only one of these 3 values will be populated, depending on incentiveCategoryId
  private Long utilityStateIncentiveId, countryIncentiveId, stateIncentiveId;
}
