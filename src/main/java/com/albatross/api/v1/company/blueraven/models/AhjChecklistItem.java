package com.albatross.api.v1.company.blueraven.models;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjChecklistItem {
    private Long id, displayOrder, checklistTypeId, failedInspectionResourceId;
    private String description, failedInspectionProject;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private Date failedInspectionDate;
}