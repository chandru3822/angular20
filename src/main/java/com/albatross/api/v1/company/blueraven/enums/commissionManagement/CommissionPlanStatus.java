package com.albatross.api.v1.company.blueraven.enums.commissionManagement;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
public enum CommissionPlanStatus {
    PENDING(1L),
    ACTIVE(2L),
    INACTIVE(3L);

    private Long id;

    CommissionPlanStatus(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
