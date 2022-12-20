package com.albatross.api.v1.company.blueraven.models.featDB;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Data
public class Utility {
    private Long id;
    private Long utilityId, ahjId, stateId, metroAreaId, companyStateId;
    private String name, metroArea, state;
    private Boolean archived;

    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;
}
