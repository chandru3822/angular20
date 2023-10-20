package com.albatross.api.v1.flow.enums;

public enum RoundRobinUserType {
    SCHEDULE_TO(1L),
    SCHEDULE_BY(2L);


    public final Long id;

    RoundRobinUserType(Long id) {
        this.id = id;
    }

    public static RoundRobinUserType get(String name) {
        name = name.toLowerCase();
        for (RoundRobinUserType s : values()) {
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
