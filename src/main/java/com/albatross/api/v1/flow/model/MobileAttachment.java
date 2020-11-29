package com.albatross.api.v1.flow.model;

import lombok.Data;

@Data
public class MobileAttachment {
    private Attachment attachment;
    private String keyPattern;
    private Long appTypeId, attachmentTypeId;
}
