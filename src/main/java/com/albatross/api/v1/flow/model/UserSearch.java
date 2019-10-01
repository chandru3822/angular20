package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserSearch {

    //search is the generic search all fields thing
    private String search, firstName, lastName, email, phone;

}
