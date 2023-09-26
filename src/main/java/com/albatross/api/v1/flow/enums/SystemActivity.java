package com.albatross.api.v1.flow.enums;

public enum SystemActivity {
    EVENT_CREATED(1L),
    PS_CREATED(2L),
    PROJECT_CREATED(3L),
    PS_DELETED(9L),
    EVENT_DELETED(10L);

    public final Long id;

    SystemActivity(Long id) {
        this.id = id;
    }
}
