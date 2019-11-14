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
    private List<UserPermission> permissions;

    private List<UserOrgHierarchy> hierarchy;

    //so far this is only used for saving
    List<CustomFieldGroup> customFieldGroups;

    @JsonIgnore
    public boolean isUnlocked(){
        // BR had INACTIVE as an unlocked type, but that makes no sense to me. maybe we should remove that?
        return Lists.newArrayList(
            UserStatusType.ACTIVE.id,
            UserStatusType.PENDING_TERMINATION.id,
            UserStatusType.INACTIVE.id).contains(this.getUserStatusTypeId()
        );
    }
}
