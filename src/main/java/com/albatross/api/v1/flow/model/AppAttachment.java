package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.Date;

@Data
public class AppAttachment {
    private Long id, size, appTypeId, attachmentTypeId, companyId, buildNumber;
    private String filename, contentType, s3Key, url, presignedUrl, appType, keyPattern, displayName, versionNumber;
    private Date dateCreated, dateModified;
    private Boolean archived, show;
}
