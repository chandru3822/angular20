package com.albatross.api.v1.flow.model;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class CreateAttachmentType {
  @NotEmpty
  private String attachmentType;

  @NotNull
  private Long companyId;

  @Size(min = 1)
  private List<Long> objectCategoryIds;
}
