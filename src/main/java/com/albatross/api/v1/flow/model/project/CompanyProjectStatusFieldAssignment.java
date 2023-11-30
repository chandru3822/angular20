package com.albatross.api.v1.flow.model.project;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CompanyProjectStatusFieldAssignment {

    private Long id, companyProjectStatusTypeId, dataViewFieldConfigId, dataViewChildFieldConfigId, displayOrder;

    private String fieldName;

    private Boolean archived;

}
