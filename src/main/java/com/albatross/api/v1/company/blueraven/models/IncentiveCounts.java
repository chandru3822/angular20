package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2021-01-07.
 */
@Data
public class IncentiveCounts {
    private Double q1, q2, q3, q4;

    /* For Closer Dashboard Incentive 2021 requirement that a closer must have at least 1 *
     * self-gen FDC in each quarter in order to earn points for that quarter              */
    private Boolean q1QualificationMet, q2QualificationMet, q3QualificationMet, q4QualificationMet;
}
