package com.albatross.api.v1.company.blueraven.models.ahj;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Getter
@Setter
public class AhjDesignDetail extends AhjDesign {
    private List<AhjContact> contacts;
    private List<AhjRequirement> designRequirements, electricalRequirements, structuralRequirements,
                                 utilityRequirements;
}
