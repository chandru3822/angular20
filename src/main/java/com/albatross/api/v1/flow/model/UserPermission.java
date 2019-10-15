package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserPermission {

    private Long id;
    private String permissionName, permissionCode;
    private Boolean archived;

}
