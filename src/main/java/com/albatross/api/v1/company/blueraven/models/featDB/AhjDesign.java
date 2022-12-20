package com.albatross.api.v1.company.blueraven.models.featDB;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Data
public class AhjDesign {
    private Long id, ahjId, stateId;
    private String stateName, ahjName;

    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;

    // these are only used when updates are performed for all AHJ Designs in a specified state
    private Boolean updateAllInState;
    private List<Long> ahjIds, designIds;
}
