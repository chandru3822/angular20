package com.albatross.api.v1.company.blueraven.controllers.partsMaster.models;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class PartsMasterVersionHistoryChangeSet extends PartsMasterVersion {
  private List<PartsMasterVersionHistory> history = new ArrayList<>();
}
