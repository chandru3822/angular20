package com.albatross.api.v1.company.blueraven.models.featDB;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@Data
@NoArgsConstructor
public class Incentive {
    private Long id;
    private Long stateId, companyStateId, typeId, statusId;
    private String name, state, type, status;
    private Date dateCreated;
    private Boolean archived, active;

    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;


}
