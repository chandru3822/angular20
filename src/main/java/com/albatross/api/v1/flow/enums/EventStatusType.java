package com.albatross.api.v1.flow.enums;

public enum EventStatusType {
    ACTIVE(1L),
    COMPLETE(2L),
    CANCELLED(3L);

    public final Long id;

    EventStatusType(Long id) {
        this.id = id;
    }

    public static EventStatusType get(String name) {
        name = name.toLowerCase();
        for (EventStatusType s : values()) {
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
