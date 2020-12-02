package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2020-10-12.
 */
@Data
public class RoundRobinLeadAllocationScores {
    private Long userId, selfGen, averageAvailability;
    private Double leadGenFdc, score;
    private String closerName, userImageUrl, userImageAltText;
}
