package com.albatross.api.v1.company.blueraven.controllers.apiManagement.models;

import lombok.Data;

import java.sql.Timestamp;

@Data
public class Key {
    public Long
        id,
        partnerId,
        createdBy,
        modifiedBy;

    public String
        key,
        description;

    public Boolean isAdmin;

    public Timestamp
        dateCreated,
        dateModified,
        validUntil;
}
