package com.albatross.api.v1.company.blueraven.models.featDB;
import lombok.Data;

import java.util.Date;

@Data
public class DatabaseHistory {
    private String field_name, previous_value, updated_value, modified_by;
    private Date date_modified;
}

