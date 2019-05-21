package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.google.common.collect.Lists;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class User {

    private Long id;
    private String email, password, firstName, lastName, fullName, userStatusType;
    private Long userStatusTypeId;

    @JsonIgnore
    public boolean isUnlocked(){
        return Lists.newArrayList(1L, 7L, 8L).contains(this.getUserStatusTypeId());
    }
}
