package com.albatross.api.v1.flow.model;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
import java.util.Date;

@Data
public class Attachment {
    private Long id, size, sourceId, attachmentTypeId, companyId, projectProcessStepId;
    private String filename, fileExtension, contentType, s3Key, url, presignedUrl, uploadedBy, processStepName;
    private Date dateCreated, dateModified;
    private Boolean archived, show, main;
}
