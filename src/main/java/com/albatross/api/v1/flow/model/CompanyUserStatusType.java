package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CompanyUserStatusType {

    private Long id, companyId;
    private String userStatusType;
    private Boolean hasAccess, archived;
}
