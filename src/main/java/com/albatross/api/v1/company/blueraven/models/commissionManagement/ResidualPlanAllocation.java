package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randa on 4/13/17.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ResidualPlanAllocation {

    private Long id, residualPlanId, min, max, allocation, fdcCount;
    private Double partialAllocation;
}
