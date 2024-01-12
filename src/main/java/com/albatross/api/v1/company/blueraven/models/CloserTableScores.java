package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2020-04-30.
 */
@Data
public class CloserTableScores {
    private Long userId, selfGenFdc, totalFdc;
    private Double leadGenFdcPercentage;
    private String name, userStatusType, officeName, region, metroArea;
}
