package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Data
public class OfficeRank {
    private Long orgId, pitchPercentage, totalAppointments, totalPitches;
    private String org, rank;
}
