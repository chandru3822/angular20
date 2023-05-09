package com.albatross.api.v1.flow.enums;

public enum SystemActivity {
    EVENT_CREATED(1L),
    PS_CREATED(2L);

    public final Long id;

    SystemActivity(Long id) {
        this.id = id;
    }
}
