package com.albatross.api.v1.company.blueraven.controllers.partsMaster.models;

import lombok.Data;

@Data
public class PartsMasterValueFilter {
  private Long targetFieldId, targetFlowCustomFieldId, parentFieldId, parentFieldValue;
}
