package com.albatross.api.v1.flow.enums;

public enum ObjectType {
    PROJECT(1L),
    CUSTOMER(2L),
    USER(3L),
    PROCESS_STEP(4L),
    ORGANIZATION(5L);

    public final Long id;

    ObjectType(Long id) {
        this.id = id;
    }

    public static ObjectType get(String name) {
        name = name.toLowerCase();
        for (ObjectType s : values()) {
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
