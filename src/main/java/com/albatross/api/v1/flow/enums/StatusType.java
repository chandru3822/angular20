package com.albatross.api.v1.flow.enums;

public enum StatusType {
    ACTIVE(1L),
    INACTIVE(2L);

    public final Long id;

    StatusType(Long id) {
        this.id = id;
    }

    public static StatusType get(String name) {
        name = name.toLowerCase();
        for (StatusType s : values()) {
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
