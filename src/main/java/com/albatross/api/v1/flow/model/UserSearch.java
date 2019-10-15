package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class UserSearch {

    //search is the generic search all fields thing
    private String search, firstName, lastName, email, phone;
    private List<Integer> statuses, positions, orgs;
    private Boolean primaryFlag;
}
