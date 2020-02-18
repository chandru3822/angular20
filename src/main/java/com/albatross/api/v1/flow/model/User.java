package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class User {

    private Long id, companyId, parentCompanyId, highestParentCompanyId, highestCompanyId;
    // companyId = context
    // parentCompanyId = true parent of ^^ that company (can be null, can point to albatross)
    // highestParentCompanyId = highest company id within company_id's hierarchy
    // highestCompanyId = highest company a user has access to (regardless of context and hierarchies) <- mostly used to determine if user is system admin/has access to albatross
    private String email, phoneNumber, username, password, firstName, lastName, fullName,
        userStatusType, timezone, awsBucket, companyName, companyAbbreviation, position, title; //title used for scheduling tool resource name
    private Long customerUserStatusTypeId;
    private List<Company> companies;
    private List<FeatureAccessControl> featureAccess;
    private Boolean hasAccess;

    private List<UserOrgHierarchy> hierarchy;

    //so far this is only used for saving
    List<CustomFieldGroup> customFieldGroups;

    @JsonIgnore
    public boolean isUnlocked(){
        // to make this work for all companies, "ACTIVE" is now the only status when users can log in
        return this.getHighestCompanyId() == 1L || (null == this.getHasAccess() ? false : this.getHasAccess());
    }
}
