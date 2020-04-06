package com.albatross.api.v1.flow.enums;

public enum IncentiveCategory {
    COUNTRY(1L),
    STATE(2L),
    UTILITY_STATE(3L);

    public final Long id;

    IncentiveCategory(Long id) {
        this.id = id;
    }

    public static IncentiveCategory get(String name) {
        name = name.toLowerCase();
        for (IncentiveCategory s : values()) {
            if (s.toString().equals(name)) {
                return s;
            }
        }
        throw new IllegalArgumentException();
    }

    public String toString() {
        return name().toLowerCase().replaceAll("_", " ");
    }
}
