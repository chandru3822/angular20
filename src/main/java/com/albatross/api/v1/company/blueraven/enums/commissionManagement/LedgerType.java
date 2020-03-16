package com.albatross.api.v1.company.blueraven.enums.commissionManagement;


public enum LedgerType {
    COMMISSION(1L),
    COMMISSION_ADJUSTMENT(2L),
    OVERRIDE(3L),
    RESIDUAL(4L);

    private Long id;

    LedgerType(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
