package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjRequirement {
    private Long id;

    private Long ahjId, requirementTypeId, originalRequirementId, position, utilityId, createdById, modifiedById, statusId;
    private String name, description, createdBy, modifiedBy, status, requirementType;
    private Date dateCreated, dateModified;
    private Boolean complete, hasOpenChallenge, archived;
}