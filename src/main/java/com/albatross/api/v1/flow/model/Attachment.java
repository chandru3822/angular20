package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
import java.util.Date;
import java.util.UUID;

@Data
public class Attachment {
    private Long id, size, sourceId, attachmentTypeId, companyId, projectProcessStepId;
    private String filename, fileExtension, contentType, s3Key, url, presignedUrl, uploadedBy, processStepName, publicUrl;
    private Date dateCreated, dateModified;
    private UUID uuid;
    private Boolean archived, show, main;
}
