package com.albatross.api.v1.company.blueraven.controllers.partsMaster.models;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.time.OffsetDateTime;

@Data
public class PartsMasterVersion {
  private Long id;
  private String version;
  private String notes;
  private String createdBy, modifiedBy;
  private OffsetDateTime dateCreated, dateModified;
  private boolean isPrimaryVersion;

  @JsonIgnore
  private Integer partsMasterVersionStatusId;

  public PartsMasterVersionStatus getStatus() {
    return PartsMasterVersionStatus.values()[partsMasterVersionStatusId];
  }
}
