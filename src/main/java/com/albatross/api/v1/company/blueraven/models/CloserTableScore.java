package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2020-04-30.
 */
@Data
public class CloserTableScore {
    private Long userId, selfGenFdc, totalFdc, rank, averageAvailability, futureAvailability;
    private Double leadGenFdcPercentage, score;
    private String closerName, userStatusType, officeName, region, metroArea, rankLabel, userImageUrl, userImageAltText;
}
