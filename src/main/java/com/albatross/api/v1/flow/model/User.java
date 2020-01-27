package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.enums.UserStatusType;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.google.common.collect.Lists;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class User {

    private Long id, companyId, parentCompanyId;
    private String email, phoneNumber, username, password, firstName, lastName, fullName,
        userStatusType, timezone, awsBucket, companyName, companyAbbreviation, position, title; //title used for scheduling tool resource name
    private Long userStatusTypeId;
    private Boolean schedulable;
    private List<Company> companies;
    private List<UserPermission> permissions;

    private List<UserOrgHierarchy> hierarchy;

    //so far this is only used for saving
    List<CustomFieldGroup> customFieldGroups;

    @JsonIgnore
    public boolean isUnlocked(){
        // to make this work for all companies, "ACTIVE" is now the only status when users can log in
        return Lists.newArrayList(UserStatusType.ACTIVE.id).contains(this.getUserStatusTypeId()
        );
    }
}
