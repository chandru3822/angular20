package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * Created by Joseph Canto on 2020-09-18.
 */
@Data
public class FunnelRequest {
    private BigDecimal targetInstallations;
    private String start, end;
    private List<Long> brsProvidedSources, selfGenSources, sources, users, areas, orgs;
    private int funnelId;
    private Boolean isCheckedInColumn;
}
