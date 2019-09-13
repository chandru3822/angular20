package com.albatross.api.v1.flow.model;

import java.util.List;

import com.albatross.api.v1.flow.enums.UserStatusType;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.google.common.collect.Lists;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class User {

    private Long id, companyId, parentCompanyId;
    private String email, username, password, firstName, lastName, fullName, userStatusType, timezone, awsBucket, companyName, companyAbbreviation;
    private Long userStatusTypeId;
    private List<UserPermission> permissions;

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
