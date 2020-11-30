package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.Date;

@Data
public class AppAttachment {
    private Long id, size, appTypeId, attachmentTypeId, companyId;
    private String filename, contentType, s3Key, url, presignedUrl, appType, keyPattern;
    private Date dateCreated, dateModified;
    private Boolean archived, show;
}
