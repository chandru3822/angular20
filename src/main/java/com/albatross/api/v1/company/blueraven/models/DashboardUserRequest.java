package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

/**
 * Created by Joseph Canto on 2020-09-15.
 */
@Data
public class DashboardUserRequest {
    private Long userId;
    private String districts, regions, offices;
}
