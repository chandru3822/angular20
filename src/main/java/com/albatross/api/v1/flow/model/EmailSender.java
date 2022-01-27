package com.albatross.api.v1.flow.model;

import lombok.Data;

import java.util.Date;

/**
 * Created by John Berns on 2020-09-30.
 */
@Data
public class EmailSender {
    private Long id;
    private String emailAddress;
    private Boolean archived;
    private Date dateCreated, dateModified;
    private Long createdById, modifiedById;
    private Long companyId;
    private boolean isDefault;
}
