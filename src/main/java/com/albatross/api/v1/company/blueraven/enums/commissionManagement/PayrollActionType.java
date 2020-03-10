package com.albatross.api.v1.company.blueraven.enums.commissionManagement;

public enum PayrollActionType {
    SUBMITTED(1L),
    APPROVED(2L),
    REJECTED(3L);

    private Long id;

    PayrollActionType(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
