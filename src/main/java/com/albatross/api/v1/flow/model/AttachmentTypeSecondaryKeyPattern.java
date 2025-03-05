package com.albatross.api.v1.flow.model;


import lombok.Data;

/**
 * Created by kevinthompson on 01/23/25.
 * Used for creating attachments that need to be uploaded to
 * more than one place, example: Utility bills that need to go
 * into the uploads as well as a file to have them processed
 */
@Data
public class AttachmentTypeSecondaryKeyPattern {

  private Long attachmentTypeId, secondaryKeyPatternId;
  private Boolean archived;
  // non DB field
  private String keyPattern;

}

