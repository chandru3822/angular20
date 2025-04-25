package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
public class ProposalAdderRequest {
  private List<AdderItem> adderItems;

  @Data
  @NoArgsConstructor
  public static class AdderItem {
    private Long id;
    private BigDecimal customAdderAmount;
    private String adderType;
    private String fieldName;
    private Boolean applied = true;
    private Integer customAdderDataType; // Data type ID from constants.DATA_FIELD_TYPES
  }
}
