package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Data
public class SetterPerformance {
    private Long pitchPercentage, totalAppointments, totalPitches, toBeatId, pitchesToGo;
    private String toBeatName, currentRank, imageUrl, imageAltText;
}
