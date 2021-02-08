package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class User {

    private Long id, companyId, parentCompanyId, highestParentCompanyId, highestCompanyId, defaultAppointmentLength, homePageCompanyFeatureId;
    private int loginAttempts;
    //not sure if i should put this here.  there are times when i need a unique list of users so i can coalesce their positions. but other times i need lists of all users so 1 user can show up multiple times with different positions
    private Long userPositionId;
    // companyId = context
    // parentCompanyId = true parent of ^^ that company (can be null, can point to albatross)
    // highestParentCompanyId = highest company id within company_id's hierarchy
    // highestCompanyId = highest company a user has access to (regardless of context and hierarchies) <- mostly used to determine if user is system admin/has access to albatross
    private String email, phoneNumber, username, firstName, lastName, fullName, newPassword, primaryPosition,
        userStatusType, timezone, awsBucket, companyName, companyAbbreviation, position, homePagePath, title; //title used for scheduling tool resource name
    private Long companyUserStatusId, userStatusTypeId, notificationTypeId;
    private List<Company> companies;
    private List<FeatureAccessControl> featureAccess;
    private List<UserPosition> userPositions;
    private Boolean hasAccess;
    private UUID uuid;
    private Timestamp expiryDate;

    private List<UserOrgHierarchy> hierarchy;

    @JsonIgnore
    private String password;

    //so far this is only used for saving
    List<CustomFieldGroup> customFieldGroups;

    @JsonIgnore
    public boolean isUnlocked(){
        return this.getHighestCompanyId() == 1L || (null == this.getHasAccess() ? false : this.getHasAccess());
    }
}
