package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.Date;

@Data
public class Announcement {
    private Long id, companyId, attachmentId;
    private String title, alertText, subtitle, description, hyperlink, presignedUrl;
    private Date startTime, endTime;
    private Boolean archived, expandable, showOnWeb, showOnMobile, seen, read, published;
}
