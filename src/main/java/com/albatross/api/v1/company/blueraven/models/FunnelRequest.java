package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-09-18.
 */
@Data
public class FunnelRequest {
    private String start, end, trendStart, trendEnd;
    private List<Long> brsProvidedSources, selfGenSources, leadsCreatedSources, sources, users, areas, orgs, appointmentTypeIds, leadSourceIds;
    private int funnelId;
    private Boolean isCheckedInColumn, isCohort, hideInactive;
}
