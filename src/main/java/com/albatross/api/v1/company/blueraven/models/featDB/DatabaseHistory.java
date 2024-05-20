package com.albatross.api.v1.company.blueraven.models.featDB;
import lombok.Data;

import java.util.Date;

@Data
public class DatabaseHistory {
    private String fieldName, previousValue, updatedValue, modifiedBy;
    private Date dateModified;
    private Integer dataType;
}

