package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;
//import org.joda.time.DateTime;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjNote {
    private Long id, createdById, updatedById, noteTypeId;
    private String note, createdBy, updatedBy;

//    private DateTime created, updated;
    private Date created, updated;
}