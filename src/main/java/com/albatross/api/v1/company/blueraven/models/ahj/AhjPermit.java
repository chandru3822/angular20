package com.albatross.api.v1.company.blueraven.models.ahj;

import com.albatross.api.v1.company.blueraven.models.CustomFieldGroup;
import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-15.
 */
@Data
public class AhjPermit {
    private Long id, ahjId, stateId;
    private String stateName, ahjName;

    // this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;

    // these are only used when updates are performed for all AHJ Permits in a specified state
    private Boolean updateAllInState;
    private List<Long> ahjIds, permitIds;
}
