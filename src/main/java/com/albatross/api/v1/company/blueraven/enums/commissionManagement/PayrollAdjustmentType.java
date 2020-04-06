package com.albatross.api.v1.company.blueraven.enums.commissionManagement;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
public enum PayrollAdjustmentType {
    COMMISSION(1L),
    OVERRIDE(2L);

    private Long id;

    PayrollAdjustmentType(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
