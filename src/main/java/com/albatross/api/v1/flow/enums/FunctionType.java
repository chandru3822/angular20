package com.albatross.api.v1.flow.enums;

public enum FunctionType {
    REQUIREMENT(1L),
    ACTION(2L);

    public final Long id;

    FunctionType(Long id) {
        this.id = id;
    }

    public static FunctionType get(String name) {
        name = name.toLowerCase();
        for (FunctionType s : values()) {
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
