package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.Date;
import java.util.UUID;

@Data
public class Attachment {
    private Long id, size, sourceId, attachmentTypeId, companyId, projectProcessStepId, projectProcessStepEventId;
    private String filename, fileExtension, contentType, s3Key, url, attachmentType,
      presignedUrl, uploadedBy, processStepName, publicUrl, originLocation, displayName;
    private Date dateCreated, dateModified;
    private UUID uuid;
    private Boolean archived, show, linked;
}
