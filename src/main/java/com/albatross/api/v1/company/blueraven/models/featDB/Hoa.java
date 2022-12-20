package com.albatross.api.v1.company.blueraven.models.featDB;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;

import java.util.List;

@Data
public class Hoa {
    private Long id;
    private Long stateId, companyStateId, managementCompanyId;
    private String name, state, managementCompany;
    private Boolean archived;

    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;


}
