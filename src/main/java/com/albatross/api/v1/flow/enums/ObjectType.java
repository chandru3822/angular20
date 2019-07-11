package com.albatross.api.v1.flow.enums;

public enum ObjectType {
    PROJECT(1),
    CUSTOMER(2),
    USER(3),
    PROCESS_STEP(4);

    public final Integer id;

    ObjectType(Integer id) {
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
