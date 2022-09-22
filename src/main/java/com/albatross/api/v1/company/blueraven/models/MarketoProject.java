package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.project.Project;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MarketoProject extends Project {

    private String firstName, lastName, leadStatus, leadSource, finalDesignApprovedDate, energizedDate, installationStartTime;
}
