package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;

@Data
public class CompanyDashboardTargets {
    private Long id;
    private Date targetDate;
    private Integer bookingsBrs, bookingsPartner, finalDesignsCompletedBrs, finalDesignsCompletedPartner,
                    substantialCompletionsBrs, substantialCompletionsPartner, finalCompletionsBrs,
                    finalCompletionsPartner;
}
