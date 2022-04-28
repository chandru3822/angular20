package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@Accessors(chain = true)
public class ProposalTemplateBlock implements Serializable, Comparable<ProposalTemplateBlock> {
  private Integer id;

  private Integer themeKeyId;

  private String themeKey;

  private Integer blockTypeId;

  private String blockType;

  private Object blockStyle;

  private Object blockValue;

  private Integer blockOrder;

  private Integer version;

  private Integer parentId;

  @Override
  public int compareTo(ProposalTemplateBlock o) {
    if (this.parentId == null || o.parentId == null) {
      return this.blockOrder.compareTo(o.getBlockOrder());
    }

    final int parentIdCmp = parentId.compareTo(o.getParentId());
    if (parentIdCmp == 0) {
      return this.blockOrder.compareTo(o.getBlockOrder());
    }

    return parentIdCmp;
  }
}
