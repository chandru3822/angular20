package com.albatross.api.v1.company.blueraven.controllers.proposal.models;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.util.UUID;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Data
@Accessors(chain = true)
public class ProposalTemplateBlock implements Serializable {
  private Integer id;

  private Integer themeKeyId;

  private String themeKey;

  private Integer blockTypeId;

  private String blockType;

  private Integer blockKindId;

  private String blockKind;

  private Object blockStyle;

  private Object blockValue;

  private Integer blockOrder;

  private Integer version;

  private Integer parentId;

  private String visibility;

  private UUID blockUUID;
}
