package com.albatross.api.v1.flow.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ProjectStatus {

    private Long id;
    private String projectStatusType;
    private Boolean archived;

}
