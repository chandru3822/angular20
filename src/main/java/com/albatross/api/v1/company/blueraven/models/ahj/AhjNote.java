package com.albatross.api.v1.company.blueraven.models.ahj;

import lombok.Data;

import java.util.Date;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjNote {
    private Long id, createdById, modifiedById, noteTypeId;
    private String note, createdBy, modifiedBy;
    private Date dateCreated, dateModified;
}
