package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Data
public class AhjDesign {
    private Long id;
    private String codes, note, referenceStandards, groundSnowLoad, windSpeed, roofSnowLoad;
    private Long utilityId;


    //this is only used for saving custom field groups
    List<CustomFieldGroup> customFieldGroups;
}
