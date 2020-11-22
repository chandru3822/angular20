package com.albatross.api.v1.flow.enums;

public enum PostalCodeZoneUserType {
    SCHEDULE_TO(1L),
    SCHEDULE_BY(2L);


    public final Long id;

    PostalCodeZoneUserType(Long id) {
        this.id = id;
    }

    public static PostalCodeZoneUserType get(String name) {
        name = name.toLowerCase();
        for (PostalCodeZoneUserType s : values()) {
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
