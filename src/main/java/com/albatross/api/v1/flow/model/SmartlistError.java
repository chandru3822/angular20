package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
public class SmartlistError {
    private Long id, smartlistId, createdById;

    private Timestamp dateCreated;

    private String smartlist, query, fields, requirements, stacktrace;
}
