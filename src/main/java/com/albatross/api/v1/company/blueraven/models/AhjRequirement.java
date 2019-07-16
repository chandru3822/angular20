package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjRequirement {
    private Long id;

    private Long ahjId, requirementTypeId, originalRequirementId, position, utilityId, createdById, updatedById, statusId;
    private String name, description, createdBy, updatedBy, status, requirementType;
    private Date dateCreated, dateUpdated;
    private Boolean complete, hasOpenChallenge, archived;
}