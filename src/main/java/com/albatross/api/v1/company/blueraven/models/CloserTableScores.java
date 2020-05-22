package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2020-04-30.
 */
@Data
public class CloserTableScores {
    private Long id, leadGenFdcPercentageNumerator, leadGenFdcPercentageDenominator, selfGenFdc, totalFdc;
    private String name, companyName, region, salesMetroArea;
}
