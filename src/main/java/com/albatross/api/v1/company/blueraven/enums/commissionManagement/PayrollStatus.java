package com.albatross.api.v1.company.blueraven.enums.commissionManagement;


public enum PayrollStatus {
    PENDING(1L),
    SUBMITTED(2L),
    APPROVED(3L),
    REJECTED(4L);

    private Long id;

    PayrollStatus(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }
}
