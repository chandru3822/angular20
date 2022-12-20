package com.albatross.api.v1.company.blueraven.models.featDB;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Data
public class AhjSummary {
  private Long id, stateId, metroAreaId, companyStateId;
  private String name, state, metroArea;
}
