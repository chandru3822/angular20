package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Data;


@Data
@Builder
@JsonPropertyOrder({"Organization Name", "Organization Type", "Parent Organization", "Active"})
public class OrgExportTemplate {
  public static OrgExportTemplate from(Org other) {
    return OrgExportTemplate.builder()
        .orgName(other.getOrgName())
        .orgType(other.getOrgType())
        .parentOrgName(other.getParentOrgName())
        .activeFlag(other.getActiveFlag() ? "Yes" : "No")
        .build();
  }

  /////////////////////////////////////////////////////////////////////////////
  // directly-sourced data — the data supplied by
  // Org — starts here
  /////////////////////////////////////////////////////////////////////////////
  @JsonProperty("Organization Name")
  private String orgName;

  @JsonProperty("Organization Type")
  private String orgType;

  @JsonProperty("Parent Organization")
  private String parentOrgName;

  @JsonProperty("Active")
  private String activeFlag;


}
